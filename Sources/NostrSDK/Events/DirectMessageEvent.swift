//
//  DirectMessageEvent.swift
//  NostrSDK
//
//  Created by Terry Yiu on 10/13/24.
//

import Foundation

/// A direct message event. It must never be signed. If it is signed, the message might leak to relays and become fully public.
///
/// This event should never be published directly to relays. It should be encrypted, sealed, and wrapped in a ``GiftWrapEvent``
/// using ``EventCreating/giftWrap(withDirectMessageEvent:toRecipient:recipientAlias:signedBy:)``
/// before publishing to relays.
///
/// The set of `pubkey` + `p` tags defines a chat room.
/// If a new `p` tag is added or a current one is removed, a new room is created with clean message history.
///
/// See [NIP-17 - Private Direct Messages](https://github.com/nostr-protocol/nips/blob/master/17.md).
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

    /// Defines the current name/topic of the conversation.
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

public extension EventCreating {
    /// Creates a ``GiftWrapEvent`` that takes a ``DirectMessageEvent`` and seals it in a signed ``SealEvent``, and then wraps that seal encrypted in the content of the gift wrap.
    /// In order to ensure the direct message is published and decryptable by all N members of the chat room, one gift wrap must be created per recipient (including the sender) for a total of N gift wraps.
    ///
    /// - Parameters:
    ///   - directMessageEvent: a ``DirectMessageEvent`` that is not signed.
    ///   - recipient: the ``PublicKey`` of the receiver of the event. This pubkey will be used to encrypt the event. If `recipientAlias` is not provided, this pubkey will automatically be added as a tag to the ``GiftWrapEvent``.
    ///   - recipientAlias: optional ``PublicKey`` of the receiver's alias used to receive gift wraps without exposing the receiver's identity. It is not used to encrypt the event. If it is provided, this pubkey will automatically be added as a tag to the ``GiftWrapEvent``.
    ///   - keypair: The real ``Keypair`` to encrypt the direct message and sign the seal with. Note that a different random one-time use key is used to sign the gift wrap.
    func giftWrap(withDirectMessageEvent directMessageEvent: DirectMessageEvent, toRecipient recipient: PublicKey, recipientAlias: PublicKey? = nil, signedBy keypair: Keypair) throws -> GiftWrapEvent {
        guard directMessageEvent.pubkey == keypair.publicKey.hex else {
            throw EventCreatingError.invalidInput
        }
        return try giftWrap(withRumor: directMessageEvent, toRecipient: recipient, recipientAlias: recipientAlias, signedBy: keypair)
    }
}
