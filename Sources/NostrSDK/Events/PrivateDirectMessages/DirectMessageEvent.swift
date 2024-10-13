//
//  DirectMessageEvent.swift
//  NostrSDK
//
//  Created by Terry Yiu on 10/13/24.
//

import Foundation

/// A direct message event. It must never be signed. If it is signed, the message might leak to relays and become fully public.
/// See [NIP-17 - Private Direct Messages](https://github.com/nostr-protocol/nips/blob/master/17.md)
public final class DirectMessageEvent: NostrEvent, ThreadedEventTagInterpreting {

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(id: String, pubkey: String, createdAt: Int64, kind: EventKind, tags: [Tag], content: String, signature: String?) {
        super.init(id: id, pubkey: pubkey, createdAt: createdAt, kind: kind, tags: tags, content: content, signature: signature)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    required init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), pubkey: String) {
        super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, pubkey: pubkey)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    required init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    /// Pubkeys mentioned in the note content.
    public var mentionedPubkeys: [String] {
        allValues(forTagName: .pubkey)
    }

    /// Defines the current name/topic of the conversation.
    /// Any member of the chat room can change the topic by simply submitting a new subject to an existing pubkey + p-tags room.
    /// There is no need to send subject in every message.
    /// The newest subject in the thread is the subject of the conversation.
    public var subject: String? {
        firstValueForTagName(.subject)
    }
}

public extension DirectMessageEvent {
    /// Builder of a ``DirectMessageEvent``.
    final class Builder: NostrEvent.Builder<DirectMessageEvent>, ThreadedEventTagBuilding {
        public init() {
            super.init(kind: .directMessage)
        }

        /// Defines the current name/topic of the conversation.
        /// Any member of the chat room can change the topic by simply submitting a new subject to an existing pubkey + p-tags room.
        /// There is no need to send subject in every message.
        /// The newest subject in the thread is the subject of the conversation.
        @discardableResult
        public final func subject(_ subject: String) -> Self {
            return appendTags(Tag(name: .subject, value: subject))
        }

        @available(*, unavailable, message: "DirectMessageEvent must never be signed. If it is signed, the message might leak to relays and become fully public.")
        public override func build(signedBy keypair: Keypair) throws -> DirectMessageEvent {
            try super.build(signedBy: keypair)
        }
    }
}

public protocol DirectMessageEncrypting: EventCreating {}
public extension DirectMessageEncrypting {
    /// Encrypts an unsigned ``DirectMessageEvent`` into a ``SealEvent``, and then wrapped in a ``GiftWrapEvent``.
    func encrypt(withDirectMessageEvent directMessageEvent: DirectMessageEvent, toRecipient recipient: PublicKey, recipientAlias: PublicKey? = nil, signedBy keypair: Keypair) throws -> GiftWrapEvent {
        guard directMessageEvent.pubkey == keypair.publicKey.hex else {
            throw EventCreatingError.invalidInput
        }
        return try giftWrap(withRumor: directMessageEvent.rumor, toRecipient: recipient, recipientAlias: recipientAlias, signedBy: keypair)
    }
}
