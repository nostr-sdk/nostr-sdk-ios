//
//  PubkeyTag.swift
//  NostrSDK
//
//  Created by Terry Yiu on 10/31/24.
//

import Foundation

public struct PubkeyTag: RelayProviding, RelayURLValidating, Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.tag == rhs.tag
    }

    /// The ``Tag`` that represents this pubkey tag.
    public let tag: Tag

    /// The pubkey being referenced.
    public var pubkey: String {
        tag.value
    }

    /// The URL of a recommended relay associated with the reference.
    public var relayURL: URL? {
        guard let relayString = tag.otherParameters.first, !relayString.isEmpty else {
            return nil
        }

        return try? validateRelayURLString(relayString)
    }

    /// The petname of the pubkey.
    public var petname: String? {
        guard tag.otherParameters.count >= 2 else {
            return nil
        }

        return tag.otherParameters[1]
    }

    /// Initializes an event tag from a ``Tag``.
    /// `nil` is returned if the tag is not an pubkey tag.
    public init?(tag: Tag) {
        guard tag.name == TagName.pubkey.rawValue else {
            return nil
        }

        self.tag = tag
    }

    /// Initializes a pubkey tag.
    /// - Parameters:
    ///   - publicKey: The ``PublicKey``  being referenced.
    ///   - relayURL: The URL of a recommended relay associated with the reference.
    ///   - petname: The petname of the pubkey.
    public init(publicKey: PublicKey, relayURL: URL? = nil, petname: String? = nil) throws {
        let validatedRelayURL: URL?
        if let relayURL {
            validatedRelayURL = try RelayURLValidator.shared.validateRelayURL(relayURL)
        } else {
            validatedRelayURL = nil
        }

        var tagOtherParameters = [validatedRelayURL?.absoluteString ?? ""]

        if let petname {
            tagOtherParameters.append(petname)
        }

        tag = .pubkey(publicKey.hex, otherParameters: tagOtherParameters)
    }

    /// Initializes a pubkey tag.
    /// - Parameters:
    ///   - pubkey: The hex pubkey being referenced.
    ///   - relayURL: The URL of a recommended relay associated with the reference.
    ///   - petname: The petname of the pubkey.
    public init(pubkey: String, relayURL: URL? = nil, petname: String? = nil) throws {
        guard let publicKey = PublicKey(hex: pubkey) else {
            throw EventCreatingError.invalidInput
        }

        try self.init(publicKey: publicKey, relayURL: relayURL, petname: petname)
    }
}
