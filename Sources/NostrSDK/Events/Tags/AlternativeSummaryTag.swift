//
//  AlternativeSummaryTag.swift
//  NostrSDK
//
//  Created by Terry Yiu on 11/3/24.
//

import Foundation

/// Interprets the "alt" alternative summary tag.
///
/// See [NIP-31 - Dealing with unknown event kinds](https://github.com/nostr-protocol/nips/blob/master/31.md).
public protocol AlternativeSummaryTagInterpreting: NostrEvent {}
public extension AlternativeSummaryTagInterpreting {
    /// A short human-readable plaintext summary of what the event is about
    /// when the event kind is part of a custom protocol and isn't meant to be read as text (like kind:1).
    var alternativeSummary: String? {
        firstValueForTagName(.alternativeSummary)
    }
}

/// Builder that adds an "alt" alternative summary tag to an event.
///
/// See [NIP-31 - Dealing with unknown event kinds](https://github.com/nostr-protocol/nips/blob/master/31.md).
public protocol AlternativeSummaryTagBuilding: NostrEventBuilding {}
public extension AlternativeSummaryTagBuilding {
    /// Specifies a short human-readable plaintext summary of what the event is about
    /// when the event kind is part of a custom protocol and isn't meant to be read as text (like kind:1).
    @discardableResult
    func alternativeSummary(_ alternativeSummary: String) -> Self {
        appendTags(Tag(name: .alternativeSummary, value: alternativeSummary))
    }
}
