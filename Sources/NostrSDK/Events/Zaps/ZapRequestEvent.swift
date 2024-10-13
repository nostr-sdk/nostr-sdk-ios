//
//  ZapRequestEvent.swift
//  NostrSDK
//
//  Created by Terry Yiu on 10/8/24.
//

import Foundation

public final class ZapRequestEvent: NostrEvent {

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
}

public extension ZapRequestEvent {
    /// Builder of a ``ZapRequestEvent``.
    final class Builder: NostrEvent.Builder<ZapRequestEvent>, RelayURLValidating {

        public init() {
            super.init(kind: .zapRequest)
        }

        @discardableResult
        public final func relays(_ relayURLs: [URL]) throws -> Builder {
            let validatedRelayURLStrings = try relayURLs.map { try validateRelayURL($0).absoluteString }

            guard let firstRelayURLString = validatedRelayURLStrings.first else {
                throw EventCreatingError.invalidInput
            }

            let tag = Tag(name: "relays", value: firstRelayURLString, otherParameters: Array(validatedRelayURLStrings[1...]))
            return appendTags(tag)
        }

        @discardableResult
        public final func amount(_ amount: String) throws -> Builder {
            guard amount.count < 19 || (amount.count == 19 && amount <= "2100000000000000000"),
                  amount.allSatisfy({ $0.isLatinDigit }),
                  let int64Amount = Int64(amount) else {
                throw EventCreatingError.invalidInput
            }

            return appendTags(Tag(name: "amount", value: amount))
        }

        @discardableResult
        public final func lnurl(_ encodedRecipientLNURLPayURL: String) -> Builder {
            return appendTags(Tag(name: "lnurl", value: encodedRecipientLNURLPayURL))
        }

        @discardableResult
        public final func pubkey(_ pubkey: String) -> Builder {
            return appendTags(.pubkey(pubkey))
        }

        @discardableResult
        public final func pubkey(_ pubkey: PublicKey) -> Builder {
            return appendTags(.pubkey(pubkey.hex))
        }

        @discardableResult
        public final func event(_ eventId: String) -> Builder {
            return appendTags(.event(eventId))
        }

        @discardableResult
        public final func event(_ event: NostrEvent) -> Builder {
            return appendTags(.event(event.id))
        }

        @discardableResult
        public final func addressableEvent(_ eventCoordinates: EventCoordinates) -> Builder {
            return appendTags(eventCoordinates.tag)
        }
    }
}

private extension Character {
    var isLatinDigit: Bool {
        let range: ClosedRange<Character> = "0"..."9"
        return range.contains(self)
    }
}
