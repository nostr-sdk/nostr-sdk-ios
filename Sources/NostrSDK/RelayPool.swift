//
//  RelayPool.swift
//
//
//  Created by Bryan Montz on 12/31/23.
//

import Combine
import Foundation
import os.log

/// An object that manages a set of relays.
/// Send events and messages to all the relays in the pool.
public final class RelayPool: ObservableObject, RelayOperating {
    
    /// The set of relays.
    public private(set) var relays = Set<Relay>()
    
    /// A Publisher that publishes all events from all relays.
    @Published public private(set) var events = PassthroughSubject<RelayEvent, Never>()
    
    /// A delegate to receive events and state changes.
    public weak var delegate: RelayDelegate? {
        didSet {
            relays.forEach { $0.delegate = delegate }
        }
    }
    
    private let logger = Logger(subsystem: "NostrSDK", category: "RelayPool")
    private var cancellable: AnyCancellable?
    
    public init(relays: Set<Relay> = [], delegate: RelayDelegate? = nil) {
        self.relays = relays
        self.delegate = delegate
        setUpRelays()
    }
    
    public convenience init(relayURLs: Set<URL> = [], delegate: RelayDelegate? = nil) throws {
        try self.init(relays: Set(relayURLs.compactMap { try Relay(url: $0) }),
                      delegate: delegate)
    }
    
    private func setUpRelays() {
        relays.forEach { setUpRelay($0) }
        updateEventsPublisher()
    }
    
    private func setUpRelay(_ relay: Relay) {
        relay.delegate = delegate
        relay.connect()
    }
    
    private func updateEventsPublisher() {
        let mergedEvents = Publishers.MergeMany(relays.map { $0.events })
        cancellable = mergedEvents
            .sink { [weak self] event in
                self?.events.send(event)
            }
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
        updateEventsPublisher()
    }
    
    /// Removes a relay from the pool, if a matching one is found (based on relay URL).
    /// - Parameter relay: The relay to remove from the pool.
    ///
    /// > Note: The relay connection will be automatically closed.
    public func remove(relay: Relay) {
        removeRelay(withURL: relay.url)
        updateEventsPublisher()
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
    public func subscribe(with filter: Filter, subscriptionId: String = UUID().uuidString) -> String {
        relays.forEach {
            do {
                try $0.subscribe(with: filter, subscriptionId: subscriptionId)
            } catch {
                logger.error("An error occurred while subscribing to a relay (\($0.url)) with a filter: \(error)")
            }
        }
        return subscriptionId
    }
    
    /// Attempts to close subscriptions with all relays with the supplied subscription id.
    /// - Parameter subscriptionId: The subscription id to close subscriptions for.
    public func closeSubscription(with subscriptionId: String) {
        relays.forEach {
            do {
                try $0.closeSubscription(with: subscriptionId)
            } catch {
                logger.error("An error occurred while closing a subscription with a relay (\($0.url)) with subscription id: \(subscriptionId): \(error)")
            }
        }
    }
    
    /// Publishes an event to the relays.
    /// - Parameter event: The ``NostrEvent`` to publish
    public func publishEvent(_ event: NostrEvent) {
        relays.forEach {
            do {
                try $0.publishEvent(event)
            } catch {
                logger.error("An error occurred while publishing an event to a relay (\($0.url)): \(error)")
            }
        }
    }
}
