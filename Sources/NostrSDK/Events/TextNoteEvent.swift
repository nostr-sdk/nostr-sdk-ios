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
public final class TextNoteEvent: NostrEvent, CustomEmojiInterpreting {
    
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

    /// Pubkeys mentioned in the note content.
    public var mentionedPubkeys: [String] {
        allValues(forTagName: .pubkey)
    }
    
    /// Events mentioned in the note content.
    public var mentionedEventIds: [String] {
        allValues(forTagName: .event)
    }

    /// The ``EventTag`` that denotes the reply event being responded to.
    /// This event tag may be the same as ``rootEventTag`` if this note is a direct reply to the root of a thread.
    public var replyEventTag: EventTag? {
        let eventTags = tags.compactMap { EventTag(tag: $0) }

        // Return the first event tag with a reply marker if it exists.
        if let reply = eventTags.first(where: { $0.marker == .reply }) {
            return reply
        }

        // A direct reply to the root of a thread should have a single marked event tag of type "root".
        if let root = eventTags.first(where: { $0.marker == .root }) {
            return root
        }

        // If there are no reply or root event markers, and there is at least one event tag with a marker,
        // then we can make a reasonable assumption that the client that created the event does not use
        // deprecated positional event tags, so there is no reply event tag.
        guard eventTags.allSatisfy({ $0.marker == nil }) else {
            return nil
        }

        // Otherwise, NIP-10 states that the last event tag is the one being responded to.
        return eventTags.last
    }

    /// The ``EventTag`` that denotes the root event of the thread being responded to.
    public var rootEventTag: EventTag? {
        let eventTags = tags.compactMap { EventTag(tag: $0) }

        // Return the first event tag with a root marker if it exists.
        if let root = eventTags.first(where: { $0.marker == .root }) {
            return root
        }

        // If there are no root event markers, and there is at least one event tag with a marker,
        // then we can make a reasonable assumption that the client that created the event does not use
        // deprecated positional event tags, so there is no root event tag.
        guard eventTags.allSatisfy({ $0.marker == nil }) else {
            return nil
        }

        // NIP-10 states that the first event tag is the root.
        return eventTags.first
    }

    /// The ``EventTag``s that denotes quoted or reposted events.
    public var mentionedEventTags: [EventTag] {
        let eventTags = tags.compactMap { EventTag(tag: $0) }

        // Only mention markers are considered mentions in the preferred spec.
        // If there is a mix of mention markers and no markers, the event tags
        // with no markers are ignored.
        let mentionedEventTags = eventTags.filter { $0.marker == .mention }

        if !mentionedEventTags.isEmpty {
            return mentionedEventTags
        }

        // If the event has any event tags with any marker, then we can make a reasonable assummption
        // that the client that created this event does not use deprecated positional event tags,
        // so there are no mentions.
        //
        // Even if there are no event tag markers, the deprecated positional event tag spec in NIP-10
        // states that there are no mentions unless there are 3 or more event tags.
        guard eventTags.allSatisfy({ $0.marker == nil }) && eventTags.count >= 3 else {
            return []
        }

        // The first event tag is the root and the last event tag is the one being replied to.
        // Everything else in between is a mention.
        return eventTags.dropFirst().dropLast()
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
    final class Builder: NostrEvent.Builder<TextNoteEvent>, CustomEmojiBuilding {
        public init() {
            super.init(kind: .textNote)
        }

        /// Sets the ``TextNoteEvent`` that is being replied to from this text note that is being built.
        @discardableResult
        public final func repliedEvent(_ repliedEvent: TextNoteEvent, relayURL: URL? = nil) throws -> Self {
            if let rootEventTag = repliedEvent.rootEventTag {
                // Maximize backwards compatibility with NIP-10 deprecated positional event tags
                // by ensuring ordering of types of event tags.

                // Root tag comes first.
                if rootEventTag.marker == .root {
                    insertTags(rootEventTag.tag, at: 0)
                } else {
                    // Recreate the event tag with a root marker if the one being read does not have a marker.
                    let rootEventTagWithMarker = try EventTag(eventId: rootEventTag.eventId, relayURL: rootEventTag.relayURL, marker: .root, pubkey: rootEventTag.pubkey)
                    insertTags(rootEventTagWithMarker.tag, at: 0)
                }

                // Reply tag comes last.
                appendTags(try EventTag(eventId: repliedEvent.id, relayURL: relayURL, marker: .reply, pubkey: repliedEvent.pubkey).tag)
            } else {
                // If the event being replied to has no root marker event tag,
                // the event being replied to is the root.
                insertTags(try EventTag(eventId: repliedEvent.id, relayURL: relayURL, marker: .root, pubkey: repliedEvent.pubkey).tag, at: 0)
            }

            // When replying to a text event E, the reply event's "p" tags should contain all of E's "p" tags as well as the "pubkey" of the event being replied to.
            // Example: Given a text event authored by a1 with "p" tags [p1, p2, p3] then the "p" tags of the reply should be [a1, p1, p2, p3] in no particular order.
            appendTags(contentsOf: repliedEvent.tags.filter { $0.name == TagName.pubkey.rawValue })

            // Add the author "p" tag if it was not already added.
            if !tags.contains(where: { $0.name == TagName.pubkey.rawValue && $0.value == repliedEvent.pubkey }) {
                appendTags(Tag(name: .pubkey, value: repliedEvent.pubkey))
            }

            return self
        }

        /// Sets the list of events, represented by ``EventTag``, that are mentioned from this text note that is being built.
        @discardableResult
        public final func mentionedEventTags(_ mentionedEventTags: [EventTag]) throws -> Builder {
            guard !mentionedEventTags.isEmpty else {
                return self
            }

            guard mentionedEventTags.allSatisfy({ $0.marker == .mention }) else {
                throw EventCreatingError.invalidInput
            }

            let newTags = mentionedEventTags.map { $0.tag }
            // Mentions go in between root markers and reply markers.
            if let replyMarkerIndex = tags.firstIndex(where: { $0.otherParameters.count >= 2 &&  $0.otherParameters[1] == EventTagMarker.reply.rawValue }) {
                insertTags(contentsOf: newTags, at: replyMarkerIndex)
            } else {
                appendTags(contentsOf: newTags)
            }

            return self
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
