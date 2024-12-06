[![Unit Tests](https://github.com/nostr-sdk/nostr-sdk-ios/actions/workflows/unit.yml/badge.svg)](https://github.com/nostr-sdk/nostr-sdk-ios/actions/workflows/unit.yml) [![SwiftLint](https://github.com/nostr-sdk/nostr-sdk-ios/actions/workflows/swiftlint.yml/badge.svg)](https://github.com/nostr-sdk/nostr-sdk-ios/actions/workflows/swiftlint.yml) [![Docs](https://github.com/nostr-sdk/nostr-sdk-ios/actions/workflows/docs.yml/badge.svg)](https://github.com/nostr-sdk/nostr-sdk-ios/actions/workflows/docs.yml)

# Nostr SDK for Apple Platforms

Nostr SDK for Apple Platforms is a native Swift library that enables developers to quickly and easily build [Nostr](https://github.com/nostr-protocol/nostr)-based apps for Apple platforms.

## Minimum Requirements

- Swift 5.7
- iOS 15
- macOS 12

## Spec Compliance

The following [NIPs](https://github.com/nostr-protocol/nips) are implemented:

- [x] [NIP-01: Basic protocol flow description](https://github.com/nostr-protocol/nips/blob/master/01.md)
- [x] [NIP-02: Follow List](https://github.com/nostr-protocol/nips/blob/master/02.md)
- [ ] [NIP-03: OpenTimestamps Attestations for Events](https://github.com/nostr-protocol/nips/blob/master/03.md)
- [x] [NIP-04: Encrypted Direct Message](https://github.com/nostr-protocol/nips/blob/master/04.md) --- **unrecommended**: deprecated in favor of [NIP-17](https://github.com/nostr-protocol/nips/blob/master/17.md)
- [x] [NIP-05: Mapping Nostr keys to DNS-based internet identifiers](https://github.com/nostr-protocol/nips/blob/master/05.md)
- [ ] [NIP-06: Basic key derivation from mnemonic seed phrase](https://github.com/nostr-protocol/nips/blob/master/06.md)
- [ ] [NIP-07: `window.nostr` capability for web browsers](https://github.com/nostr-protocol/nips/blob/master/07.md)
- [ ] [NIP-08: Handling Mentions](https://github.com/nostr-protocol/nips/blob/master/08.md) --- **unrecommended**: deprecated in favor of [NIP-27](https://github.com/nostr-protocol/nips/blob/master/27.md)
- [x] [NIP-09: Event Deletion Request](https://github.com/nostr-protocol/nips/blob/master/09.md)
- [x] [NIP-10: Conventions for clients' use of `e` and `p` tags in text events](https://github.com/nostr-protocol/nips/blob/master/10.md)
- [x] [NIP-11: Relay Information Document](https://github.com/nostr-protocol/nips/blob/master/11.md)
- [ ] [NIP-13: Proof of Work](https://github.com/nostr-protocol/nips/blob/master/13.md)
- [x] [NIP-14: Subject tag in text events](https://github.com/nostr-protocol/nips/blob/master/14.md)
- [ ] [NIP-15: Nostr Marketplace (for resilient marketplaces)](https://github.com/nostr-protocol/nips/blob/master/15.md)
- [x] [NIP-17: Private Direct Messages](https://github.com/nostr-protocol/nips/blob/master/17.md)
- [x] [NIP-18: Reposts](https://github.com/nostr-protocol/nips/blob/master/18.md)
- [x] [NIP-19: bech32-encoded entities](https://github.com/nostr-protocol/nips/blob/master/19.md)
- [ ] [NIP-21: `nostr:` URI scheme](https://github.com/nostr-protocol/nips/blob/master/21.md)
- [ ] [NIP-22: Comment](https://github.com/nostr-protocol/nips/blob/master/22.md)
- [x] [NIP-23: Long-form Content](https://github.com/nostr-protocol/nips/blob/master/23.md)
- [x] [NIP-24: Extra metadata fields and tags](https://github.com/nostr-protocol/nips/blob/master/24.md)
- [x] [NIP-25: Reactions](https://github.com/nostr-protocol/nips/blob/master/25.md)
- [ ] [NIP-26: Delegated Event Signing](https://github.com/nostr-protocol/nips/blob/master/26.md)
- [ ] [NIP-27: Text Note References](https://github.com/nostr-protocol/nips/blob/master/27.md)
- [ ] [NIP-28: Public Chat](https://github.com/nostr-protocol/nips/blob/master/28.md)
- [ ] [NIP-29: Relay-based Groups](https://github.com/nostr-protocol/nips/blob/master/29.md)
- [x] [NIP-30: Custom Emoji](https://github.com/nostr-protocol/nips/blob/master/30.md)
- [x] [NIP-31: Dealing with Unknown Events](https://github.com/nostr-protocol/nips/blob/master/31.md)
- [x] [NIP-32: Labeling](https://github.com/nostr-protocol/nips/blob/master/32.md)
- [ ] [NIP-34: `git` stuff](https://github.com/nostr-protocol/nips/blob/master/34.md)
- [ ] [NIP-35: Torrents](https://github.com/nostr-protocol/nips/blob/master/35.md)
- [x] [NIP-36: Sensitive Content](https://github.com/nostr-protocol/nips/blob/master/36.md)
- [ ] [NIP-38: User Statuses](https://github.com/nostr-protocol/nips/blob/master/38.md)
- [ ] [NIP-39: External Identities in Profiles](https://github.com/nostr-protocol/nips/blob/master/39.md)
- [x] [NIP-40: Expiration Timestamp](https://github.com/nostr-protocol/nips/blob/master/40.md)
- [ ] [NIP-42: Authentication of clients to relays](https://github.com/nostr-protocol/nips/blob/master/42.md)
- [x] [NIP-44: Versioned Encryption](https://github.com/nostr-protocol/nips/blob/master/44.md)
- [ ] [NIP-45: Counting results](https://github.com/nostr-protocol/nips/blob/master/45.md)
- [ ] [NIP-46: Nostr Connect](https://github.com/nostr-protocol/nips/blob/master/46.md)
- [x] [NIP-47: Wallet Connect](https://github.com/nostr-protocol/nips/blob/master/47.md)
- [ ] [NIP-48: Proxy Tags](https://github.com/nostr-protocol/nips/blob/master/48.md)
- [ ] [NIP-49: Private Key Encryption](https://github.com/nostr-protocol/nips/blob/master/49.md)
- [ ] [NIP-50: Search Capability](https://github.com/nostr-protocol/nips/blob/master/50.md)
- [ ] [NIP-51: Lists](https://github.com/nostr-protocol/nips/blob/master/51.md)
- [x] [NIP-52: Calendar Events](https://github.com/nostr-protocol/nips/blob/master/52.md)
- [ ] [NIP-53: Live Activities](https://github.com/nostr-protocol/nips/blob/master/53.md)
- [ ] [NIP-54: Wiki](https://github.com/nostr-protocol/nips/blob/master/54.md)
- [ ] [NIP-55: Android Signer Application](https://github.com/nostr-protocol/nips/blob/master/55.md)
- [x] [NIP-56: Reporting](https://github.com/nostr-protocol/nips/blob/master/56.md)
- [ ] [NIP-57: Lightning Zaps](https://github.com/nostr-protocol/nips/blob/master/57.md)
- [ ] [NIP-58: Badges](https://github.com/nostr-protocol/nips/blob/master/58.md)
- [x] [NIP-59: Gift Wrap](https://github.com/nostr-protocol/nips/blob/master/59.md)
- [ ] [NIP-60: Cashu Wallet](https://github.com/nostr-protocol/nips/blob/master/60.md)
- [ ] [NIP-61: Nutzaps](https://github.com/nostr-protocol/nips/blob/master/61.md)
- [ ] [NIP-64: Chess (PGN)](https://github.com/nostr-protocol/nips/blob/master/64.md)
- [x] [NIP-65: Relay List Metadata](https://github.com/nostr-protocol/nips/blob/master/65.md)
- [ ] [NIP-69: Peer-to-peer Order events](https://github.com/nostr-protocol/nips/blob/master/69.md)
- [ ] [NIP-70: Protected Events](https://github.com/nostr-protocol/nips/blob/master/70.md)
- [ ] [NIP-71: Video Events](https://github.com/nostr-protocol/nips/blob/master/71.md)
- [ ] [NIP-72: Moderated Communities](https://github.com/nostr-protocol/nips/blob/master/72.md)
- [ ] [NIP-73: External Content IDs](https://github.com/nostr-protocol/nips/blob/master/73.md)
- [ ] [NIP-75: Zap Goals](https://github.com/nostr-protocol/nips/blob/master/75.md)
- [ ] [NIP-78: Application-specific data](https://github.com/nostr-protocol/nips/blob/master/78.md)
- [ ] [NIP-84: Highlights](https://github.com/nostr-protocol/nips/blob/master/84.md)
- [ ] [NIP-89: Recommended Application Handlers](https://github.com/nostr-protocol/nips/blob/master/89.md)
- [ ] [NIP-90: Data Vending Machines](https://github.com/nostr-protocol/nips/blob/master/90.md)
- [ ] [NIP-92: Media Attachments](https://github.com/nostr-protocol/nips/blob/master/92.md)
- [ ] [NIP-94: File Metadata](https://github.com/nostr-protocol/nips/blob/master/94.md)
- [ ] [NIP-96: HTTP File Storage Integration](https://github.com/nostr-protocol/nips/blob/master/96.md)
- [ ] [NIP-98: HTTP Auth](https://github.com/nostr-protocol/nips/blob/master/98.md)
- [ ] [NIP-99: Classified Listings](https://github.com/nostr-protocol/nips/blob/master/99.md)

## Installation

Nostr SDK can be integrated as an Xcode project target or a Swift package target.

[Releases](https://github.com/nostr-sdk/nostr-sdk-ios/releases) follow [semantic versioning](https://semver.org/).

### Xcode Project Target

1. Go to `File` -> `Add Package Dependencies`.
2. Type https://github.com/nostr-sdk/nostr-sdk-ios.git into the search field.
3. Select `nostr-sdk-ios` from the search results.
4. Select `Up to Next Major Version` starting from the latest release as the dependency rule.
5. Ensure your project is selected next to `Add to Project`.
6. Click `Add Package`.
7. On the package product dialog, add `NostrSDK` to your target and click `Add Package`.

### Swift Package Target

In your `Package.swift` file:
1. Add the NostrSDK package dependency to https://github.com/nostr-sdk/nostr-sdk-ios.git
2. Add `NostrSDK` as a dependency on the targets that need to use the SDK.

```swift
let package = Package(
	// ...
    dependencies: [
        // ...
        .package(url: "https://github.com/nostr-sdk/nostr-sdk-ios.git", .upToNextMajor(from: "0.2.0"))
    ],
    targets: [
        .target(
            // ...
            dependencies: ["NostrSDK"]
        ),
        .testTarget(
            // ...
            dependencies: ["NostrSDK"]
        )
    ]
)
```

## Contributing

If you would like to contribute to this library, please see [CONTRIBUTING.md](CONTRIBUTING.md).

## Contact

These are the core maintainers of this library and their Nostr public keys.

### Active Maintainers

- [Terry Yiu](https://github.com/tyiu) ([npub1yaul8k059377u9lsu67de7y637w4jtgeuwcmh5n7788l6xnlnrgs3tvjmf](https://njump.me/npub1yaul8k059377u9lsu67de7y637w4jtgeuwcmh5n7788l6xnlnrgs3tvjmf))

### Passive / Inactive Maintainers

- [Bryan Montz](https://github.com/bryanmontz) ([npub1qlk0nqupxmlyxravg0aqscxmcc4q4tq898z6x003rykwwh3npj0syvyayc](https://njump.me/npub1qlk0nqupxmlyxravg0aqscxmcc4q4tq898z6x003rykwwh3npj0syvyayc))
- [Joel Klabo](https://github.com/joelklabo) ([npub19a86gzxctwtz68l8zld2u9y2fjvyyj4juyx8m5geylssrmfj27eqs22ckt](https://njump.me/npub19a86gzxctwtz68l8zld2u9y2fjvyyj4juyx8m5geylssrmfj27eqs22ckt))

## Acknowledgements

- [OpenSats](https://opensats.org/blog/nostr-grants-july-2023) - Nostr Grant in July 2023
- [Swift-DocC Plugin](https://github.com/apple/swift-docc-plugin) - [Apache License 2.0, Apple Inc.](https://github.com/apple/swift-docc-plugin/blob/main/LICENSE.txt)
- [SymbolKit](https://github.com/apple/swift-docc-symbolkit) - [Apache License 2.0, Apple Inc.](https://github.com/apple/swift-docc-symbolkit/blob/main/LICENSE.txt)
- [secp256k1.swift](https://github.com/GigaBitcoin/secp256k1.swift) - [MIT License, Copyright (c) 2020 GigaBitcoin LLC](https://github.com/GigaBitcoin/secp256k1.swift/blob/main/LICENSE)
- [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift) - [Copyright (C) 2014-3099 Marcin Krzyżanowski](https://github.com/krzyzanowskim/CryptoSwift/blob/main/LICENSE)
- [Bech32](https://github.com/0xDEADP00L/Bech32/blob/master/Sources/Bech32.swift) - [MIT License, Copyright 2018 Evolution Group Limited](https://github.com/0xDEADP00L/Bech32/blob/master/LICENSE)
- [Nos Data+Encoding.swift](https://github.com/planetary-social/nos/blob/main/Nos/Extensions/Data%2BEncoding.swift) - [MIT License, Copyright 2024 © Verse Communications](https://njump.me/note1q39598qkdc093sdq4enudjf0dall76s7n779k07nutgd9r2zt6vq96l8c2)
