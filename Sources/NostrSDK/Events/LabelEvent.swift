//
//  LabelEvent.swift
//  NostrSDK
//
//  Created by Terry Yiu on 10/31/24.
//

import Foundation

/// This event attaches labels to label targets. This allows for labeling of events, people, relays, or topics.
/// This supports several use cases, including distributed moderation, collection management, license assignment, and content classification.
///
/// See [NIP-32 Labeling](https://github.com/nostr-protocol/nips/blob/master/32.md).
public final class LabelEvent: NostrEvent {

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

    /// The targeted events from this label event.
    public var targetedEvents: [EventTag] {
        allTags(withTagName: .event).compactMap { EventTag(tag: $0) }
    }

    /// The targeted pubkeys from this label event.
    public var targetedPubkeys: [PubkeyTag] {
        allTags(withTagName: .pubkey).compactMap { PubkeyTag(tag: $0) }
    }

    /// The targeted event coordinates from this label event.
    public var targetedEventCoordinates: [EventCoordinates] {
        referencedEventCoordinates
    }

    /// The targeted relay URLs from this label event.
    public var targetedRelayURLs: [URL] {
        tags.filter { $0.name == "r" }.compactMap { URL(string: $0.value) }
    }

    /// The targeted topics from this label event.
    public var targetedTopics: [String] {
        allValues(forTagName: .hashtag)
    }
}

/// Interprets label tags on an event.
///
/// If this is a ``LabelEvent`` kind (1985), the label is attached to the label target.
/// Otherwise, the label is attached to this event itself as the target.
///
/// See [NIP-32 Labeling](https://github.com/nostr-protocol/nips/blob/master/32.md).
public protocol LabelTagInterpreting: NostrEvent {}
public extension LabelTagInterpreting {
    /// The label namespaces.
    var labelNamespaces: [String] {
        allValues(forTagName: .labelNamespace)
    }

    /// Dictionary of label namespaces or marks mapped to list of labels.
    /// If a label does not include mark, `ugc` (user generated content) is implied and keyed from `ugc` in the dictionary.
    var labels: [String: [String]] {
        let filteredTags = allTags(withTagName: .label)
        return Dictionary(
            grouping: filteredTags,
            by: { $0.otherParameters.first ?? "ugc" }
        ).mapValues { tags in
            tags.map { tag in tag.value }
        }
    }

    /// The labels that include the specified mark.
    /// If no mark is provided to this function or on a label tag, `ugc` (user generated content) is implied.
    func labels(for mark: String?) -> [String] {
        let resolvedMark = mark ?? "ugc"
        return allTags(withTagName: .label)
            .filter { labelTag in
                let labelMark = labelTag.otherParameters.first ?? "ugc"
                return labelMark == resolvedMark
            }.map { $0.value }
    }
}

public extension LabelEvent {
    /// Builder of a ``LabelEvent``.
    final class Builder: NostrEvent.Builder<LabelEvent>, RelayURLValidating {
        public init() {
            super.init(kind: .label)
        }

        /// Adds an event as a label target.
        @discardableResult
        public final func target(eventId: String, relayURL: URL? = nil) throws -> Builder {
            appendTags(try EventTag(eventId: eventId, relayURL: relayURL).tag)
        }

        /// Adds a pubkey as a label target.
        @discardableResult
        public final func target(pubkey: String, relayURL: URL? = nil) throws -> Builder {
            if let relayURL {
                let validatedRelayURL = try validateRelayURL(relayURL)
                appendTags(.pubkey(pubkey, otherParameters: [validatedRelayURL.absoluteString]))
            } else {
                appendTags(.pubkey(pubkey))
            }
            return self
        }

        /// Adds event coordinates as a label target.
        @discardableResult
        public final func target(eventCoordinates: EventCoordinates) throws -> Builder {
            appendTags(eventCoordinates.tag)
        }

        /// Adds a relay URL as a label target.
        @discardableResult
        public final func target(relayURL: URL) throws -> Builder {
            let validatedRelayURL = try validateRelayURL(relayURL)
            return appendTags(Tag(name: "r", value: validatedRelayURL.absoluteString))
        }

