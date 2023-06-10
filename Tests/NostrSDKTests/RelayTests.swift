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

    func testConnectAndReceive() throws {
        let relay = try Relay(url: RelayTests.RelayURL)
        
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

}
