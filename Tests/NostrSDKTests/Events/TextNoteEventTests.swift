//
//  TextNoteEventTests.swift
//  
//
//  Created by Terry Yiu on 4/14/24.
//

@testable import NostrSDK
import XCTest

final class TextNoteEventTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading {

    func testCreateSignedTextNote() throws {
        let imageURLString = "https://nostrsdk.com/ostrich.png"
        let imageURL = try XCTUnwrap(URL(string: imageURLString))
        let customEmoji = try XCTUnwrap(CustomEmoji(shortcode: "ostrich", imageURL: imageURL))

        let note = try textNote(withContent: "Hello world! :ostrich:",
                                subject: "test-subject",
                                customEmojis: [customEmoji],
                                signedBy: Keypair.test)

        XCTAssertEqual(note.kind, .textNote)
        XCTAssertEqual(note.content, "Hello world! :ostrich:")
        XCTAssertEqual(note.subject, "test-subject")
        XCTAssertEqual(note.pubkey, Keypair.test.publicKey.hex)
        XCTAssertEqual(note.tags, [Tag(name: .emoji, value: "ostrich", otherParameters: [imageURLString]), Tag(name: .subject, value: "test-subject")])
        XCTAssertEqual(note.customEmojis, [customEmoji])

        try verifyEvent(note)
    }

    func testCreateTextNoteReply() throws {
        let noteToReply: TextNoteEvent = try decodeFixture(filename: "text_note")

        let relayURL = try XCTUnwrap(URL(string: "wss://relay.nostr.com"))
        let mentionedEventTag1 = try XCTUnwrap(EventTag(eventId: "mentionednote1", relayURL: relayURL, marker: .mention))
        let mentionedEventTag2 = try XCTUnwrap(EventTag(eventId: "mentionednote2", relayURL: relayURL, marker: .mention))
        let note = try textNote(withContent: "This is a reply to a note in a thread.", replyingTo: noteToReply, mentionedEventTags: [mentionedEventTag1, mentionedEventTag2], signedBy: Keypair.test)

        XCTAssertEqual(note.kind, .textNote)
        XCTAssertEqual(note.content, "This is a reply to a note in a thread.")
        XCTAssertEqual(note.pubkey, Keypair.test.publicKey.hex)

        let rootEventTag = try XCTUnwrap(noteToReply.rootEventTag)
        let expectedRootEventTag = try XCTUnwrap(EventTag(eventId: rootEventTag.eventId, relayURL: rootEventTag.relayURL, marker: .root))
        let replyEventTag = try XCTUnwrap(EventTag(eventId: noteToReply.id, marker: .reply))
        let expectedTags: [Tag] = [
            expectedRootEventTag.tag,
            mentionedEventTag1.tag,
            mentionedEventTag2.tag,
            replyEventTag.tag,
            .pubkey("f8e6c64342f1e052480630e27e1016dce35fc3a614e60434fef4aa2503328ca9"),
            .pubkey("82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2")

        ]
        XCTAssertEqual(note.tags, expectedTags)

        try verifyEvent(note)
    }

    func testDecodeTextNote() throws {

        let event: TextNoteEvent = try decodeFixture(filename: "text_note")

        XCTAssertEqual(event.id, "fa5ed84fc8eeb959fd39ad8e48388cfc33075991ef8e50064cfcecfd918bb91b")
        XCTAssertEqual(event.pubkey, "82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2")
        XCTAssertEqual(event.createdAt, 1682080184)
        XCTAssertEqual(event.kind, .textNote)

        let expectedTags: [Tag] = [
            .event("93930d65435d49db723499335473920795e7f13c45600dcfad922135cf44bd63"),
            .pubkey("f8e6c64342f1e052480630e27e1016dce35fc3a614e60434fef4aa2503328ca9")
        ]
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertEqual(event.content, "I think it stays persistent on your profile, but interface setting doesn’t persist. Bug.  ")
        XCTAssertEqual(event.signature, "96e6667348b2b1fc5f6e73e68fb1605f571ad044077dda62a35c15eb8290f2c4559935db461f8466df3dcf39bc2e11984c5344f65aabee4520dd6653d74cdc09")

        XCTAssertEqual(event.mentionedPubkeys, ["f8e6c64342f1e052480630e27e1016dce35fc3a614e60434fef4aa2503328ca9"])
        XCTAssertEqual(event.mentionedEventIds, ["93930d65435d49db723499335473920795e7f13c45600dcfad922135cf44bd63"])
    }

