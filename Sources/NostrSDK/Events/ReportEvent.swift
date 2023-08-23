//
//  ReportEvent.swift
//  
//
//  Created by Bryan Montz on 8/21/23.
//

import Foundation

public enum ReportType: String {
    /// depictions of nudity, porn, etc
    case nudity
    
    /// profanity, hateful speech, etc
    case profanity
    
    /// something which may be illegal in some jurisdiction
    case illegal
    
    /// spam
    case spam
    
    /// someone pretending to be someone else
    ///
    /// > Note: The `impersonation` ReportType only makes sense for profile reports.
    case impersonation
}

/// An event which reports a user or other notes for spam, illegal and explicit content.
///
/// See [NIP-56](https://github.com/nostr-protocol/nips/blob/b4cdc1a73d415c79c35655fa02f5e55cd1f2a60c/56.md#nip-56).
public final class ReportEvent: NostrEvent {
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    public init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .report, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    /// The reason that the event or user was reported.
    public var reportType: ReportType? {
        guard let tag = tags.first(where: { $0.name == .event }) ?? tags.first(where: { $0.name == .pubkey }),
              let reportString = tag.otherParameters.first else {
            return nil
        }
        return ReportType(rawValue: reportString)
    }
}
