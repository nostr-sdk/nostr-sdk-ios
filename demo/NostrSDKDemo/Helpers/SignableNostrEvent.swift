//
//  SignableNostrEvent.swift
//  Yeti
//
//  Created by Terry Yiu on 2/8/25.
//

import Foundation
import NostrSDK

class SignableNostrEvent: Codable, Equatable, Hashable {
    public static func == (lhs: SignableNostrEvent, rhs: SignableNostrEvent) -> Bool {
        lhs.createdAt == rhs.createdAt &&
        lhs.kind == rhs.kind &&
        lhs.tags == rhs.tags &&
        lhs.content == rhs.content
    }

    let createdAt: Int64

    /// The event kind.
    let kind: EventKind

    /// List of ``Tag`` objects.
    let tags: [Tag]

    /// Arbitrary string.
    let content: String

    init(createdAt: Int64, kind: EventKind, tags: [Tag], content: String) {
        self.createdAt = createdAt
        self.kind = kind
        self.tags = tags
        self.content = content
    }

    private enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case kind
        case tags
        case content
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(createdAt)
        hasher.combine(kind)
        hasher.combine(tags)
        hasher.combine(content)
    }
}
