//
//  DraftPrivateWrapEvent.swift
//  NostrSDK
//
//  Created by Terry Yiu on 2/1/25.
//

import Foundation

/// A private wrap for drafts of any other event kind.
/// The draft event is JSON-stringified, NIP44-encrypted to the signer's public key and placed inside the .content of the event.
/// See [NIP-37 - Draft Events](https://github.com/nostr-protocol/nips/blob/master/37.md).
public final class DraftPrivateWrapEvent: NostrEvent, AddressableEvent, NIP44v2Encrypting {

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

    /// Whether this draft has been deleted by a client.
    var deleted: Bool { content.isEmpty }

    /// The kind of the draft event.
    var draftEventKind: EventKind? {
        guard let draftEventKindString = firstValueForTagName(.kind),
              let draftEventKindNumber = Int(draftEventKindString)
        else {
            return nil
        }

        return EventKind(rawValue: draftEventKindNumber)
    }

    /// The events that this draft anchors, such as parent events on replies.
    var anchorEvents: [EventTag] {
        allTags(withTagName: .event).compactMap { EventTag(tag: $0) }
    }

    /// The event addresses that this draft anchors, such as parent events on replies.
    var anchorEventAddresses: [EventCoordinates] {
        referencedEventCoordinates
    }

    /// The decrypted draft event that this event privately wraps.
    /// - Parameters:
    ///   - keypair: The ``Keypair`` to use to decrypt the draft event.
    /// - Returns: The decrypted ``NostrEvent``, with the subclass defined by `draftEventKind`.
    func draftEvent(decryptedWith keypair: Keypair) throws -> NostrEvent {
        guard let decryptedContent = try? decrypt(payload: content, privateKeyA: keypair.privateKey, publicKeyB: keypair.publicKey) else {
            throw DraftPrivateWrapEventError.decryptionFailed
        }

        guard let jsonData = decryptedContent.data(using: .utf8) else {
            throw DraftPrivateWrapEventError.utf8EncodingFailed
        }

        let classForDraftEventKind = draftEventKind?.classForKind ?? NostrEvent.self

        guard let decryptedDraftEvent = try? JSONDecoder().decode(classForDraftEventKind, from: jsonData) else {
            throw DraftPrivateWrapEventError.jsonDecodingFailed
        }

        return decryptedDraftEvent
    }
}

public enum DraftPrivateWrapEventError: Error {
    case decryptionFailed
    case encryptionFailed
    case jsonDecodingFailed
    case utf8EncodingFailed
}

public extension DraftPrivateWrapEvent {
    /// Builder of a ``DraftPrivateWrapEvent``.
    final class Builder: NostrEvent.Builder<DraftPrivateWrapEvent>, AddressableEventBuilding, NIP44v2Encrypting {
        public init() {
            super.init(kind: .draftPrivateWrap)
        }

        /// Sets the kind of the draft event.
        @discardableResult
        public final func draftEventKind(_ draftEventKind: EventKind) -> Self {
            appendTags(Tag(name: .kind, value: String(draftEventKind.rawValue)))
        }

        /// Appends events that this draft anchors, such as parent events on replies.
        @discardableResult
        public final func appendAnchorEvents(_ anchorEvents: EventTag...) -> Self {
            appendAnchorEvents(contentsOf: anchorEvents)
        }

        /// Appends events that this draft anchors, such as parent events on replies.
        @discardableResult
        public final func appendAnchorEvents(contentsOf anchorEvents: [EventTag]) -> Self {
            appendTags(contentsOf: anchorEvents.map { $0.tag })
        }

        /// Appends event addresses that this draft anchors, such as parent events on replies.
        @discardableResult
        public final func appendAnchorEventAddresses(_ anchorEventAddresses: EventCoordinates...) -> Self {
            appendAnchorEventAddresses(contentsOf: anchorEventAddresses)
        }

        /// Appends event addresses that this draft anchors, such as parent events on replies.
        @discardableResult
        public final func appendAnchorEventAddresses(contentsOf anchorEventAddresses: [EventCoordinates]) -> Self {
            appendTags(contentsOf: anchorEventAddresses.map { $0.tag })
        }

        /// Sets the draft event that this event privately wraps by encrypting it.
        @discardableResult
        public final func draftContent(_ draftEvent: NostrEvent, encryptedWith keypair: Keypair) throws -> Self {
            let jsonData = try JSONEncoder().encode(draftEvent)
            guard let stringifiedJSON = String(data: jsonData, encoding: .utf8) else {
                throw DraftPrivateWrapEventError.utf8EncodingFailed
            }

            guard let encryptedDraftContent = try? encrypt(plaintext: stringifiedJSON, privateKeyA: keypair.privateKey, publicKeyB: keypair.publicKey) else {
                throw DraftPrivateWrapEventError.encryptionFailed
            }

            return content(encryptedDraftContent)
        }
    }
}
