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
    required init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    required init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), pubkey: String) {
        super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, pubkey: pubkey)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(id: String, pubkey: String, createdAt: Int64, kind: EventKind, tags: [Tag], content: String, signature: String?) {
        super.init(id: id, pubkey: pubkey, createdAt: createdAt, kind: kind, tags: tags, content: content, signature: signature)
    }

    public init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .report, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    /// The reason that the event or user was reported.
    public var reportType: ReportType? {
        guard let tag = tags.first(where: { $0.name == TagName.event.rawValue }) ?? tags.first(where: { $0.name == TagName.pubkey.rawValue }),
              let reportString = tag.otherParameters.first else {
            return nil
        }
        return ReportType(rawValue: reportString)
    }
}

public extension EventCreating {

    /// Creates a ``ReportEvent`` (kind 1984) which reports a user for spam, illegal and explicit content.
    /// - Parameters:
    ///   - pubkey: The pubkey being reported.
    ///   - reportType: The type (or reason) for the reporting. See ``ReportType``.
    ///   - additionalInformation: Additional information submitted by the entity reporting the content.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``ReportEvent``.
    func reportUser(withPublicKey pubkey: PublicKey, reportType: ReportType, additionalInformation: String = "", signedBy keypair: Keypair) throws -> ReportEvent {
        try ReportEvent(content: additionalInformation,
                        tags: [.pubkey(pubkey.hex, otherParameters: [reportType.rawValue])],
                        signedBy: keypair)
    }

    /// Creates a ``ReportEvent`` (kind 1984) which reports other notes for spam, illegal and explicit content.
    /// - Parameters:
    ///   - note: The note being reported.
    ///   - reportType: The type (or reason) for the reporting. See ``ReportType``.
    ///   - additionalInformation: Additional information submitted by the entity reporting the content.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``ReportEvent``.
    func reportNote(_ note: NostrEvent, reportType: ReportType, additionalInformation: String = "", signedBy keypair: Keypair) throws -> ReportEvent {
        guard reportType != .impersonation else {
            throw EventCreatingError.invalidInput
        }
        let tags: [Tag] = [
            .event(note.id, otherParameters: [reportType.rawValue]),
            .pubkey(note.pubkey)
        ]
        return try ReportEvent(content: additionalInformation, tags: tags, signedBy: keypair)
    }
}
