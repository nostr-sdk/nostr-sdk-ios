//
//  RelayTests.swift
//  
//
//  Created by Bryan Montz on 6/5/23.
//

import Combine
@testable import NostrSDK
import XCTest

final class RelayTests: XCTestCase {
    
    private static let RelayURL = URL(string: "wss://relay.damus.io")!
    
    private var cancellables = Set<AnyCancellable>()
    
    private var connectExpectation: XCTestExpectation?
    private var receiveEventExpectation: XCTestExpectation?
    private var disconnectExpectation: XCTestExpectation?

    private var receiveResponseEventExpectation: XCTestExpectation?
    private var receiveResponseOkExpectation: XCTestExpectation?
    private var receiveResponseEoseExpectation: XCTestExpectation?

    func testConnectAndReceive() throws {
        connectExpectation = expectation(description: "connect")
        receiveEventExpectation = expectation(description: "receive")
        disconnectExpectation = expectation(description: "disconnect")

        receiveResponseEventExpectation = expectation(description: "receiveResponseEvent")

        let relay = try Relay(url: RelayTests.RelayURL)
        XCTAssertEqual(relay.url, RelayTests.RelayURL)
        relay.connect()
        
        relay.$state
            .removeDuplicates()
            .sink { state in
                switch state {
                case .connected:
                    self.connectExpectation?.fulfill()
                case .notConnected:
                    self.disconnectExpectation?.fulfill()
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        wait(for: [connectExpectation!], timeout: 10)
        
        let filter = try XCTUnwrap(Filter(kinds: [1], limit: 1))
        let subscriptionId = try relay.subscribe(with: filter)
        
        relay.events
            .sink { [unowned relay] _ in
                // we have received an event from the relay. close the subscription.
                try? relay.closeSubscription(with: subscriptionId)
                self.receiveResponseEventExpectation?.fulfill()
                self.receiveEventExpectation?.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [receiveResponseEventExpectation!], timeout: 10)
        wait(for: [receiveEventExpectation!], timeout: 10)
        
        relay.disconnect()
        
        wait(for: [disconnectExpectation!], timeout: 10)
        
        cancellables.removeAll()
    }

    func testSubscribeWithoutConnection() throws {
        let relay = try Relay(url: RelayTests.RelayURL)
        let filter = try XCTUnwrap(Filter(kinds: [1], limit: 1))
        XCTAssertThrowsError(try relay.subscribe(with: filter)) {
            XCTAssertEqual($0 as? RelayRequestError, RelayRequestError.notConnected)
        }
    }

    func testCloseSubscribeWithoutConnection() throws {
        let relay = try Relay(url: RelayTests.RelayURL)
        XCTAssertThrowsError(try relay.closeSubscription(with: "foobar")) {
            XCTAssertEqual($0 as? RelayRequestError, RelayRequestError.notConnected)
        }
    }
    
    func testRelayDelegate() throws {
        connectExpectation = expectation(description: "connect")
        receiveEventExpectation = expectation(description: "receive")
        disconnectExpectation = expectation(description: "disconnect")

        receiveResponseEventExpectation = expectation(description: "receiveResponseEvent")
        receiveResponseEoseExpectation = expectation(description: "receiveResponseEose")

        let relay = try Relay(url: RelayTests.RelayURL)
        relay.delegate = self
        relay.connect()
        
        wait(for: [connectExpectation!], timeout: 10)
        
        let filter = try XCTUnwrap(Filter(kinds: [1], limit: 1))
        let subscriptionId = try relay.subscribe(with: filter)
        
        wait(for: [receiveResponseEventExpectation!], timeout: 10)
        wait(for: [receiveEventExpectation!], timeout: 10)
        wait(for: [receiveResponseEoseExpectation!], timeout: 10)

        try? relay.closeSubscription(with: subscriptionId)
        
        relay.disconnect()
        
        wait(for: [disconnectExpectation!], timeout: 10)
    }
}

extension RelayTests: RelayDelegate {
    
    func relayStateDidChange(_ relay: Relay, state: Relay.State) {
        switch state {
        case .connected:
            connectExpectation?.fulfill()
        case .notConnected:
            disconnectExpectation?.fulfill()
        default:
            break
        }
    }
    
    func relay(_ relay: Relay, didReceive event: RelayEvent) {
        receiveEventExpectation?.fulfill()
    }

    func relay(_ relay: NostrSDK.Relay, didReceive response: RelayResponse) {
        switch response {
        case .event:
            receiveResponseEventExpectation?.fulfill()
        case .ok:
            receiveResponseOkExpectation?.fulfill()
        case .eose:
            receiveResponseEoseExpectation?.fulfill()
        default:
            break
        }
    }
}
