//
//  HashtagInterpreting.swift
//
//
//  Created by Terry Yiu on 11/15/23.
//

import Foundation

/// Intreprets hashtag tags on events.
public protocol HashtagInterpreting: NostrEvent {}
public extension HashtagInterpreting {
    /// The hashtags of the event.
    var hashtags: [String] {
        tags.filter { $0.name == TagName.hashtag.rawValue }
            .map { $0.value }
    }
}
