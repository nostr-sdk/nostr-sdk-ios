//
//  MetadataCodingTests.swift
//
//
//  Created by Bryan Montz on 12/5/23.
//

import XCTest
@testable import NostrSDK

class MetadataCodingTests: XCTestCase, MetadataCoding {
    
    // MARK: - Decoding
    
    func testNprofileDecoding() throws {
        let input = "nprofile1qqsrhuxx8l9ex335q7he0f09aej04zpazpl0ne2cgukyawd24mayt8gpp4mhxue69uhhytnc9e3k7mgpz4mhxue69uhkg6nzv9ejuumpv34kytnrdaksjlyr9p"
        let (hrp, _) = try Bech32.decode(input)
        XCTAssertEqual(hrp, "nprofile")
        
        let result = try decodedMetadata(from: input)
        
        XCTAssertEqual(result.pubkey, "3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d")
        
        let expectedRelays = [
            "wss://r.x.com",
            "wss://djbas.sadkb.com"
        ]
        XCTAssertEqual(result.relays, expectedRelays)
    }
    
    func testNeventDecoding() throws {
        let input = "nevent1qqstna2yrezu5wghjvswqqculvvwxsrcvu7uc0f78gan4xqhvz49d9spr3mhxue69uhkummnw3ez6un9d3shjtn4de6x2argwghx6egpr4mhxue69uhkummnw3ez6ur4vgh8wetvd3hhyer9wghxuet5nxnepm"
        let (hrp, _) = try Bech32.decode(input)
        XCTAssertEqual(hrp, "nevent")
        
        let result = try decodedMetadata(from: input)
        XCTAssertEqual(result.eventId, "b9f5441e45ca39179320e0031cfb18e34078673dcc3d3e3a3b3a981760aa5696")
        
        let expectedRelays = [
            "wss://nostr-relay.untethr.me",
            "wss://nostr-pub.wellorder.net"
        ]
        XCTAssertEqual(result.relays, expectedRelays)
    }
    
    func testNrelayDecoding() throws {
        let id = "nrelay1qqt8wumn8ghj7un9d3shjtnwdaehgu3wvfskueq4r295t"
        let (hrp, _) = try Bech32.decode(id)
        XCTAssertEqual(hrp, "nrelay")
        
        let metadata = try decodedMetadata(from: id)
        
        XCTAssertEqual(metadata.relays, ["wss://relay.nostr.band"])
    }
    
    func testNaddrDecoding() throws {
        let id = "naddr1qqxnzdesxqmnxvpexqunzvpcqyt8wumn8ghj7un9d3shjtnwdaehgu3wvfskueqzypve7elhmamff3sr5mgxxms4a0rppkmhmn7504h96pfcdkpplvl2jqcyqqq823cnmhuld"
        let (hrp, _) = try Bech32.decode(id)
        XCTAssertEqual(hrp, "naddr")
        
        let metadata = try decodedMetadata(from: id)
        
        XCTAssertEqual(metadata.pubkey, "599f67f7df7694c603a6d0636e15ebc610db77dcfd47d6e5d05386d821fb3ea9")
        XCTAssertEqual(metadata.relays, ["wss://relay.nostr.band"])
        XCTAssertNil(metadata.eventId)
        XCTAssertEqual(metadata.identifier, "1700730909108")
        XCTAssertEqual(metadata.kind, 30023)
    }

    func testNpubPrefixDecoding() throws {
        let id = Keypair.test.publicKey.npub
        let (hrp, _) = try Bech32.decode(id)
        XCTAssertEqual(hrp, "npub")

        XCTAssertThrowsError(try decodedMetadata(from: id))
    }

    func testNsecPrefixDecoding() throws {
        let id = Keypair.test.privateKey.nsec
        let (hrp, _) = try Bech32.decode(id)
        XCTAssertEqual(hrp, "nsec")

        XCTAssertThrowsError(try decodedMetadata(from: id))
    }

    func testNotePrefixDecoding() throws {
        let id = "note1lf0dsn7ga6u4nlfe4k8yswyvlseswkv3a789qpjvlnk0myvthydshz7qeg"
        let (hrp, _) = try Bech32.decode(id)
        XCTAssertEqual(hrp, "note")

        XCTAssertThrowsError(try decodedMetadata(from: id))
    }

    func testIgnoreUnrecognizedType() throws {
        // start with the pubkey (type is "00", length is "20", the rest is the pubkey)
        var tlvString = "00203bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d"
        
        // append unrecognized TLV type (04)
        tlvString += "04080000000000000000"
        
        // append relay TLV (type is "01", length is "03", the rest is the relay in ASCII)
        tlvString += "010d7773733a2f2f722e782e636f6d"
        
        // make sure we can drop the unrecognized type and still get the relay after it
        
        let metadata = try decodedTLVString(tlvString, identifierType: .profile)
        
        XCTAssertEqual(metadata.pubkey, "3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d")
        XCTAssertEqual(metadata.relays, ["wss://r.x.com"])
    }
    
