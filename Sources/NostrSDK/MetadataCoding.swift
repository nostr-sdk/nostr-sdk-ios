//
//  MetadataCoding.swift
//
//
//  Created by Bryan Montz on 12/3/23.
//

import Foundation

/// The type of Bech32-encoded identifier.
/// These identifiers can be used to succinctly encapsulate metadata to aid in the discovery of events and users.
/// See [NIP-19](https://github.com/nostr-protocol/nips/blob/master/19.md) for information about how these Bech32-encoded
public enum Bech32IdentifierType: String {
    case profile = "nprofile"
    case event = "nevent"
    case relay = "nrelay"
    case address = "naddr"
}

/// An error encountered while encoding or decoding TLV (Type-Length-Value) data.
public enum TLVCodingError: Error {
    case unknownPrefix
    case missingExpectedData
    case malformedData
    case failedToEncode
}

/// The components of the TLV-encoded (Type-Length-Value) data.
private enum TLVEncodingType: Int {
    case special, relay, author, kind
    
    var typeByte: String {
        String(format: "%02x", rawValue)
    }
}

/// A container for metadata about a user or event, for encoding and decoding to and from Bech32-encoded identifiers.
public struct Metadata {
    
    /// A 32-byte hexadecimal public key.
    var pubkey: String?
    
    /// One or more relays on which the user or event can be found.
    var relays: [String]?
    
    /// A 32-byte hexadecimal event identifier.
    var eventId: String?
    
    /// An identifier (d-tag) associated with an event, for use with parameterized replaceable events.
    var identifier: String?
    
    /// The kind of the event, as an integer.
    var kind: UInt32?
}

/// A protocol containing a set of functions for encoding and decoding identifiers.
/// See [NIP-19](https://github.com/nostr-protocol/nips/blob/master/19.md) for the full specifications.
public protocol MetadataCoding {}
public extension MetadataCoding {
    
    /// Decodes the metadata contained in a Bech32-encoded identifier (e.g. nprofile, nevent, nrelay, naddr).
    /// - Parameter identifier: The identifier to decode.
    /// - Returns: The metadata decoded from the identifier.
    ///
    /// Throws an error if the hrp (human-readable part) of the identifier is unknown or if the data is missing or malformed.
    func decodedMetadata(from identifier: String) throws -> Metadata {
        let (hrp, checksum) = try Bech32.decode(identifier)
        guard let identifierType = Bech32IdentifierType(rawValue: hrp) else {
            throw TLVCodingError.unknownPrefix
        }
        
        guard let tlvString = checksum.base8FromBase5?.hexString else {
            throw TLVCodingError.missingExpectedData
        }
        
        return try decodedTLVString(tlvString, identifierType: identifierType)
    }
    
    /// Decodes the metadata contained in a TLV-encoded string.
    /// - Parameters:
    ///   - tlvString: The TLV-encoded string.
    ///   - identifierType: The identifier type to decode.
    /// - Returns: The metadata decoded from the identifier.
    ///
    /// > Note: This function is provided for debugging and testing, as it is an intermediate result.
    func decodedTLVString(_ tlvString: String, identifierType: Bech32IdentifierType) throws -> Metadata {
        var pubkey: String?
        var relays = [String]()
        var eventId: String?
        var identifier: String?
        var kind: UInt32?
        
        var scanner = tlvString[...]
        while !scanner.isEmpty {
            let typeByte = scanner.readAndDropFirst(2)
            let lengthByte = scanner.readAndDropFirst(2)
            guard let lengthInBytes = Int(lengthByte, radix: 16) else {
                throw TLVCodingError.malformedData
            }
            
            let contentBytes = scanner.readAndDropFirst(lengthInBytes * 2)  // 2 chars per byte
            
            guard let typeInt = Int(typeByte),
                  let contentType = TLVEncodingType(rawValue: typeInt) else {
                // unrecognized type, NIP-19 says to ignore rather than fail here
                continue
            }
            
            let content = String(contentBytes)
            switch contentType {
            case .special:
                switch identifierType {
                case .profile:
                    pubkey = content
                case .event:
                    eventId = content
                case .relay:
                    if let decoded = content.decoded(using: .ascii) {
                        relays.append(decoded)
                    }
                case .address:
                    if let decoded = content.decoded() {
                        identifier = decoded
                    }
                }
            case .relay:
                if let decoded = content.decoded(using: .ascii) {
                    relays.append(decoded)
                }
            case .author:
                pubkey = content
            case .kind:
                if let kindInt = UInt32(content, radix: 16) {
                    kind = kindInt
                }
            }
        }
        
        return Metadata(pubkey: pubkey,
                        relays: relays,
                        eventId: eventId,
                        identifier: identifier,
                        kind: kind)
    }
    