    func testDecodeTextNoteReply() throws {
        let event: TextNoteEvent = try decodeFixture(filename: "text_note_reply")

        XCTAssertEqual(event.id, "ce8944b22de84acecbde68ba736c75b6cca6e88f4b370e21038edf881a84a0a5")
        XCTAssertEqual(event.pubkey, "a8f3721a89fdb79a7e7c6e7b8134c720a408b6c24bf4262419cf54b160c527a6")
        XCTAssertEqual(event.createdAt, 1703828613)
        XCTAssertEqual(event.kind, .textNote)

        let expectedTags: [Tag] = [
            .event("a7823beaa8c9d4063bb554972fa5ba90112764231aed3d4d691199da3e5c6a03", otherParameters: ["", "root"]),
            .event("85f247a5d137652a720ca2a0a1f0c9933cf1be1e461432da765cf479de3d5950", otherParameters: ["", "mention"]),
            .event("c464c099740755440d0cac82b54c4dcd12faffa327ea4409ace221ae3e00deda", otherParameters: ["", "reply"]),
            .pubkey("a8f3721a89fdb79a7e7c6e7b8134c720a408b6c24bf4262419cf54b160c527a6", otherParameters: ["", "mention"])
        ]
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertEqual(event.content, "Reply 2 with fix with mention nostr:nevent1qqsgtuj85hgnwef2wgx29g9p7ryex083hc0yv9pjmfm9earemc74j5qpp4mhxue69uhkummn9ekx7mqzyz50xus6387m0xn703h8hqf5cus2gz9kcf9lgf3yr884fvtqc5n6vqcyqqqqqqg5vcwpa")
        XCTAssertEqual(event.signature, "e7d578bcd8d712a43f5c42cbeb76e6e4b09d6e0ab0a4bf0aacb7d7a7368d32e2ef0632d11e707b6d7e86b00460e7d5a6b5733c7b182a3d78b0e482c99a75b892")

        XCTAssertEqual(event.mentionedPubkeys, ["a8f3721a89fdb79a7e7c6e7b8134c720a408b6c24bf4262419cf54b160c527a6"])
        XCTAssertEqual(event.mentionedEventIds, ["a7823beaa8c9d4063bb554972fa5ba90112764231aed3d4d691199da3e5c6a03", "85f247a5d137652a720ca2a0a1f0c9933cf1be1e461432da765cf479de3d5950", "c464c099740755440d0cac82b54c4dcd12faffa327ea4409ace221ae3e00deda"])

        XCTAssertEqual(event.rootEventTag, try EventTag(eventId: "a7823beaa8c9d4063bb554972fa5ba90112764231aed3d4d691199da3e5c6a03", marker: .root))
        XCTAssertEqual(event.replyEventTag, try EventTag(eventId: "c464c099740755440d0cac82b54c4dcd12faffa327ea4409ace221ae3e00deda", marker: .reply))
        XCTAssertEqual(event.mentionedEventTags, [try EventTag(eventId: "85f247a5d137652a720ca2a0a1f0c9933cf1be1e461432da765cf479de3d5950", marker: .mention)])
    }

    func testDecodeTextNoteRootReply() throws {
        let event: TextNoteEvent = try decodeFixture(filename: "text_note_root_reply")

        XCTAssertEqual(event.id, "e93f47af92d844f27ea30c8a352e758d2b0a24028fa99319abff784a78bd572c")
        XCTAssertEqual(event.pubkey, "a8f3721a89fdb79a7e7c6e7b8134c720a408b6c24bf4262419cf54b160c527a6")
        XCTAssertEqual(event.createdAt, 1704157235)
        XCTAssertEqual(event.kind, .textNote)

        let expectedTags: [Tag] = [
            .event("a7823beaa8c9d4063bb554972fa5ba90112764231aed3d4d691199da3e5c6a03", otherParameters: ["", "root"]),
            .event("553d7c2d9e8baec4a0917312d35b12391b24fcef6417b15df288422e584e090d", otherParameters: ["", "mention"]),
            .pubkey("a8f3721a89fdb79a7e7c6e7b8134c720a408b6c24bf4262419cf54b160c527a6", otherParameters: ["", "mention"])
        ]
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertEqual(event.content, "Direct reply with mention nostr:nevent1qqs920tu9k0ghtky5zghxykntvfrjxeylnhkg9a3thegss3wtp8qjrgpp4mhxue69uhkummn9ekx7mqzyz50xus6387m0xn703h8hqf5cus2gz9kcf9lgf3yr884fvtqc5n6vqcyqqqqqqgwjgqyy")
        XCTAssertEqual(event.signature, "b2a33fbf571dc3056346bf4f28b620076a8152d6b419ae7b4c474350c7811325a5996d63e3520130d89f97ee73e92f94122a0bb478b9517eae5d8c22ffd77b7f")

        XCTAssertEqual(event.mentionedPubkeys, ["a8f3721a89fdb79a7e7c6e7b8134c720a408b6c24bf4262419cf54b160c527a6"])
        XCTAssertEqual(event.mentionedEventIds, ["a7823beaa8c9d4063bb554972fa5ba90112764231aed3d4d691199da3e5c6a03", "553d7c2d9e8baec4a0917312d35b12391b24fcef6417b15df288422e584e090d"])

        XCTAssertEqual(event.rootEventTag, try EventTag(eventId: "a7823beaa8c9d4063bb554972fa5ba90112764231aed3d4d691199da3e5c6a03", marker: .root))
        XCTAssertEqual(event.mentionedEventTags, [try EventTag(eventId: "553d7c2d9e8baec4a0917312d35b12391b24fcef6417b15df288422e584e090d", marker: .mention)])
    }

