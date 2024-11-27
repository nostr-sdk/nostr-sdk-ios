//
//  WalletConnectTests.swift
//  NostrSDK
//
//  Created by Thomas Rademaker on 11/27/24.
//

import XCTest
@testable import NostrSDK

final class WalletConnectTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading {
    
    func testCreateWalletConnectInfoEvent() throws {
        let capabilities = ["pay_invoice", "get_balance", "notifications"]
        let notifications = ["payment_received", "payment_sent"]
        
        let event = try walletConnectInfo(
            capabilities: capabilities,
            notifications: notifications,
            signedBy: Keypair.test
        )
        
        XCTAssertEqual(event.capabilities, capabilities)
        XCTAssertEqual(event.notificationTypes, notifications)
        XCTAssertEqual(event.kind, .walletConnectInfo)
        
        try verifyEvent(event)
    }
    
    func testCreateWalletConnectRequestEvent() throws {
        let walletPubkey = Keypair.test.publicKey.hex
        let method = "pay_invoice"
        let params: [String: Any] = ["invoice": "lnbc50n1...", "amount": 123]
        let expiration: Int64 = 1703225078
        
        let event = try walletConnectRequest(
            walletPubkey: walletPubkey,
            method: method,
            params: params,
            expiration: expiration,
            signedBy: Keypair.test
        )
        
        XCTAssertEqual(event.walletPubkey, walletPubkey)
        XCTAssertEqual(event.expiration, expiration)
        XCTAssertEqual(event.kind, .walletConnectRequest)
        
        let request = try XCTUnwrap(event.request)
        XCTAssertEqual(request.method, method)
        XCTAssertEqual(request.params["invoice"] as? String, "lnbc50n1...")
        XCTAssertEqual(request.params["amount"] as? Int, 123)
        
        try verifyEvent(event)
    }
    
    func testCreateWalletConnectResponseEvent() throws {
        let clientPubkey = Keypair.test.publicKey.hex
        let requestId = "test_request_id"
        let resultType = "pay_invoice"
        let result: [String: Any] = ["preimage": "0123456789abcdef", "fees_paid": 5]
        
        let event = try walletConnectResponse(
            clientPubkey: clientPubkey,
            requestId: requestId,
            resultType: resultType,
            result: result,
            signedBy: Keypair.test
        )
        
        XCTAssertEqual(event.clientPubkey, clientPubkey)
        XCTAssertEqual(event.requestId, requestId)
        XCTAssertEqual(event.kind, .walletConnectResponse)
        
        let response = try XCTUnwrap(event.response)
        XCTAssertEqual(response.resultType, resultType)
        XCTAssertNil(response.error)
        XCTAssertEqual(response.result?["preimage"] as? String, "0123456789abcdef")
        XCTAssertEqual(response.result?["fees_paid"] as? Int, 5)
        
        try verifyEvent(event)
    }
    
    func testCreateWalletConnectResponseEventWithError() throws {
        let clientPubkey = Keypair.test.publicKey.hex
        let requestId = "test_request_id"
        let resultType = "pay_invoice"
        let error = [
            "code": WalletConnectErrorCode.insufficentBallance.rawValue,
            "message": "Not enough funds"
        ]
        
        let event = try walletConnectResponse(
            clientPubkey: clientPubkey,
            requestId: requestId,
            resultType: resultType,
            error: error,
            signedBy: Keypair.test
        )
        
        let response = try XCTUnwrap(event.response)
        XCTAssertEqual(response.error?["code"], WalletConnectErrorCode.insufficentBallance.rawValue)
        XCTAssertEqual(response.error?["message"], "Not enough funds")
        XCTAssertNil(response.result)
        
        try verifyEvent(event)
    }
    
    func testCreateWalletConnectNotificationEvent() throws {
        let clientPubkey = Keypair.test.publicKey.hex
        let notificationType = "payment_received"
        let notification: [String: Any] = [
            "type": "incoming",
            "payment_hash": "abc123",
            "amount": 1000,
            "created_at": 1703225078
        ]
        
        let event = try walletConnectNotification(
            clientPubkey: clientPubkey,
            notificationType: notificationType,
            notification: notification,
            signedBy: Keypair.test
        )
        
        XCTAssertEqual(event.clientPubkey, clientPubkey)
        XCTAssertEqual(event.kind, .walletConnectNotification)
        
        let content = try XCTUnwrap(event.notificationContent)
        XCTAssertEqual(content.type, notificationType)
        XCTAssertEqual(content.data["payment_hash"] as? String, "abc123")
        XCTAssertEqual(content.data["amount"] as? Int, 1000)
        
        try verifyEvent(event)
    }
}

extension WalletConnectTests {
    
