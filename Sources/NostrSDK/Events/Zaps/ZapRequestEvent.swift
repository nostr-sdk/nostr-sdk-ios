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

    public var relays: [URL] {
        guard let relaysTag = firstTagForRawTagName("relays") else {
            return []
        }

        return ([relaysTag.value] + relaysTag.otherParameters).compactMap { try? validateRelayURLString($0) }
    }

    public var amount: Int64? {
        guard let amountString = firstValueForRawTagName("amount"),
              amountString.count < 19 || (amountString.count == 19 && amountString <= "2100000000000000000"),
              amountString.allSatisfy({ $0.isLatinDigit }) else {
            return nil
        }

        return Int64(amountString)
    }

    public var lnurl: String? {
        firstValueForRawTagName("lnurl")
    }

    public var referencedPubkey: String? {
        firstValueForTagName(.pubkey)
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

        /// The amount of millisats the sender intends to pay.
        @discardableResult
        public final func amount(_ amount: Int64) throws -> Builder {
            return appendTags(Tag(name: "amount", value: String(amount)))
        }

        /// The lnurl pay url of the recipient, encoded using bech32 with the prefix lnurl.
        @discardableResult
        public final func lnurl(_ encodedRecipientLNURLPayURL: String) throws -> Builder {
            guard encodedRecipientLNURLPayURL.starts(with: "lnurl") else {
                throw EventCreatingError.invalidInput
            }
            return appendTags(Tag(name: "lnurl", value: encodedRecipientLNURLPayURL))
        }

        /// The pubkey of the recipient.
        @discardableResult
        public final func pubkey(_ pubkey: String) -> Builder {
            return appendTags(.pubkey(pubkey))
        }

        /// The pubkey of the recipient.
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

public struct ZapRequestResponse: Codable {
    /// The invoice the sender must pay to finalize their zap.
    let pr: String?
}

public protocol ZapRequestRequesting {}
public extension ZapRequestRequesting {
    func zapRequestResponse(for url: URL, zapRequestEvent: ZapRequestEvent, lnurl: String? = nil, dataRequester: DataRequesting = URLSession.shared) async throws -> ZapRequestResponse? {
        guard let amount = zapRequestEvent.amount,
              let zapRequestJSON = try? JSONEncoder().encode(zapRequestEvent),
              let lnurl = zapRequestEvent.lnurl ?? lnurl,
              let urlWithQueryParameters = URL(string: "\(url.absoluteString)?amount=\(amount)&nostr=\(zapRequestJSON)&lnurl=\(lnurl)") else {
            return nil
        }

        let (data, _) = try await dataRequester.data(from: urlWithQueryParameters, delegate: nil)
        return try JSONDecoder().decode(ZapRequestResponse.self, from: data)
    }
}

private extension Character {
    var isLatinDigit: Bool {
        let range: ClosedRange<Character> = "0"..."9"
        return range.contains(self)
    }
}