    /// The Bech32-encoded, TLV-encoded identifier based on the specified type and metadata.
    /// - Parameters:
    ///   - metadata: The metadata to encode.
    ///   - identifierType: The identifier type to encode to.
    /// - Returns: The requested identifier.
    func encodedIdentifier(with metadata: Metadata, identifierType: Bech32IdentifierType) throws -> String {
        let tlvEncoded = try tlvEncodedString(with: metadata, identifierType: identifierType)
        guard let encoded = Bech32.encode(identifierType.rawValue, hex: tlvEncoded) else {
            throw TLVCodingError.failedToEncode
        }
        return encoded
    }
    
    /// The TLV-encoded (Type-Length-Value) string based on the specified type and metadata.
    /// - Parameters:
    ///   - metadata: The metadata to encode.
    ///   - identifierType: The identifier type to encode to.
    /// - Returns: The TLV-encoded String.
    ///
    /// Throws an error if the metadata does not contain the required information to create the requested identifier.
    ///
    /// > Note: This function is provided for debugging and testing, as it is an intermediate result and must be Bech32-encoded before transmitting.
    func tlvEncodedString(with metadata: Metadata, identifierType: Bech32IdentifierType) throws -> String {
        var contents = ""
        
        let specialTypeValue: Data?
        switch identifierType {
        case .profile:
            guard let pubkey = metadata.pubkey else {
                throw TLVCodingError.missingExpectedData
            }
            specialTypeValue = pubkey.hexadecimalData
        case .event:
            guard let eventId = metadata.eventId else {
                throw TLVCodingError.missingExpectedData
            }
            specialTypeValue = eventId.hexadecimalData
        case .relay:
            guard let relay = metadata.relays?.first else {
                throw TLVCodingError.missingExpectedData
            }
            specialTypeValue = relay.data(using: .ascii)
        case .address:
            specialTypeValue = metadata.identifier?.data(using: .utf8)
        }
        
        if let lengthByte = (specialTypeValue ?? Data()).byteLengthString {
            contents.append(TLVEncodingType.special.typeByte)
            contents.append(lengthByte)
            contents.append(specialTypeValue?.hexString ?? "")
        }
        
        // relays
        if identifierType != .relay, let relays = metadata.relays {
            for relay in relays where !relay.isEmpty {
                let relayData = relay.data(using: .ascii)
                if let lengthByte = (relayData ?? Data()).byteLengthString {
                    contents.append(TLVEncodingType.relay.typeByte)
                    contents.append(lengthByte)
                    contents.append(relayData?.hexString ?? "")
                }
            }
        }
        
        if identifierType == .address || identifierType == .event {
            // author
            if let pubkey = metadata.pubkey, let lengthByte = pubkey.hexadecimalData?.byteLengthString {
                contents.append(TLVEncodingType.author.typeByte)
                contents.append(lengthByte)
                contents.append(pubkey)
            }
            
            // kind
            if let kind = metadata.kind {
                var bigEndianData = Data()
                withUnsafeBytes(of: kind.bigEndian) { bigEndianData.append(contentsOf: $0) }
                if let lengthByte = bigEndianData.byteLengthString {
                    contents.append(TLVEncodingType.kind.typeByte)
                    contents.append(lengthByte)
                    contents.append(bigEndianData.hexString)
                }
            }
        }
        
        return contents
    }
}

fileprivate extension Data {
    
    /// The length of the Data in a one-byte hexadecimal string.
    ///
    /// For example, for a Data with 32 bytes, the result will be "20".
    var byteLengthString: String? {
        // Ensure the length is representable by a byte (0 to 255)
        guard count >= 0 && count <= 255 else {
            return nil // Length exceeds one byte
        }

        // Format the length as a two-character hexadecimal string
        return String(format: "%02x", count)
    }
}

fileprivate extension Substring {
    
    /// Extracts the leading characters in a String.
    /// - Parameter numberOfCharacters: The number of characters to read.
    /// - Returns: The extracted characters.
    ///
    /// > Note: This function mutates the string by removing the leading characters from it.
    mutating func readAndDropFirst(_ numberOfCharacters: Int = 1) -> Substring {
        let result = prefix(numberOfCharacters)
        self = dropFirst(numberOfCharacters)
        return result
    }
}
