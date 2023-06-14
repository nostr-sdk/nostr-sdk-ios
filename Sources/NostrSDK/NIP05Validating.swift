//
//  NIP05Validating.swift
//  
//
//  Created by Bryan Montz on 6/12/23.
//

import Foundation

/// A constant that describes a type of error encountered while validating a [NIP-05](https://github.com/nostr-protocol/nips/blob/master/05.md#nip-05) identifier.
public enum NIP05ValidationError: Error {
    /// The identifier was not in the expected format. Valid identifiers look like email addresses, such as "bob@example.com".
    case invalidIdentifierFormat
    
    /// The URL composed from the local-part and domain of a provided identifier was invalid.
    case invalidComposedURL
    
    /// The pubkey provided did not match the one received from the host.
    case failedValidation
}

/// A response to a [NIP-05](https://github.com/nostr-protocol/nips/blob/master/05.md#nip-05) request.
///
/// It be decoded from json data that looks like this:
/// ```json
/// {
///   "names": {
///     "bob": "b0635d6a9851d3aed0cd6c495b282167acf761729078d975fc341b22650b07b9"
///   },
///   "relays": {
///     "b0635d6a9851d3aed0cd6c495b282167acf761729078d975fc341b22650b07b9": [ "wss://relay.example.com", "wss://relay2.example.com" ]
///   }
/// }
/// ```
struct NIP05Response: Codable {
    
    /// An object with names as properties and hex-encoded pubkeys as values.
    ///
    /// Use this to look up the pubkey associated with an email-like [internet identifier](https://datatracker.ietf.org/doc/html/rfc5322#section-3.4.1).
    let names: [String: String]?
    
    /// An object with public keys as properties and arrays of relay URLs as values
    ///
    /// Use this to learn in which relays a specific user may be found.
    let relays: [String: [String]]?
}

/// Provides functions for parsing and requesting data associated with a [NIP-05](https://github.com/nostr-protocol/nips/blob/master/05.md#nip-05) identifier.
public protocol NIP05DataRequesting {}
public extension NIP05DataRequesting {
    
    /// Parses an [internet identifier](https://datatracker.ietf.org/doc/html/rfc5322#section-3.4.1) into the local-part and the domain.
    /// - Parameter identifier: an email-like internet identifier
    /// - Returns: A tuple containing the local part and the domain
    ///
    /// Use this function to separate an email-like internet identifier into its components: the local-part and the domain.
    ///
    /// For example, for the `identifier` "bob@example.com", the return value would be a tuple containing "bob" and "example.com".
    private func parse(nip05Identifier identifier: String) throws -> (String, String) {
        let components = identifier.components(separatedBy: "@")
        guard components.count == 2 else {
            throw NIP05ValidationError.invalidIdentifierFormat
        }
        let domain = components[1]
        guard domain.contains(".") else {
            throw NIP05ValidationError.invalidIdentifierFormat
        }
        return (components[0], domain)
    }
    
    /// Constructs a URL for checking a [NIP-05](https://github.com/nostr-protocol/nips/blob/master/05.md#nip-05) identifier.
    /// - Parameters:
    ///   - localPart: The local-part of the identifier (e.g. "bob" in "bob@example.com").
    ///   - domain: The domain to make the request to (e.g. "example.com" in "bob@example.com").
    /// - Returns: The fully specified URL
    private func nip05URL(localPart: String, domain: String) -> URL? {
        URL(string: "https://\(domain)/.well-known/nostr.json?name=\(localPart)")
    }
    
    /// Parses the provided identifier and requests the associated data from `https://<domain>/.well-known/nostr.json?name=<local-part>`.
    /// - Parameters:
    ///   - identifier: An email-like [internet identifier](https://datatracker.ietf.org/doc/html/rfc5322#section-3.4.1).
    ///   - dataRequester: The object to use to make the request. `URLSession.shared` will be used if not provided.
    /// - Returns: The response object obtained by making the request using the `dataRequester`.
    internal func nip05Response(for identifier: String, dataRequester: DataRequesting = URLSession.shared) async throws -> NIP05Response {
        let (localPart, domain) = try parse(nip05Identifier: identifier)
        
        guard let url = nip05URL(localPart: localPart, domain: domain) else {
            throw NIP05ValidationError.invalidComposedURL
        }
        
        let (data, _) = try await dataRequester.data(from: url, delegate: nil)
        
        return try JSONDecoder().decode(NIP05Response.self, from: data)
    }
    
