//
//  KeysTests.swift
//  
//
//  Created by Terry Yiu on 5/25/23.
//

@testable import NostrSDK
import XCTest

final class KeysTests: XCTestCase {

    private let publicKeyNpub = "npub1yjucvgzxnnasdwkw287h7374ccxtvcls733nr7a0q9qyvuf0hdrqnzajun"
    private let publicKeyHex = "24b98620469cfb06bace51fd7f47d5c60cb663f0f46331fbaf014046712fbb46"
    private let privateKeyNsec = "nsec1t6k4sx3q68dj2aegujrzls7ds6uzvxwuekmez9cgzn3y7v6fd3ysjwttch"
    private let privateKeyHex = "5ead581a20d1db257728e4862fc3cd86b82619dccdb791170814e24f33496c49"
    private let emptyString = ""

    func testPrivateKeyNsec() throws {
        let privateKey = try XCTUnwrap(PrivateKey(nsec: privateKeyNsec))
        XCTAssertEqual(privateKey.nsec, privateKeyNsec)
        XCTAssertEqual(privateKey.hex, privateKeyHex)
    }

    func testPrivateKeyHex() throws {
        let privateKey = try XCTUnwrap(PrivateKey(hex: privateKeyHex))
        XCTAssertEqual(privateKey.nsec, privateKeyNsec)
        XCTAssertEqual(privateKey.hex, privateKeyHex)
    }

    func testPublicKeyNpub() throws {
        let publicKey = try XCTUnwrap(PublicKey(npub: publicKeyNpub))
        XCTAssertEqual(publicKey.npub, publicKeyNpub)
        XCTAssertEqual(publicKey.hex, publicKeyHex)
    }

    func testPublicKeyHex() throws {
        let publicKey = try XCTUnwrap(PublicKey(hex: publicKeyHex))
        XCTAssertEqual(publicKey.npub, publicKeyNpub)
        XCTAssertEqual(publicKey.hex, publicKeyHex)
    }

    func testEmptyString() throws {
        let publicKeyHex = PublicKey(hex: emptyString)
        XCTAssertNil(publicKeyHex)

        let publicKeyNpub = PublicKey(npub: emptyString)
        XCTAssertNil(publicKeyNpub)

        let privateKeyHex = PrivateKey(hex: emptyString)
        XCTAssertNil(privateKeyHex)

        let privateKeyNsec = PrivateKey(nsec: emptyString)
        XCTAssertNil(privateKeyNsec)
    }

    func testKeypair() throws {
        let keypair = try XCTUnwrap(Keypair(nsec: privateKeyNsec))

        XCTAssertEqual(keypair.privateKey.nsec, privateKeyNsec)
        XCTAssertEqual(keypair.privateKey.hex, privateKeyHex)
        XCTAssertEqual(keypair.publicKey.npub, publicKeyNpub)
        XCTAssertEqual(keypair.publicKey.hex, publicKeyHex)

        // Sanity check that creating a new keypair yields keys in the correct length.
        let newKeypair = try XCTUnwrap(Keypair())
        XCTAssertEqual(newKeypair.privateKey.hex.count, privateKeyHex.count)
        XCTAssertEqual(newKeypair.privateKey.nsec.count, privateKeyNsec.count)
        XCTAssertEqual(newKeypair.publicKey.hex.count, publicKeyHex.count)
        XCTAssertEqual(newKeypair.publicKey.npub.count, publicKeyNpub.count)
    }
}
