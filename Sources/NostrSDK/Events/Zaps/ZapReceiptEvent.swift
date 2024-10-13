//
//  ZapReceiptEvent.swift
//  NostrSDK
//
//  Created by Terry Yiu on 10/8/24.
//

import CryptoKit
import Foundation

public final class ZapReceiptEvent: NostrEvent {

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

    public var recipientPubkey: String? {
        firstValueForTagName(.pubkey)
    }

    public var recipientEventId: String? {
        firstValueForTagName(.event)
    }

    public var recipientEventCoordinates: EventCoordinates? {
        referencedEventCoordinates.first
    }

    public var senderPubkey: String? {
        firstValueForRawTagName("P")
    }

    public var bolt11Invoice: String? {
        firstValueForRawTagName("bolt11")
    }

    public var description: String? {
        firstValueForRawTagName("description")
    }

    public var preimage: String? {
        firstValueForRawTagName("preimage")
    }
}

public extension ZapReceiptEvent {
    /// Builder of a ``ZapReceiptEvent``.
    final class Builder: NostrEvent.Builder<ZapReceiptEvent>, RelayURLValidating {

        public init() {
            super.init(kind: .zapReceipt)
        }
    }
}

public enum ZapReceiptVerifyingError: Error, CustomStringConvertible {
    case invalidZapReceipt

    public var description: String {
        switch self {
        case .invalidZapReceipt: return "The zap receipt is invalid."
        }
    }
}

public protocol ZapReceiptVerifying {}
public extension ZapReceiptVerifying {
    func verify(zapReceiptEvent: ZapReceiptEvent) {
        guard let description = zapReceiptEvent.description else {
            throw ZapReceiptVerifyingError.invalidZapReceipt
        }
        SHA256().update(data: <#T##DataProtocol#>)
    }
}
