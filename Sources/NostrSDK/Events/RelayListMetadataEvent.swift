//
//  RelayListMetadataEvent.swift
//
//
//  Created by Terry Yiu on 7/13/24.
//

import Foundation
import OrderedCollections

/// Defines a replaceable event using kind 10002 to advertise preferred relays for discovering a user's content and receiving fresh content from others.
/// This event doesn't fully replace relay lists that are designed to configure a client's usage of relays.
/// Clients MAY use other relay lists in situations where ``RelayListMetadataEvent`` cannot be found.
///
/// When seeking events from a user, clients SHOULD use the WRITE relays.
/// When seeking events about a user, where the user was tagged, clients SHOULD use the READ relays.
///
/// When broadcasting an event, clients SHOULD:
/// - Broadcast the event to the WRITE relays of the author
/// - Broadcast the event to all READ relays of each tagged user
///
/// > Note: [NIP 65 - Relay List Metadata](https://github.com/nostr-protocol/nips/blob/master/65.md)
public final class RelayListMetadataEvent: NostrEvent, NormalReplaceableEvent {

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    required init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    required init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), pubkey: String) {
        super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, pubkey: pubkey)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(id: String, pubkey: String, createdAt: Int64, kind: EventKind, tags: [Tag], content: String, signature: String?) {
        super.init(id: id, pubkey: pubkey, createdAt: createdAt, kind: kind, tags: tags, content: content, signature: signature)
    }

    init(tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .relayListMetadata, content: "", tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    /// The list of ``UserRelayMetadata`` that describes preferred relays for discovering the user's content and receiving fresh content from others
    public var relayMetadataList: [UserRelayMetadata] {
        tags.compactMap { UserRelayMetadata(tag: $0) }
    }
}

/// Describes a preferred relay for discovering a user's content and receiving fresh content from others.
public struct UserRelayMetadata: Equatable {
    /// The URL of the preferred relay.
    public let relayURL: URL

    /// The relay marker describing what type of events might be found from the preferred relay.
    public let marker: Marker

    public enum Marker {
        /// When seeking events about the user who authored the ``RelayListMetadataEvent``, where the user was tagged,
        /// clients SHOULD use this relay as a read relay.
        case read

        /// When seeking events from the user who authored the ``RelayListMetadataEvent``,
        /// clients SHOULD use this relay as a write relay.
        case write

        /// When seeking events about the user who authored the ``RelayListMetadataEvent``, where the user was tagged,
        /// or when seeking events from the user who authored the ``RelayListMetadataEvent``,
        /// clients SHOULD use this relay as a read and write relay.
        case readAndWrite
    }

    /// Creates a ``UserRelayMetadata`` from a ``Tag``.
    /// The tag must have a tag name of `r`, value of a valid relay URL string, and, optionally, a marker of `read` or `write`.
    /// If the marker is omitted, the relay is used for both read and write.
    ///
    /// A `nil` value is returned if the relay URL string is invalid or the marker is invalid.
    ///
    /// > Note: [NIP 65 - Relay List Metadata](https://github.com/nostr-protocol/nips/blob/master/65.md)
    public init?(tag: Tag) {
        guard tag.name == "r", let relayURL = try? RelayURLValidator.shared.validateRelayURLString(tag.value) else {
            return nil
        }

        switch tag.otherParameters.first {
        case "read":
            marker = .read
        case "write":
            marker = .write
        case .none:
            marker = .readAndWrite
        case .some:
            return nil
        }

        self.relayURL = relayURL
    }

    /// Creates a ``UserRelayMetadata`` from a relay ``URL`` and ``Marker``.
    ///
    /// A `nil` value is returned if the relay URL string is invalid.
    ///
    /// > Note: [NIP 65 - Relay List Metadata](https://github.com/nostr-protocol/nips/blob/master/65.md)
    public init?(relayURL: URL, marker: Marker = .readAndWrite) {
        guard let validatedRelayURL = try? RelayURLValidator.shared.validateRelayURL(relayURL) else {
            return nil
        }
        self.relayURL = validatedRelayURL
        self.marker = marker
    }

    /// The ``Tag`` that represents the user relay metadata that can be used in a ``RelayListMetadataEvent``.
    ///
    /// Note that if this ``UserRelayMetadata`` was initialized with a ``Tag``, the tag returned by this property
    /// may not be the same as the original tag.
    /// For example, if there are extra parameters in the original tag that is not recognized by [NIP-65](https://github.com/nostr-protocol/nips/blob/master/65.md),
    /// they will not be returned by this property.
    public var tag: Tag {
        let otherParameters: [String]
        switch marker {
        case .read:
            otherParameters = ["read"]
        case .write:
            otherParameters = ["write"]
        case .readAndWrite:
            otherParameters = []
        }
        return Tag(name: "r", value: relayURL.absoluteString, otherParameters: otherParameters)
    }
}

public extension EventCreating {
    /// Creates a ``RelayListMetadataEvent`` (kind 10002).
    /// - Parameters:
    ///   - relayMetadataList: The list of ``UserRelayMetadata``.
    ///   - keypair: The ``Keypair`` to sign the event with.
    func relayListMetadataEvent(withRelayMetadataList relayMetadataList: [UserRelayMetadata], signedBy keypair: Keypair) throws -> RelayListMetadataEvent {
        // Using an ordered dictionary to retain the order of the list while de-duplicating the data.
        var deduplicatedMetadata = OrderedDictionary<URL, UserRelayMetadata>()

        for metadata in relayMetadataList {
            if let existingMetadata = deduplicatedMetadata[metadata.relayURL] {
                // If the user relay metadata marker is identical between the duplicates,
                // or if the existing one already has a read and write marker, skip it.
                if existingMetadata.marker == metadata.marker || existingMetadata.marker == .readAndWrite {
                    continue
                }

                // Any other permutation of markers will result in a combined marker of read and write.
                if metadata.marker == .readAndWrite {
                    // If the marker on `metadata` is set to read and write, just use that as the value
                    // instead of creating a new object (as a micro-optimization).
                    deduplicatedMetadata[metadata.relayURL] = metadata
                } else {
                    deduplicatedMetadata[metadata.relayURL] = UserRelayMetadata(relayURL: metadata.relayURL, marker: .readAndWrite)
                }
            } else {
                deduplicatedMetadata[metadata.relayURL] = metadata
            }
        }

        return try RelayListMetadataEvent(tags: deduplicatedMetadata.map { $0.value.tag }, signedBy: keypair)
    }
}