    func testDecodeWalletConnectInfoEvent() throws {
        let event: WalletConnectInfoEvent = try decodeFixture(filename: "wallet_connect_info_event")
        
        XCTAssertEqual(event.id, "a87228880982599ed0f83411e8ea4f6714f35961f32b2274994897c218ad171d")
        XCTAssertEqual(event.pubkey, Keypair.test.publicKey.hex)
        XCTAssertEqual(event.createdAt, 1702832309)
        XCTAssertEqual(event.kind, .walletConnectInfo)
        XCTAssertEqual(event.capabilities, ["pay_invoice", "get_balance", "notifications"])
        XCTAssertEqual(event.notificationTypes, ["payment_received", "payment_sent"])
        XCTAssertEqual(event.signature, "b1f04510811195f69552dc1aff5033f306b4fdf9e6e7c1ac265438b457932266414bdf1ed9ec0c2c2f22d56bef7e519af5c3bfb974c933fd20037918b95dc65a")
    }
    
    func testDecodeWalletConnectRequestEvent() throws {
        let event: WalletConnectRequestEvent = try decodeFixture(filename: "wallet_connect_request_event")
        
        XCTAssertEqual(event.id, "b87228880982599ed0f83411e8ea4f6714f35961f32b2274994897c218ad171e")
        XCTAssertEqual(event.pubkey, Keypair.test.publicKey.hex)
        XCTAssertEqual(event.createdAt, 1702832310)
        XCTAssertEqual(event.kind, .walletConnectRequest)
        XCTAssertEqual(event.walletPubkey, "7e7e9c42a91bfef19fa929e5fda1b72e0ebc1a4c1141673e2794234d86addf4e")
        XCTAssertEqual(event.expiration, 1703225078)
        
        let request = try XCTUnwrap(event.request)
        XCTAssertEqual(request.method, "pay_invoice")
        XCTAssertEqual(request.params["invoice"] as? String, "lnbc50n1...")
        XCTAssertEqual(request.params["amount"] as? Int, 123)
        
        XCTAssertEqual(event.signature, "c1f04510811195f69552dc1aff5033f306b4fdf9e6e7c1ac265438b457932266414bdf1ed9ec0c2c2f22d56bef7e519af5c3bfb974c933fd20037918b95dc65b")
    }
    
    func testDecodeWalletConnectResponseEvent() throws {
        let event: WalletConnectResponseEvent = try decodeFixture(filename: "wallet_connect_response_event")
        
        XCTAssertEqual(event.id, "c87228880982599ed0f83411e8ea4f6714f35961f32b2274994897c218ad171f")
        XCTAssertEqual(event.pubkey, Keypair.test.publicKey.hex)
        XCTAssertEqual(event.createdAt, 1702832311)
        XCTAssertEqual(event.kind, .walletConnectResponse)
        XCTAssertEqual(event.clientPubkey, "8e7e9c42a91bfef19fa929e5fda1b72e0ebc1a4c1141673e2794234d86addf4f")
        XCTAssertEqual(event.requestId, "b87228880982599ed0f83411e8ea4f6714f35961f32b2274994897c218ad171e")
        
        let response = try XCTUnwrap(event.response)
        XCTAssertEqual(response.resultType, "pay_invoice")
        XCTAssertEqual(response.result?["preimage"] as? String, "0123456789abcdef")
        XCTAssertEqual(response.result?["fees_paid"] as? Int, 5)
        
        XCTAssertEqual(event.signature, "d1f04510811195f69552dc1aff5033f306b4fdf9e6e7c1ac265438b457932266414bdf1ed9ec0c2c2f22d56bef7e519af5c3bfb974c933fd20037918b95dc65c")
    }
    
    func testDecodeWalletConnectNotificationEvent() throws {
        let event: WalletConnectNotificationEvent = try decodeFixture(filename: "wallet_connect_notification_event")
        
        XCTAssertEqual(event.id, "d87228880982599ed0f83411e8ea4f6714f35961f32b2274994897c218ad171g")
        XCTAssertEqual(event.pubkey, Keypair.test.publicKey.hex)
        XCTAssertEqual(event.createdAt, 1702832312)
        XCTAssertEqual(event.kind, .walletConnectNotification)
        XCTAssertEqual(event.clientPubkey, "8e7e9c42a91bfef19fa929e5fda1b72e0ebc1a4c1141673e2794234d86addf4f")
        
        let content = try XCTUnwrap(event.notificationContent)
        XCTAssertEqual(content.type, "payment_received")
        XCTAssertEqual(content.data["type"] as? String, "incoming")
        XCTAssertEqual(content.data["payment_hash"] as? String, "abc123")
        XCTAssertEqual(content.data["amount"] as? Int, 1000)
        XCTAssertEqual(content.data["created_at"] as? Int, 1703225078)
        
        XCTAssertEqual(event.signature, "e1f04510811195f69552dc1aff5033f306b4fdf9e6e7c1ac265438b457932266414bdf1ed9ec0c2c2f22d56bef7e519af5c3bfb974c933fd20037918b95dc65d")
    }
}