    func testDecodeTextNoteReplyDeprecatedPositionalTags() throws {
        let event: TextNoteEvent = try decodeFixture(filename: "text_note_reply_deprecated_positional_tags")

        XCTAssertEqual(event.id, "2e3325c6b0c983091390730bcfa8768ca2b5f5acbc4f7f187bc12d7a8c057201")
        XCTAssertEqual(event.pubkey, "a8f3721a89fdb79a7e7c6e7b8134c720a408b6c24bf4262419cf54b160c527a6")
        XCTAssertEqual(event.createdAt, 1704154322)
        XCTAssertEqual(event.kind, .textNote)

        let expectedTags: [Tag] = [
            .event("a7823beaa8c9d4063bb554972fa5ba90112764231aed3d4d691199da3e5c6a03"),
            .event("c464c099740755440d0cac82b54c4dcd12faffa327ea4409ace221ae3e00deda")
        ]
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertEqual(event.content, "Reply 2 with deprecated positional tags and mention\nnostr:note1257hctv73whvfgy3wvfdxkcj8ydjfl80vstmzh0j3ppzukzwpyxsc0hy03")
        XCTAssertEqual(event.signature, "a40b016c85d62a771793300c73494157dcb813eb25aa101b13e26beb987f521d80d1b1d2f026539107ecf861d60c98410063358adaaf5e45d1ce71a4e54e4774")

        XCTAssertEqual(event.mentionedPubkeys, [])
        XCTAssertEqual(event.mentionedEventIds, ["a7823beaa8c9d4063bb554972fa5ba90112764231aed3d4d691199da3e5c6a03", "c464c099740755440d0cac82b54c4dcd12faffa327ea4409ace221ae3e00deda"])

        let rootEventTag = try XCTUnwrap(event.rootEventTag)
        let replyEventTag = try XCTUnwrap(event.replyEventTag)
        XCTAssertEqual(rootEventTag.eventId, "a7823beaa8c9d4063bb554972fa5ba90112764231aed3d4d691199da3e5c6a03")
        XCTAssertEqual(rootEventTag.relayURL, nil)
        XCTAssertEqual(rootEventTag.marker, nil)
        XCTAssertEqual(replyEventTag.eventId, "c464c099740755440d0cac82b54c4dcd12faffa327ea4409ace221ae3e00deda")
        XCTAssertEqual(replyEventTag.relayURL, nil)
        XCTAssertEqual(replyEventTag.marker, nil)
        XCTAssertEqual(event.mentionedEventTags, [])
    }

