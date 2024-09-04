//
//  SealEventTests.swift
//  
//
//  Created by Terry Yiu on 5/17/24.
//

@testable import NostrSDK
import XCTest

final class SealEventTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading, NIP44v2Encrypting {

    static let author = Keypair(hex: "0beebd062ec8735f4243466049d7747ef5d6594ee838de147f8aab842b15e273")!
    static let recipient = Keypair(hex: "e108399bd8424357a710b606ae0c13166d853d327e47a6e5e038197346bdbf45")!
    static let wrapper = Keypair(hex: "4f02eac59266002db5801adc5270700ca69d5b8f761d8732fab2fbf233c90cbd")!

    func testCreateSealSucceeds() throws {
        let rumor: NostrEvent = try decodeFixture(filename: "rumor")

        let sealEvent = try seal(withRumor: rumor, toRecipient: SealEventTests.recipient.publicKey, signedBy: .test)
        try verifyEvent(sealEvent)

        let unsealedRumor = try sealEvent.unsealedRumor(using: SealEventTests.recipient.privateKey)

        XCTAssertEqual(rumor, unsealedRumor)
    }

    func testCreateSealFailsWithSignedEvent() throws {
        let signedEvent = try TextNoteEvent.Builder()
            .content("Are you going to the party tonight?")
            .build(signedBy: .test)
        XCTAssertThrowsError(try seal(withRumor: signedEvent, toRecipient: SealEventTests.recipient.publicKey, signedBy: .test))
    }

    func testDecodeSeal() throws {
        let sealEvent: SealEvent = try decodeFixture(filename: "seal")

        XCTAssertEqual(sealEvent.id, "28a87d7c074d94a58e9e89bb3e9e4e813e2189f285d797b1c56069d36f59eaa7")
        XCTAssertEqual(sealEvent.pubkey, SealEventTests.author.publicKey.hex)
        XCTAssertEqual(sealEvent.createdAt, 1703015180)
        XCTAssertEqual(sealEvent.kind, .seal)
        XCTAssertEqual(sealEvent.tags, [])
        XCTAssertEqual(sealEvent.signature, "02fc3facf6621196c32912b1ef53bac8f8bfe9db51c0e7102c073103586b0d29c3f39bdaa1e62856c20e90b6c7cc5dc34ca8bb6a528872cf6e65e6284519ad73")
        XCTAssertEqual(sealEvent.content, "AqBCdwoS7/tPK+QGkPCadJTn8FxGkd24iApo3BR9/M0uw6n4RFAFSPAKKMgkzVMoRyR3ZS/aqATDFvoZJOkE9cPG/TAzmyZvr/WUIS8kLmuI1dCA+itFF6+ULZqbkWS0YcVU0j6UDvMBvVlGTzHz+UHzWYJLUq2LnlynJtFap5k8560+tBGtxi9Gx2NIycKgbOUv0gEqhfVzAwvg1IhTltfSwOeZXvDvd40rozONRxwq8hjKy+4DbfrO0iRtlT7G/eVEO9aJJnqagomFSkqCscttf/o6VeT2+A9JhcSxLmjcKFG3FEK3Try/WkarJa1jM3lMRQqVOZrzHAaLFW/5sXano6DqqC5ERD6CcVVsrny0tYN4iHHB8BHJ9zvjff0NjLGG/v5Wsy31+BwZA8cUlfAZ0f5EYRo9/vKSd8TV0wRb9DQ=")

        try verifyEvent(sealEvent)

        // Ensure that no other private key can unseal the message.
        let randomKeypair = try XCTUnwrap(Keypair())
        XCTAssertThrowsError(try sealEvent.unsealedRumor(using: randomKeypair.privateKey))

        // Ensure that if the author is not the recipient, the author cannot unseal the message either.
        XCTAssertThrowsError(try sealEvent.unsealedRumor(using: SealEventTests.author.privateKey))

        let unsealedRumor = try XCTUnwrap(sealEvent.unsealedRumor(using: SealEventTests.recipient.privateKey))
        XCTAssertEqual(unsealedRumor.id, "9dd003c6d3b73b74a85a9ab099469ce251653a7af76f523671ab828acd2a0ef9")
        XCTAssertEqual(unsealedRumor.pubkey, SealEventTests.author.publicKey.hex)
        XCTAssertEqual(unsealedRumor.createdAt, 1691518405)
        XCTAssertEqual(unsealedRumor.kind, .textNote)
        XCTAssertEqual(unsealedRumor.tags, [])
        XCTAssertNil(unsealedRumor.signature)
        XCTAssertTrue(unsealedRumor.isRumor)
        XCTAssertEqual(unsealedRumor.content, "Are you going to the party tonight?")
    }

}
