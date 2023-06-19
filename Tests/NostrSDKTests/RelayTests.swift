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
    private var receiveExpectation: XCTestExpectation?
    private var disconnectExpectation: XCTestExpectation?
    
    override func setUp() {
        connectExpectation = expectation(description: "connect")
        receiveExpectation = expectation(description: "receive")
        disconnectExpectation = expectation(description: "disconnect")
    }
    
    func testConnectAndReceive() throws {
        let relay = try Relay(url: RelayTests.RelayURL)
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
        
        let subscriptionId = try relay.subscribe(with: Filter(kinds: [1], limit: 1))
        
        relay.events
            .sink { [unowned relay] _ in
                // we have received an event from the relay. close the subscription.
                try? relay.closeSubscription(with: subscriptionId)
                self.receiveExpectation?.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [receiveExpectation!], timeout: 10)
        
        relay.disconnect()
        
        wait(for: [disconnectExpectation!], timeout: 10)
        
        cancellables.removeAll()
    }
    
    func testRelayDelegate() throws {
        let relay = try Relay(url: RelayTests.RelayURL)
        relay.delegate = self
        relay.connect()
        
        wait(for: [connectExpectation!], timeout: 10)
        
        let subscriptionId = try relay.subscribe(with: Filter(kinds: [1], limit: 1))
        
        wait(for: [receiveExpectation!], timeout: 10)
        
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
    
    func relay(_ relay: Relay, didReceive event: NostrEvent) {
        receiveExpectation?.fulfill()
    }
}
