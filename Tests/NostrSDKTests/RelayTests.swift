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
    
    func testConnectAndReceive() throws {
        let relay = try Relay(url: RelayTests.RelayURL)
        relay.connect()
        
        let exp = expectation(description: "connect")
        
        relay.$state
            .sink { state in
                if state == .connected {
                    exp.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 10)
        
        let subscriptionId = try relay.subscribe(with: Filter(kinds: [1], limit: 1))
        
        let exp2 = expectation(description: "receive")
        
        relay.events
            .sink { [unowned relay] _ in
                // we have received an event from the relay. close the subscription.
                try? relay.closeSubscription(with: subscriptionId)
                exp2.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [exp2], timeout: 10)
    }
    
    func testRelayDelegate() throws {
        let relay = try Relay(url: RelayTests.RelayURL)
        relay.connect()
        relay.delegate = self
        
        let exp = expectation(description: "connect")
        
        connectExpectation = exp
        
        wait(for: [exp], timeout: 10)
        
        let subscriptionId = try relay.subscribe(with: Filter(kinds: [1], limit: 1))
        
        let exp2 = expectation(description: "receive")
        
        receiveExpectation = exp2
        
        wait(for: [exp2], timeout: 10)
        
        try? relay.closeSubscription(with: subscriptionId)
    }
}

extension RelayTests: RelayDelegate {
    
    func relayStateDidChange(_ relay: Relay, state: Relay.State) {
        if state == .connected {
            connectExpectation?.fulfill()
        }
    }
    
    func relay(_ relay: Relay, didReceive event: NostrEvent) {
        receiveExpectation?.fulfill()
    }
}
