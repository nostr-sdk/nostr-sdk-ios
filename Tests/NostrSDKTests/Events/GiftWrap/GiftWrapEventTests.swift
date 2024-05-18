//
//  GiftWrapEventTests.swift
//  
//
//  Created by Terry Yiu on 5/15/24.
//

@testable import NostrSDK
import XCTest

final class GiftWrapEventTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading {

    static let author = Keypair(hex: "0beebd062ec8735f4243466049d7747ef5d6594ee838de147f8aab842b15e273")!
    static let recipient = Keypair(hex: "e108399bd8424357a710b606ae0c13166d853d327e47a6e5e038197346bdbf45")!
    static let wrapper = Keypair(hex: "4f02eac59266002db5801adc5270700ca69d5b8f761d8732fab2fbf233c90cbd")!

    func testCreateGiftWrapSucceeds() throws {
        let rumor: NostrEvent = try decodeFixture(filename: "rumor")

        let giftWrapEvent = try giftWrap(withRumor: rumor, toRecipient: GiftWrapEventTests.recipient.publicKey, signedBy: .test)
        try verifyEvent(giftWrapEvent)

        let unsealedRumor = try giftWrapEvent.unseal(privateKey: GiftWrapEventTests.recipient.privateKey)

        XCTAssertEqual(rumor, unsealedRumor)
    }

    func testCreateGiftWrapFailsWithSignedEvent() throws {
        let signedEvent = try textNote(withContent: "Are you going to the party tonight?", signedBy: .test)
        XCTAssertThrowsError(try giftWrap(withRumor: signedEvent, toRecipient: GiftWrapEventTests.recipient.publicKey, signedBy: .test))
    }

    func testDecodeGiftWrap() throws {
        let giftWrapEvent: GiftWrapEvent = try decodeFixture(filename: "gift_wrap")

        XCTAssertEqual(giftWrapEvent.id, "5c005f3ccf01950aa8d131203248544fb1e41a0d698e846bd419cec3890903ac")
        XCTAssertEqual(giftWrapEvent.pubkey, GiftWrapEventTests.wrapper.publicKey.hex)
        XCTAssertEqual(giftWrapEvent.createdAt, 1703021488)
        XCTAssertEqual(giftWrapEvent.kind, .giftWrap)
        XCTAssertEqual(giftWrapEvent.tags, [Tag(name: .pubkey, value: "166bf3765ebd1fc55decfe395beff2ea3b2a4e0a8946e7eb578512b555737c99")])
        XCTAssertEqual(giftWrapEvent.signature, "35fabdae4634eb630880a1896a886e40fd6ea8a60958e30b89b33a93e6235df750097b04f9e13053764251b8bc5dd7e8e0794a3426a90b6bcc7e5ff660f54259")
        XCTAssertEqual(giftWrapEvent.content, "AhC3Qj/QsKJFWuf6xroiYip+2yK95qPwJjVvFujhzSguJWb/6TlPpBW0CGFwfufCs2Zyb0JeuLmZhNlnqecAAalC4ZCugB+I9ViA5pxLyFfQjs1lcE6KdX3euCHBLAnE9GL/+IzdV9vZnfJH6atVjvBkNPNzxU+OLCHO/DAPmzmMVx0SR63frRTCz6Cuth40D+VzluKu1/Fg2Q1LSst65DE7o2efTtZ4Z9j15rQAOZfE9jwMCQZt27rBBK3yVwqVEriFpg2mHXc1DDwHhDADO8eiyOTWF1ghDds/DxhMcjkIi/o+FS3gG1dG7gJHu3KkGK5UXpmgyFKt+421m5o++RMD/BylS3iazS1S93IzTLeGfMCk+7IKxuSCO06k1+DaasJJe8RE4/rmismUvwrHu/HDutZWkvOAhd4z4khZo7bJLtiCzZCZ74lZcjOB4CYtuAX2ZGpc4I1iOKkvwTuQy9BWYpkzGg3ZoSWRD6ty7U+KN+fTTmIS4CelhBTT15QVqD02JxfLF7nA6sg3UlYgtiGw61oH68lSbx16P3vwSeQQpEB5JbhofW7t9TLZIbIW/ODnI4hpwj8didtk7IMBI3Ra3uUP7ya6vptkd9TwQkd/7cOFaSJmU+BIsLpOXbirJACMn+URoDXhuEtiO6xirNtrPN8jYqpwvMUm5lMMVzGT3kMMVNBqgbj8Ln8VmqouK0DR+gRyNb8fHT0BFPwsHxDskFk5yhe5c/2VUUoKCGe0kfCcX/EsHbJLUUtlHXmTqaOJpmQnW1tZ/siPwKRl6oEsIJWTUYxPQmrM2fUpYZCuAo/29lTLHiHMlTbarFOd6J/ybIbICy2gRRH/LFSryty3Cnf6aae+A9uizFBUdCwTwffc3vCBae802+R92OL78bbqHKPbSZOXNC+6ybqziezwG+OPWHx1Qk39RYaF0aFsM4uZWrFic97WwVrH5i+/Nsf/OtwWiuH0gV/SqvN1hnkxCTF/+XNn/laWKmS3e7wFzBsG8+qwqwmO9aVbDVMhOmeUXRMkxcj4QreQkHxLkCx97euZpC7xhvYnCHarHTDeD6nVK+xzbPNtzeGzNpYoiMqxZ9bBJwMaHnEoI944Vxoodf51cMIIwpTmmRvAzI1QgrfnOLOUS7uUjQ/IZ1Qa3lY08Nqm9MAGxZ2Ou6R0/Z5z30ha/Q71q6meAs3uHQcpSuRaQeV29IASmye2A2Nif+lmbhV7w8hjFYoaLCRsdchiVyNjOEM4VmxUhX4VEvw6KoCAZ/XvO2eBF/SyNU3Of4SO")

        try verifyEvent(giftWrapEvent)

        // Ensure that no other private key can unseal the message.
        let randomKeypair = try XCTUnwrap(Keypair())
        XCTAssertThrowsError(try giftWrapEvent.unseal(privateKey: randomKeypair.privateKey))

        // Ensure that if the author is not the recipient, the author cannot unseal the message either.
        XCTAssertThrowsError(try giftWrapEvent.unseal(privateKey: GiftWrapEventTests.author.privateKey))

        let unsealedRumor = try XCTUnwrap(giftWrapEvent.unseal(privateKey: GiftWrapEventTests.recipient.privateKey))
        XCTAssertEqual(unsealedRumor.id, "9dd003c6d3b73b74a85a9ab099469ce251653a7af76f523671ab828acd2a0ef9")
        XCTAssertEqual(unsealedRumor.pubkey, GiftWrapEventTests.author.publicKey.hex)
        XCTAssertEqual(unsealedRumor.createdAt, 1691518405)
        XCTAssertEqual(unsealedRumor.kind, .textNote)
        XCTAssertEqual(unsealedRumor.tags, [])
        XCTAssertNil(unsealedRumor.signature)
        XCTAssertTrue(unsealedRumor.isRumor)
        XCTAssertEqual(unsealedRumor.content, "Are you going to the party tonight?")
    }
}
