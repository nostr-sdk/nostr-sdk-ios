[![Unit Tests](https://github.com/nostr-sdk/nostr-sdk-ios/actions/workflows/unit.yml/badge.svg)](https://github.com/nostr-sdk/nostr-sdk-ios/actions/workflows/unit.yml) [![SwiftLint](https://github.com/nostr-sdk/nostr-sdk-ios/actions/workflows/swiftlint.yml/badge.svg)](https://github.com/nostr-sdk/nostr-sdk-ios/actions/workflows/swiftlint.yml) [![Docs](https://github.com/nostr-sdk/nostr-sdk-ios/actions/workflows/docs.yml/badge.svg)](https://github.com/nostr-sdk/nostr-sdk-ios/actions/workflows/docs.yml)

# Nostr SDK for Apple Platforms

[Nostr](https://github.com/nostr-protocol/nostr) SDK library for Apple Platforms.

## Minimum Requirements

- Swift 5.7.1
- iOS 15
- macOS 12

## Features

TBD

## Spec Compliance

Nostr SDK iOS implements the following NIPs:

- [x] [NIP-01: Basic protocol flow description](https://github.com/nostr-protocol/nips/blob/master/01.md)
- [x] [NIP-02: Follow List](https://github.com/nostr-protocol/nips/blob/master/02.md)
- [ ] [NIP-03: OpenTimestamps Attestations for Events](https://github.com/nostr-protocol/nips/blob/master/03.md)
- [x] [NIP-04: Encrypted Direct Message](https://github.com/nostr-protocol/nips/blob/master/04.md) --- **unrecommended**: deprecated in favor of [NIP-44](https://github.com/nostr-protocol/nips/blob/master/44.md)
- [x] [NIP-05: Mapping Nostr keys to DNS-based internet identifiers](https://github.com/nostr-protocol/nips/blob/master/05.md)
- [ ] [NIP-06: Basic key derivation from mnemonic seed phrase](https://github.com/nostr-protocol/nips/blob/master/06.md)
- [ ] [NIP-07: `window.nostr` capability for web browsers](https://github.com/nostr-protocol/nips/blob/master/07.md)
- [ ] [NIP-08: Handling Mentions](https://github.com/nostr-protocol/nips/blob/master/08.md) --- **unrecommended**: deprecated in favor of [NIP-27](https://github.com/nostr-protocol/nips/blob/master/27.md)
- [ ] [NIP-09: Event Deletion](https://github.com/nostr-protocol/nips/blob/master/09.md)
- [x] [NIP-10: Conventions for clients' use of `e` and `p` tags in text events](https://github.com/nostr-protocol/nips/blob/master/10.md)
- [x] [NIP-11: Relay Information Document](https://github.com/nostr-protocol/nips/blob/master/11.md)
- [ ] [NIP-13: Proof of Work](https://github.com/nostr-protocol/nips/blob/master/13.md)
- [ ] [NIP-14: Subject tag in text events](https://github.com/nostr-protocol/nips/blob/master/14.md)
- [ ] [NIP-15: Nostr Marketplace (for resilient marketplaces)](https://github.com/nostr-protocol/nips/blob/master/15.md)
- [x] [NIP-18: Reposts](https://github.com/nostr-protocol/nips/blob/master/18.md)
- [ ] [NIP-19: bech32-encoded entities](https://github.com/nostr-protocol/nips/blob/master/19.md)
- [ ] [NIP-21: `nostr:` URI scheme](https://github.com/nostr-protocol/nips/blob/master/21.md)
- [x] [NIP-23: Long-form Content](https://github.com/nostr-protocol/nips/blob/master/23.md)
- [x] [NIP-24: Extra metadata fields and tags](https://github.com/nostr-protocol/nips/blob/master/24.md)
- [x] [NIP-25: Reactions](https://github.com/nostr-protocol/nips/blob/master/25.md)
- [ ] [NIP-26: Delegated Event Signing](https://github.com/nostr-protocol/nips/blob/master/26.md)
- [ ] [NIP-27: Text Note References](https://github.com/nostr-protocol/nips/blob/master/27.md)
- [ ] [NIP-28: Public Chat](https://github.com/nostr-protocol/nips/blob/master/28.md)
- [x] [NIP-30: Custom Emoji](https://github.com/nostr-protocol/nips/blob/master/30.md)
- [ ] [NIP-31: Dealing with Unknown Events](https://github.com/nostr-protocol/nips/blob/master/31.md)
- [ ] [NIP-32: Labeling](https://github.com/nostr-protocol/nips/blob/master/32.md)
- [ ] [NIP-36: Sensitive Content](https://github.com/nostr-protocol/nips/blob/master/36.md)
- [ ] [NIP-38: User Statuses](https://github.com/nostr-protocol/nips/blob/master/38.md)
- [ ] [NIP-39: External Identities in Profiles](https://github.com/nostr-protocol/nips/blob/master/39.md)
- [ ] [NIP-40: Expiration Timestamp](https://github.com/nostr-protocol/nips/blob/master/40.md)
- [ ] [NIP-42: Authentication of clients to relays](https://github.com/nostr-protocol/nips/blob/master/42.md)
- [ ] [NIP-44: Versioned Encryption](https://github.com/nostr-protocol/nips/blob/master/44.md)
- [ ] [NIP-45: Counting results](https://github.com/nostr-protocol/nips/blob/master/45.md)
- [ ] [NIP-46: Nostr Connect](https://github.com/nostr-protocol/nips/blob/master/46.md)
- [ ] [NIP-47: Wallet Connect](https://github.com/nostr-protocol/nips/blob/master/47.md)
- [ ] [NIP-48: Proxy Tags](https://github.com/nostr-protocol/nips/blob/master/48.md)
- [ ] [NIP-50: Search Capability](https://github.com/nostr-protocol/nips/blob/master/50.md)
- [ ] [NIP-51: Lists](https://github.com/nostr-protocol/nips/blob/master/51.md)
- [ ] [NIP-52: Calendar Events](https://github.com/nostr-protocol/nips/blob/master/52.md)
- [ ] [NIP-53: Live Activities](https://github.com/nostr-protocol/nips/blob/master/53.md)
- [x] [NIP-56: Reporting](https://github.com/nostr-protocol/nips/blob/master/56.md)
- [ ] [NIP-57: Lightning Zaps](https://github.com/nostr-protocol/nips/blob/master/57.md)
- [ ] [NIP-58: Badges](https://github.com/nostr-protocol/nips/blob/master/58.md)
- [ ] [NIP-65: Relay List Metadata](https://github.com/nostr-protocol/nips/blob/master/65.md)
- [ ] [NIP-72: Moderated Communities](https://github.com/nostr-protocol/nips/blob/master/72.md)
- [ ] [NIP-75: Zap Goals](https://github.com/nostr-protocol/nips/blob/master/75.md)
- [ ] [NIP-78: Application-specific data](https://github.com/nostr-protocol/nips/blob/master/78.md)
- [ ] [NIP-84: Highlights](https://github.com/nostr-protocol/nips/blob/master/84.md)
- [ ] [NIP-89: Recommended Application Handlers](https://github.com/nostr-protocol/nips/blob/master/89.md)
- [ ] [NIP-90: Data Vending Machines](https://github.com/nostr-protocol/nips/blob/master/90.md)
- [ ] [NIP-94: File Metadata](https://github.com/nostr-protocol/nips/blob/master/94.md)
- [ ] [NIP-98: HTTP Auth](https://github.com/nostr-protocol/nips/blob/master/98.md)
- [ ] [NIP-99: Classified Listings](https://github.com/nostr-protocol/nips/blob/master/99.md)

## Installation

TBD

## Contributing

If you would like to contribute to this library, please see [CONTRIBUTING.md](CONTRIBUTING.md).

## Contact

These are the core maintainers of this library and their Nostr public keys.

- [Bryan Montz](https://github.com/bryanmontz) ([npub1qlk0nqupxmlyxravg0aqscxmcc4q4tq898z6x003rykwwh3npj0syvyayc](https://njump.me/npub1qlk0nqupxmlyxravg0aqscxmcc4q4tq898z6x003rykwwh3npj0syvyayc))
- [Joel Klabo](https://github.com/joelklabo) ([npub19a86gzxctwtz68l8zld2u9y2fjvyyj4juyx8m5geylssrmfj27eqs22ckt](https://njump.me/npub19a86gzxctwtz68l8zld2u9y2fjvyyj4juyx8m5geylssrmfj27eqs22ckt))
- [Terry Yiu](https://github.com/tyiu) ([npub1yaul8k059377u9lsu67de7y637w4jtgeuwcmh5n7788l6xnlnrgs3tvjmf](https://njump.me/npub1yaul8k059377u9lsu67de7y637w4jtgeuwcmh5n7788l6xnlnrgs3tvjmf))