    // MARK: - Encoding
    
    func testRawTLVEncoding() throws {
        var metadata = Metadata()
        metadata.pubkey = "3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d"
        
        metadata.relays = [
            "wss://r.x.com",
            "wss://djbas.sadkb.com"
        ]
        
        let encoded = try tlvEncodedString(with: metadata, identifierType: .profile)
        
        var expectedTLVEncodedString = ""
        expectedTLVEncodedString.append("00203bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d") // pubkey
        expectedTLVEncodedString.append("010d7773733a2f2f722e782e636f6d") // relay 1
        expectedTLVEncodedString.append("01157773733a2f2f646a6261732e7361646b622e636f6d") // relay 2
        
        XCTAssertEqual(encoded, expectedTLVEncodedString)
    }
    
    func testNprofileEncoding() throws {
        var metadata = Metadata()
        metadata.pubkey = "3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d"
        
        metadata.relays = [
            "wss://r.x.com",
            "wss://djbas.sadkb.com"
        ]
        
        let identifier = try encodedIdentifier(with: metadata, identifierType: .profile)
        XCTAssertEqual(identifier, "nprofile1qqsrhuxx8l9ex335q7he0f09aej04zpazpl0ne2cgukyawd24mayt8gpp4mhxue69uhhytnc9e3k7mgpz4mhxue69uhkg6nzv9ejuumpv34kytnrdaksjlyr9p")
    }
    
    func testNeventEncoding() throws {
        var metadata = Metadata()
        metadata.eventId = "b9f5441e45ca39179320e0031cfb18e34078673dcc3d3e3a3b3a981760aa5696"
        metadata.relays = [
            "wss://nostr-relay.untethr.me",
            "wss://nostr-pub.wellorder.net"
        ]
        
        let identifier = try encodedIdentifier(with: metadata, identifierType: .event)
        let expected = "nevent1qqstna2yrezu5wghjvswqqculvvwxsrcvu7uc0f78gan4xqhvz49d9spr3mhxue69uhkummnw3ez6un9d3shjtn4de6x2argwghx6egpr4mhxue69uhkummnw3ez6ur4vgh8wetvd3hhyer9wghxuet5nxnepm"
        XCTAssertEqual(identifier, expected)
    }
    
    func testNrelayEncoding() throws {
        var metadata = Metadata()
        metadata.relays = ["wss://relay.nostr.band"]
        
        let identifier = try encodedIdentifier(with: metadata, identifierType: .relay)
        let expected = "nrelay1qqt8wumn8ghj7un9d3shjtnwdaehgu3wvfskueq4r295t"
        XCTAssertEqual(identifier, expected)
    }
    
    func testNaddrEncoding() throws {
        var metadata = Metadata()
        metadata.pubkey = "599f67f7df7694c603a6d0636e15ebc610db77dcfd47d6e5d05386d821fb3ea9"
        metadata.relays = ["wss://relay.nostr.band"]
        metadata.identifier = "1700730909108"
        metadata.kind = 30023
        
        let identifier = try encodedIdentifier(with: metadata, identifierType: .address)
        let expected = "naddr1qqxnzdesxqmnxvpexqunzvpcqyt8wumn8ghj7un9d3shjtnwdaehgu3wvfskueqzypve7elhmamff3sr5mgxxms4a0rppkmhmn7504h96pfcdkpplvl2jqcyqqq823cnmhuld"
        XCTAssertEqual(identifier, expected)
    }

    func testNpubEncoding() throws {
        var metadata = Metadata()
        metadata.pubkey = "3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d"

        metadata.relays = [
            "wss://r.x.com",
            "wss://djbas.sadkb.com"
        ]

        XCTAssertThrowsError(try encodedIdentifier(with: metadata, identifierType: .publicKey))
    }

    func testNsecEncoding() throws {
        var metadata = Metadata()
        metadata.pubkey = "3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d"

        metadata.relays = [
            "wss://r.x.com",
            "wss://djbas.sadkb.com"
        ]

        XCTAssertThrowsError(try encodedIdentifier(with: metadata, identifierType: .privateKey))
    }

    func testNoteEncoding() throws {
        var metadata = Metadata()
        metadata.eventId = "b9f5441e45ca39179320e0031cfb18e34078673dcc3d3e3a3b3a981760aa5696"
        metadata.relays = [
            "wss://nostr-relay.untethr.me",
            "wss://nostr-pub.wellorder.net"
        ]

        XCTAssertThrowsError(try encodedIdentifier(with: metadata, identifierType: .note))
    }
}
