//
//  ContentWarningTag.swift
//  NostrSDK
//
//  Created by Terry Yiu on 11/3/24.
//

import Foundation

/// Interprets the content-warning tag.
///
/// See [NIP-36 Sensitive Content / Content Warning](https://github.com/nostr-protocol/nips/blob/master/36.md).
public protocol ContentWarningTagInterpreting: NostrEvent {}
public extension ContentWarningTagInterpreting {
    /// Content warning to indicate that the event's content needs to be approved by readers to be shown. Clients can hide the content until the user acts on it.
    var contentWarning: String? {
        firstValueForRawTagName("content-warning")
    }
}

/// Builder that adds a content warning to an event.
///
/// See [NIP-36 Sensitive Content / Content Warning](https://github.com/nostr-protocol/nips/blob/master/36.md).
public protocol ContentWarningTagBuilding: NostrEventBuilding {}
public extension ContentWarningTagBuilding {
    /// Adds a content warning to indicate that the event's content needs to be approved by readers to be shown. Clients can hide the content until the user acts on it.
    @discardableResult
    func contentWarning(_ contentWarning: String) -> Self {
        appendTags(Tag(name: "content-warning", value: contentWarning))
    }
}
