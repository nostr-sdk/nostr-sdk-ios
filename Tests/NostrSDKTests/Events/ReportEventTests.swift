//
//  ReportEventTests.swift
//  
//
//  Created by Terry Yiu on 4/14/24.
//

@testable import NostrSDK
import XCTest

final class ReportEventTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading {

    func testCreateReportUser() throws {
        let report = try reportUser(withPublicKey: Keypair.test.publicKey, reportType: .impersonation, additionalInformation: "he's lying!", signedBy: Keypair.test)

        XCTAssertEqual(report.kind, .report)
        XCTAssertEqual(report.content, "he's lying!")

        let expectedTag = Tag.pubkey(Keypair.test.publicKey.hex, otherParameters: ["impersonation"])
        XCTAssertTrue(report.tags.contains(expectedTag))

        try verifyEvent(report)
    }

    func testCreateReportNote() throws {
        let noteToReport: TextNoteEvent = try decodeFixture(filename: "text_note")

        let report = try reportNote(noteToReport, reportType: .profanity, additionalInformation: "mean words", signedBy: Keypair.test)

        XCTAssertEqual(report.kind, .report)
        XCTAssertEqual(report.content, "mean words")

        let expectedPubkeyTag = Tag.pubkey("82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2")
        XCTAssertTrue(report.tags.contains(expectedPubkeyTag))

        let expectedEventTag = Tag.event(noteToReport.id, otherParameters: ["profanity"])
        XCTAssertTrue(report.tags.contains(expectedEventTag))

        try verifyEvent(report)
    }

    func testCreateReportNoteWithImpersonationShouldFail() throws {
        let noteToReport: TextNoteEvent = try decodeFixture(filename: "text_note")

        XCTAssertThrowsError(try reportNote(noteToReport, reportType: .impersonation, additionalInformation: "mean words", signedBy: Keypair.test))
    }

}
