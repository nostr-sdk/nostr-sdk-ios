//
//  TextNoteEvent.swift
//  
//
//  Created by Bryan Montz on 7/23/23.
//

import Foundation

/// An event that contains plaintext content.
///
/// > Note: [NIP-01 Specification](https://github.com/nostr-protocol/nips/blob/b503f8a92b22be3037b8115fe3e644865a4fa155/01.md#basic-event-kinds)
public final class TextNoteEvent: NostrEvent, CustomEmojiInterpreting, ThreadedEventTagInterpreting {

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

    @available(*, deprecated, message: "Deprecated in favor of TextNote.Builder.")
    init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .textNote, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    /// Pubkeys referenced in the note content.
    @available(*, deprecated, message: "Deprecated in favor of referencedPubkeys. Mention is an overloaded term from NIP-10.")
    public var mentionedPubkeys: [String] {
        referencedPubkeys
    }

    /// Events referenced in the note content.
    @available(*, deprecated, message: "Deprecated in favor of referencedEventIds. Mention is an overloaded term from NIP-10.")
    public var mentionedEventIds: [String] {
        referencedEventIds
    }

    /// a short subject for a text note, similar to subjects in emails.
    ///
    /// See [NIP-14 - Subject tag in Text events](https://github.com/nostr-protocol/nips/blob/master/14.md).
    public var subject: String? {
        firstValueForTagName(.subject)
    }
}

public extension EventCreating {

    /// Creates a ``TextNoteEvent`` (kind 1) and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - content: The content of the text note.
    ///   - repliedEvent: The event being replied to.
    ///   - mentionedEventTags: The ``EventTag``s with `mention` markers for the mentioned events.
    ///   - subject: A subject for the text note.
    ///   - customEmojis: The custom emojis to emojify with if the matching shortcodes are found in the content field.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``TextNoteEvent``.
    ///
    /// See [NIP-01](https://github.com/nostr-protocol/nips/blob/master/01.md)
    /// See [NIP-10 - On "e" and "p" tags in Text Events (kind 1)](https://github.com/nostr-protocol/nips/blob/master/10.md)
    @available(*, deprecated, message: "Deprecated in favor of TextNote.Builder.")
    func textNote(withContent content: String, replyingTo repliedEvent: TextNoteEvent? = nil, mentionedEventTags: [EventTag]? = nil, subject: String? = nil, customEmojis: [CustomEmoji]? = nil, signedBy keypair: Keypair) throws -> TextNoteEvent {

        let builder = TextNoteEvent.Builder()
            .content(content)
            .subject(subject)

        if let repliedEvent {
            try builder.repliedEvent(repliedEvent)
        }

        if let customEmojis {
            builder.customEmojis(customEmojis)
        }

        if let mentionedEventTags {
            try builder.mentionedEventTags(mentionedEventTags)
        }

        return try builder.build(signedBy: keypair)
    }
}

public extension TextNoteEvent {
    /// Builder of a ``TextNoteEvent``.
    final class Builder: NostrEvent.Builder<TextNoteEvent>, CustomEmojiBuilding, ThreadedEventTagBuilding {
        public init() {
            super.init(kind: .textNote)
        }

        /// Sets the subject for this text note.
        @discardableResult
        public final func subject(_ subject: String?) -> Builder {
            guard let subject else {
                return self
            }

            appendTags(Tag(name: .subject, value: subject))
            return self
        }
    }
}