    func testDecodeTextNoteRootReplyDeprecatedPositionalTags() throws {
        let event: TextNoteEvent = try decodeFixture(filename: "text_note_root_reply_deprecated_positional_tags")

        XCTAssertEqual(event.id, "d5f7e913264a407a60619df12a845d52512027588846a5a6fb4da392613fdf23")
        XCTAssertEqual(event.pubkey, "a8f3721a89fdb79a7e7c6e7b8134c720a408b6c24bf4262419cf54b160c527a6")
        XCTAssertEqual(event.createdAt, 1704153856)
        XCTAssertEqual(event.kind, .textNote)

        let expectedTags: [Tag] = [
            .event("a7823beaa8c9d4063bb554972fa5ba90112764231aed3d4d691199da3e5c6a03")
        ]
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertEqual(event.content, "Text note reply to root with deprecated positional tags.\nnostr:note1257hctv73whvfgy3wvfdxkcj8ydjfl80vstmzh0j3ppzukzwpyxsc0hy03")
        XCTAssertEqual(event.signature, "7583a884c7f5061e8693a3e09ef6f427f4fda0c4b58666b654e2db344b3ffbd8bfdb5ba11292990e3d3845f67d3afac500b18f9c98d62b11bd46d90ef95d115e")

        XCTAssertEqual(event.mentionedPubkeys, [])
        XCTAssertEqual(event.mentionedEventIds, ["a7823beaa8c9d4063bb554972fa5ba90112764231aed3d4d691199da3e5c6a03"])

        let rootEventTag = try XCTUnwrap(event.rootEventTag)
        let replyEventTag = try XCTUnwrap(event.replyEventTag)
        XCTAssertEqual(rootEventTag.eventId, "a7823beaa8c9d4063bb554972fa5ba90112764231aed3d4d691199da3e5c6a03")
        XCTAssertEqual(rootEventTag.relayURL, nil)
        XCTAssertEqual(rootEventTag.marker, nil)
        XCTAssertEqual(replyEventTag.eventId, "a7823beaa8c9d4063bb554972fa5ba90112764231aed3d4d691199da3e5c6a03")
        XCTAssertEqual(replyEventTag.relayURL, nil)
        XCTAssertEqual(replyEventTag.marker, nil)
        XCTAssertEqual(event.mentionedEventTags, [])
    }

    func testDecodeNoteWithSubject() throws {
        let event: TextNoteEvent = try decodeFixture(filename: "text_note_subject")

        XCTAssertEqual(event.id, "fa5ed84fc8eeb959fd39ad8e48388cfc33075991ef8e50064cfcecfd918bb91b")
        XCTAssertEqual(event.pubkey, "82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2")
        XCTAssertEqual(event.createdAt, 1682080184)
        XCTAssertEqual(event.kind, .textNote)

        let expectedTags: [Tag] = [
            .event("93930d65435d49db723499335473920795e7f13c45600dcfad922135cf44bd63"),
            .pubkey("f8e6c64342f1e052480630e27e1016dce35fc3a614e60434fef4aa2503328ca9"),
            Tag(name: .subject, value: "test-subject")
        ]
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertEqual(event.content, "I think it stays persistent on your profile, but interface setting doesn’t persist. Bug.  ")
        XCTAssertEqual(event.subject, "test-subject")
        XCTAssertEqual(event.signature, "96e6667348b2b1fc5f6e73e68fb1605f571ad044077dda62a35c15eb8290f2c4559935db461f8466df3dcf39bc2e11984c5344f65aabee4520dd6653d74cdc09")

        XCTAssertEqual(event.mentionedPubkeys, ["f8e6c64342f1e052480630e27e1016dce35fc3a614e60434fef4aa2503328ca9"])
        XCTAssertEqual(event.mentionedEventIds, ["93930d65435d49db723499335473920795e7f13c45600dcfad922135cf44bd63"])
    }

    func testDecodeNoteWithCustomEmoji() throws {
        let event: TextNoteEvent = try decodeFixture(filename: "text_note_custom_emoji")

        XCTAssertEqual(event.id, "afc6f38482de8600bfbc85d9f1b404a2bbab8a65a3e2eb62f0ce47195e99886b")
        XCTAssertEqual(event.pubkey, "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        XCTAssertEqual(event.createdAt, 1699770458)
        XCTAssertEqual(event.kind, .textNote)

        let expectedTags = [
            Tag(name: .emoji, value: "ostrich", otherParameters: ["https://nostrsdk.com/ostrich.png"]),
            Tag(name: .subject, value: "test-subject")
        ]
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertEqual(event.content, "Hello world! :ostrich:")
        XCTAssertEqual(event.subject, "test-subject")
        XCTAssertEqual(event.signature, "7a110a5ad3a248985d11dbb90da3f254fa99fbae80bf6e270f36d1c697a6fbf3f6508a5a027f00e2fc9ca81aafdd67c52b09e80c49fa5f7ab3bc8d5836a08601")

        XCTAssertEqual(event.mentionedPubkeys, [])
        XCTAssertEqual(event.mentionedEventIds, [])
    }

}
