//
//  CreateChannelEvent.swift
//
//
//  Created by Konstantin Yurchenko, Jr on 9/11/24.
//

import Foundation

/// Create a public chat channel.
/// See [NIP-28](https://github.com/nostr-protocol/nips/blob/master/28.md#kind-40-create-channel).
public class CreateChannelEvent: NostrEvent {
    
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

    init(content: String, tags: [Tag], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: Self.kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    class var kind: EventKind {
        .channelCreation
    }
}

public extension EventCreating {
    func createChannelEvent(withContent content: String, signedBy keypair: Keypair) throws -> CreateChannelEvent {
        return try CreateChannelEvent(content: content, tags: [], signedBy: keypair)
    }
}

public extension CreateChannelEvent {
    /// Builder of ``CreateChannelEvent``.
    final class Builder: NostrEvent.Builder<CreateChannelEvent> {
        public init() {
            super.init(kind: .channelCreation)
        }
        
        public final func channelMetadata(_ channelMetadata: ChannelMetadata, merging rawChannelMetadata: [String: Any] = [:]) throws -> Self {
            let channelMetadataAsData = try JSONEncoder().encode(channelMetadata)

            let allChannelMetadataAsData: Data
            if rawChannelMetadata.isEmpty {
                allChannelMetadataAsData = channelMetadataAsData
            } else {
                var channelMetadataAsDictionary = try JSONSerialization.jsonObject(with: channelMetadataAsData, options: []) as? [String: Any] ?? [:]
                channelMetadataAsDictionary.merge(rawChannelMetadata) { (current, _) in current }
                allChannelMetadataAsData = try JSONSerialization.data(withJSONObject: channelMetadataAsDictionary, options: .sortedKeys)
            }

            guard let allChannelMetadataAsString = String(data: allChannelMetadataAsData, encoding: .utf8) else {
                throw EventCreatingError.invalidInput
            }

            content(allChannelMetadataAsString)

            return self
        }
    }
}