    /// Requests the pubkey associated with a [NIP-05](https://github.com/nostr-protocol/nips/blob/master/05.md#nip-05) identifier.
    /// - Parameters:
    ///   - identifier: An email-like [internet identifier](https://datatracker.ietf.org/doc/html/rfc5322#section-3.4.1).
    ///   - dataRequester: The object to use to make the request. `URLSession.shared` will be used if not provided.
    /// - Returns: The pubkey associated with the identifier or nil.
    func pubkeyForNIP05Identifier(_ identifier: String, dataRequester: DataRequesting = URLSession.shared) async throws -> String? {
        let (localPart, _) = try parse(nip05Identifier: identifier)
        let nip05Response = try await nip05Response(for: identifier, dataRequester: dataRequester)
        return nip05Response.names?[localPart]
    }
    
    /// Requests the relays associated with a [NIP-05](https://github.com/nostr-protocol/nips/blob/master/05.md#nip-05) identifier.
    /// - Parameters:
    ///   - identifier: An email-like [internet identifier](https://datatracker.ietf.org/doc/html/rfc5322#section-3.4.1).
    ///   - dataRequester: The object to use to make the request. `URLSession.shared` will be used if not provided.
    /// - Returns: A list of relay URLs associated with the identifier or nil.
    func relayURLsForNIP05Identifier(_ identifier: String, dataRequester: DataRequesting = URLSession.shared) async throws -> [String]? {
        let (localPart, _) = try parse(nip05Identifier: identifier)
        let nip05Response = try await nip05Response(for: identifier, dataRequester: dataRequester)
        guard let pubkey = nip05Response.names?[localPart] else {
            return nil
        }
        return nip05Response.relays?[pubkey]
    }
}

/// Provides a function for validating a [NIP-05](https://github.com/nostr-protocol/nips/blob/master/05.md#nip-05) identifier.
public protocol NIP05Validating: NIP05DataRequesting {}
public extension NIP05Validating {
    
    /// Validates a [NIP-05](https://github.com/nostr-protocol/nips/blob/master/05.md#nip-05) identifier against a provided pubkey.
    /// - Parameters:
    ///   - identifier: An email-like [internet identifier](https://datatracker.ietf.org/doc/html/rfc5322#section-3.4.1).
    ///   - pubkey: The pubkey to check against the one returned from the host.
    ///   - dataRequester: The object to use to make the request. `URLSession.shared` will be used if not provided.
    ///
    /// Use this function to validate that a [NIP-05](https://github.com/nostr-protocol/nips/blob/master/05.md#nip-05) identifier and pubkey match. If the function does not throw an error, then the identifier has been successfully validated.
    ///
    /// For example, if you have the identifier "bob@example.com" and a pubkey "b0635d6a9851d3aed0cd6c495b282167acf761729078d975fc341b22650b07b9", you can check if the [NIP-05](https://github.com/nostr-protocol/nips/blob/master/05.md#nip-05) identifier points to the pubkey like this:
    /// ```swift
    /// Task {
    ///     do {
    ///         try await validateNIP05Identifier("bob@example.com", pubkey: "b0635d6a9851d3aed0cd6c495b282167acf761729078d975fc341b22650b07b9")
    ///     } catch {
    ///         // provide error handling here
    ///     }
    /// }
    /// ```
    func validateNIP05Identifier(_ identifier: String, pubkey: String, dataRequester: DataRequesting = URLSession.shared) async throws {
        let nip05Pubkey = try await pubkeyForNIP05Identifier(identifier, dataRequester: dataRequester)
        guard nip05Pubkey == pubkey else {
            throw NIP05ValidationError.failedValidation
        }
    }
}
