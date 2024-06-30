//
//  Bech32IdentifierType.swift
//
//
//  Created by Terry Yiu on 6/30/24.
//

/// The type of Bech32-encoded identifier.
/// These identifiers can be used to succinctly encapsulate metadata to aid in the discovery of events and users.
/// See [NIP-19](https://github.com/nostr-protocol/nips/blob/master/19.md) for information about how these
/// identifiers are encoded and used.
public enum Bech32IdentifierType: String {
    case publicKey = "npub"
    case privateKey = "nsec"
    case note = "note"
    case profile = "nprofile"
    case event = "nevent"
    case relay = "nrelay"
    case address = "naddr"
}