        /// Adds a hashtag topic as a label target.
        @discardableResult
        public final func target(topic: String) throws -> Builder {
            appendTags(.hashtag(topic))
        }
    }
}

/// Builder that labels a target.
///
/// If this is a ``LabelEvent`` kind (1985), the label is attached to the label target.
/// Otherwise, the label is attached to this event itself as the target.
///
/// See [NIP-32 Labeling](https://github.com/nostr-protocol/nips/blob/master/32.md).
public protocol LabelTagBuilding: NostrEventBuilding {}
public extension LabelTagBuilding {
    /// Labels an event in a given namespace.
    ///
    /// Namespaces can be any string but SHOULD be unambiguous by using a well-defined namespace (such as an ISO standard) or reverse domain name notation.
    ///
    /// Namespaces are RECOMMENDED in order to support searching by namespace rather than by a specific tag.
    /// The special `ugc` ("user generated content") namespace MAY be used when the label content is provided by an end user.
    ///
    /// Namespaces starting with # indicate that the label target should be associated with the label's value.
    /// This is a way of attaching standard nostr tags to events, pubkeys, relays, urls, etc.
    ///
    /// If this is a ``LabelEvent`` kind (1985), the label is attached to the label target.
    /// Otherwise, the label is attached to this event itself as the target.
    ///
    /// See [NIP-32 Labeling](https://github.com/nostr-protocol/nips/blob/master/32.md).
    @discardableResult
    func appendLabels(_ labels: String..., namespace: String) -> Self {
        self.appendLabels(contentsOf: labels, namespace: namespace)
    }

    /// Labels an event in a given namespace.
    ///
    /// Namespaces can be any string but SHOULD be unambiguous by using a well-defined namespace (such as an ISO standard) or reverse domain name notation.
    ///
    /// Namespaces are RECOMMENDED in order to support searching by namespace rather than by a specific tag.
    /// The special `ugc` ("user generated content") namespace MAY be used when the label content is provided by an end user.
    ///
    /// Namespaces starting with # indicate that the label target should be associated with the label's value.
    /// This is a way of attaching standard nostr tags to events, pubkeys, relays, urls, etc.
    ///
    /// If this is a ``LabelEvent`` kind (1985), the label is attached to the label target.
    /// Otherwise, the label is attached to this event itself as the target.
    ///
    /// See [NIP-32 Labeling](https://github.com/nostr-protocol/nips/blob/master/32.md).
    @discardableResult
    func appendLabels(contentsOf labels: [String], namespace: String) -> Self {
        guard !labels.isEmpty else {
            return self
        }

        appendTags(Tag(name: .labelNamespace, value: namespace))
        for label in labels {
            appendTags(Tag(name: .label, value: label, otherParameters: [namespace]))
        }
        return self
    }

    /// Labels the event with a given mark.
    /// A mark SHOULD be included. If it is not included, `ugc` (user generated content) is implied.
    ///
    /// If this is a ``LabelEvent`` kind (1985), the label is attached to the label target.
    /// Otherwise, the label is attached to this event itself as the target.
    ///
    /// See [NIP-32 Labeling](https://github.com/nostr-protocol/nips/blob/master/32.md).
    @discardableResult
    func appendLabels(_ labels: String..., mark: String? = nil) -> Self {
        self.appendLabels(contentsOf: labels, mark: mark)
    }

    /// Labels the event with a given mark.
    /// A mark SHOULD be included. If it is not included, `ugc` (user generated content) is implied.
    ///
    /// If this is a ``LabelEvent`` kind (1985), the label is attached to the label target.
    /// Otherwise, the label is attached to this event itself as the target.
    ///
    /// See [NIP-32 Labeling](https://github.com/nostr-protocol/nips/blob/master/32.md).
    @discardableResult
    func appendLabels(contentsOf labels: [String], mark: String? = nil) -> Self {
        let otherParameters: [String]
        if let mark {
            otherParameters = [mark]
        } else {
            otherParameters = []
        }
        for label in labels {
            appendTags(Tag(name: .label, value: label, otherParameters: otherParameters))
        }
        return self
    }
}
