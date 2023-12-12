//
//  Bech32Tests.swift
//
//  Copied and modified by Terry Yiu on 5/24/23 from https://github.com/0xDEADP00L/Bech32/blob/master/Tests/Bech32Tests/Bech32Tests.swift under MIT license
//  Created by Evolution Group Ltd on 12.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

//  Base32 address format for native v0-16 witness outputs implementation
//  https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki
//  Inspired by Pieter Wuille C++ implementation

import XCTest
@testable import NostrSDK

private typealias InvalidChecksum = (bech32: String, error: Bech32.DecodingError)
private typealias ValidAddressData = (address: String, script: [UInt8])
private typealias InvalidAddressData = (hrp: String, version: Int, programLen: Int)

class Bech32Tests: XCTestCase {

    private let _validChecksum: [String] = [
        "A12UEL5L",
        "an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs",
        // Montz: The length limit of 90 characters is for bitcoin and must be removed for Nostr identifiers, which can be longer. Therefore this test case was moved from invalid to valid.
        "an84characterslonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1569pvx",
        /////////
        "abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw",
        "11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j",
        "split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w",
        "?1ezyfcl"
    ]

    private let _invalidChecksum: [InvalidChecksum] = [
        (" 1nwldj5", Bech32.DecodingError.nonPrintableCharacter),
        ("\u{7f}1axkwrx", Bech32.DecodingError.nonPrintableCharacter),
        ("pzry9x0s0muk", Bech32.DecodingError.noChecksumMarker),
        ("1pzry9x0s0muk", Bech32.DecodingError.incorrectHrpSize),
        ("x1b4n0q5v", Bech32.DecodingError.invalidCharacter),
        ("li1dgmt3", Bech32.DecodingError.incorrectChecksumSize),
        ("de1lg7wt\u{ff}", Bech32.DecodingError.nonPrintableCharacter),
        ("10a06t8", Bech32.DecodingError.incorrectHrpSize),
        ("1qzzfhee", Bech32.DecodingError.incorrectHrpSize)
    ]

    private let _invalidAddress: [String] = [
        "tc1qw508d6qejxtdg4y5r3zarvary0c5xw7kg3g4ty",
        "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t5",
        "BC13W508D6QEJXTDG4Y5R3ZARVARY0C5XW7KN40WF2",
        "bc1rw5uspcuh",
        "bc10w508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7kw5rljs90",
        "BC1QR508D6QEJXTDG4Y5R3ZARVARYV98GJ9P",
        "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sL5k7",
        "bc1zw508d6qejxtdg4y5r3zarvaryvqyzf3du",
        "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3pjxtptv",
        "bc1gmk9yu"
    ]

    private let _validAddressData: [ValidAddressData] = [
        ("BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4", [
            0x00, 0x14, 0x75, 0x1e, 0x76, 0xe8, 0x19, 0x91, 0x96, 0xd4, 0x54,
            0x94, 0x1c, 0x45, 0xd1, 0xb3, 0xa3, 0x23, 0xf1, 0x43, 0x3b, 0xd6
            ]),
        ("tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7", [
            0x00, 0x20, 0x18, 0x63, 0x14, 0x3c, 0x14, 0xc5, 0x16, 0x68, 0x04,
            0xbd, 0x19, 0x20, 0x33, 0x56, 0xda, 0x13, 0x6c, 0x98, 0x56, 0x78,
            0xcd, 0x4d, 0x27, 0xa1, 0xb8, 0xc6, 0x32, 0x96, 0x04, 0x90, 0x32,
            0x62
            ]),
        ("bc1pw508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7k7grplx", [
            0x81, 0x28, 0x75, 0x1e, 0x76, 0xe8, 0x19, 0x91, 0x96, 0xd4, 0x54,
            0x94, 0x1c, 0x45, 0xd1, 0xb3, 0xa3, 0x23, 0xf1, 0x43, 0x3b, 0xd6,
            0x75, 0x1e, 0x76, 0xe8, 0x19, 0x91, 0x96, 0xd4, 0x54, 0x94, 0x1c,
            0x45, 0xd1, 0xb3, 0xa3, 0x23, 0xf1, 0x43, 0x3b, 0xd6
            ]),
        ("BC1SW50QA3JX3S", [
            0x90, 0x02, 0x75, 0x1e
            ]),
        ("bc1zw508d6qejxtdg4y5r3zarvaryvg6kdaj", [
            0x82, 0x10, 0x75, 0x1e, 0x76, 0xe8, 0x19, 0x91, 0x96, 0xd4, 0x54,
            0x94, 0x1c, 0x45, 0xd1, 0xb3, 0xa3, 0x23
            ]),
        ("tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy", [
            0x00, 0x20, 0x00, 0x00, 0x00, 0xc4, 0xa5, 0xca, 0xd4, 0x62, 0x21,
            0xb2, 0xa1, 0x87, 0x90, 0x5e, 0x52, 0x66, 0x36, 0x2b, 0x99, 0xd5,
            0xe9, 0x1c, 0x6c, 0xe2, 0x4d, 0x16, 0x5d, 0xab, 0x93, 0xe8, 0x64,
            0x33
            ])
    ]

    private let _invalidAddressData: [InvalidAddressData] = [
        ("BC", 0, 20),
        ("bc", 0, 21),
        ("bc", 17, 32),
        ("bc", 1, 1),
        ("bc", 16, 41)
    ]

    func testValidChecksum() {
        for valid in _validChecksum {
            do {
                let decoded = try Bech32.decode(valid)
                XCTAssertFalse(decoded.hrp.isEmpty, "Empty result for \"\(valid)\"")
                let checksumBase8 = try XCTUnwrap(decoded.checksum.base8FromBase5)
                let recoded = Bech32.encode(decoded.hrp, baseEightData: checksumBase8)
                XCTAssert(valid.lowercased() == recoded.lowercased(), "Roundtrip encoding failed: \(valid) != \(recoded)")
            } catch {
                XCTFail("Error decoding \(valid): \(error.localizedDescription)")
            }
        }
    }

    func testInvalidChecksum() {
        for invalid in _invalidChecksum {
            let checksum = invalid.bech32
            let reason = invalid.error
            do {
                let decoded = try Bech32.decode(checksum)
                XCTFail("Successfully decoded an invalid checksum \(checksum): \(decoded.checksum.hexString)")
            } catch let error as Bech32.DecodingError {
                XCTAssert(errorsEqual(error, reason), "Decoding error mismatch, got \(error.localizedDescription), expected \(reason.localizedDescription)")
            } catch {
                XCTFail("Invalid error occurred: \(error.localizedDescription)")
            }
        }
    }

    private func errorsEqual(_ lhs: Bech32.DecodingError, _ rhs: Bech32.DecodingError) -> Bool {
        switch (lhs, rhs) {
        case (.checksumMismatch, .checksumMismatch),
            (.incorrectChecksumSize, .incorrectChecksumSize),
            (.incorrectHrpSize, .incorrectHrpSize),
            (.invalidCase, .invalidCase),
            (.invalidCharacter, .invalidCharacter),
            (.noChecksumMarker, .noChecksumMarker),
            (.nonUTF8String, .nonUTF8String),
            (.stringLengthExceeded, .stringLengthExceeded),
            (.nonPrintableCharacter, .nonPrintableCharacter):
            return true
        default:
            return false
        }
    }
}
