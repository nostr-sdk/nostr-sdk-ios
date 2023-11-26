//
//  LongformContentEvent.swift
//
//
//  Created by Bryan Montz on 11/2/23.
//

import Foundation

public final class LongformContentEvent: NostrEvent {
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .longformContent, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    var publishedAt: Date? {
        guard let unixTimeString = tags.first(where: { $0.name == .publishedAt })?.value,
              let unixSeconds = TimeInterval(unixTimeString) else {
            return nil
        }
        return Date(timeIntervalSince1970: unixSeconds)
    }
    
    var identifier: String? {
        tags.first(where: { $0.name == .identifier})?.value
    }
    
    var title: String? {
        tags.first(where: { $0.name == .title })?.value
    }
    
    var summary: String? {
        tags.first(where: { $0.name == .summary })?.value
    }
    
    var imageURL: URL? {
        guard let imageURLString = tags.first(where: { $0.name == .image })?.value else {
            return nil
        }
        return URL(string: imageURLString)
    }
    
    var hashtags: [String] {
        tags.filter { $0.name == .hashtag }.map { $0.value }
    }
}
