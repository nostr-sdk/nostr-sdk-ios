//
//  RelayPool.swift
//
//
//  Created by Bryan Montz on 12/31/23.
//

import Foundation
import os.log

/// An object that manages a set of relays.
/// Send events and messages to all the relays in the pool.
public final class RelayPool: RelayDelegate, RelayOperating {
    
    /// The set of relays.
    public private(set) var relays = Set<Relay>()
    
    /// A delegate to receive events and state changes.
    public weak var delegate: RelayDelegate?
    
    private let logger = Logger(subsystem: "NostrSDK", category: "RelayPool")
    
    public init(relays: Set<Relay> = [], delegate: RelayDelegate? = nil) {
        self.relays = relays
        self.delegate = delegate
        setUpRelays()
    }
    
    public convenience init(relayURLs: Set<URL> = [], delegate: RelayDelegate? = nil) {
        self.init(relays: Set(relayURLs.compactMap { try? Relay(url: $0) }),
                  delegate: delegate)
    }
    
    private func setUpRelays() {
        relays.forEach { setUpRelay($0) }
    }
    
    private func setUpRelay(_ relay: Relay) {
        relay.delegate = self
        relay.connect()
    }
    
    /// Adds a relay to the pool, if a matching one is not already there (based on relay URL).
    /// - Parameter relay: The relay to add to the pool.
    ///
    /// > Note: The relay will be automatically connected.
    public func add(relay: Relay) {
        guard !relays.contains(relay) else {
            logger.warning("Could not add relay because it was already in the pool: \(relay.url)")
            return
        }
        
        relays.insert(relay)
        setUpRelay(relay)
    }
    
    /// Removes a relay from the pool, if a matching one is found (based on relay URL).
    /// - Parameter relay: The relay to remove from the pool.
    ///
    /// > Note: The relay connection will be automatically closed.
    public func remove(relay: Relay) {
        removeRelay(withURL: relay.url)
    }
    
    /// Removes a relay from the pool, if one with a matching URL is found.
    /// - Parameter relayURL: The relay URL to remove.
    ///
    /// > Note: The relay connection will be automatically closed.
    public func removeRelay(withURL relayURL: URL) {
        let matches = relays.filter { $0.url == relayURL }
        matches.forEach {
            $0.disconnect()
            relays.remove($0)
        }
    }
    
    // MARK: - RelayOperating
    
    /// Attempts to connect to all of the relays.
    public func connect() {
        relays.forEach { $0.connect() }
    }
    
    /// Attempts to disconnect from all of the relays.
    public func disconnect() {
        relays.forEach { $0.disconnect() }
    }
    
    /// Sends a request to the relays.
    /// - Parameter request: The request to send
    public func send(request: String) {
        relays.forEach { $0.send(request: request) }
    }
    
    /// Subscribes to all of the relays using the supplied ``Filter``.
    /// - Parameters:
    ///   - filter: The filter to subscribe to.
    ///   - subscriptionId: The subscription id. If you do not supply one, a random one will be created and returned.
    /// - Returns: The subscription id.
    public func subscribe(with filter: Filter, subscriptionId: String = UUID().uuidString) throws -> String {
        do {
            try relays.forEach { try $0.subscribe(with: filter, subscriptionId: subscriptionId) }
        } catch {
            logger.error("An error occurred while subscribing to a relay with a filter: \(error)")
        }
        return subscriptionId
    }
    
    /// Attempts to close subscriptions with all relays with the supplied subscription id.
    /// - Parameter subscriptionId: The subscription id to close subscriptions for.
    public func closeSubscription(with subscriptionId: String) throws {
        do {
            try relays.forEach { try $0.closeSubscription(with: subscriptionId) }
        } catch {
            logger.error("An error occurred while closing a subscription with subscription id: \(subscriptionId): \(error)")
        }
    }
    
    /// Publishes an event to the relays.
    /// - Parameter event: The ``NostrEvent`` to publish
    public func publishEvent(_ event: NostrEvent) throws {
        try relays.forEach {
            try $0.publishEvent(event)
        }
    }
    
    // MARK: - RelayDelegate
    
    public func relayStateDidChange(_ relay: Relay, state: Relay.State) {
        delegate?.relayStateDidChange(relay, state: state)
    }
    
    public func relay(_ relay: Relay, didReceive event: RelayEvent) {
        delegate?.relay(relay, didReceive: event)
    }
}
