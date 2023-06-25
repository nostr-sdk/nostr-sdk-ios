//
//  Relay.swift
//  
//
//  Created by Bryan Montz on 6/5/23.
//

import Combine
import Foundation
import os.log

/// An error that occurs while validating a relay URL.
public enum RelayURLError: Error, CustomStringConvertible {
    /// An indication that the provided URL has an invalid scheme.
    case invalidScheme
    
    public var description: String {
        switch self {
        case .invalidScheme:
            return "The provided scheme was invalid."
        }
    }
}

/// An error that occurs while building a relay request.
public enum RelayRequestError: Error, CustomStringConvertible {

    /// An indication that there is no connection to the relay web socket.
    case notConnected

    /// An indication that the request was invalid.
    case invalidRequest
    
    public var description: String {
        switch self {
        case .notConnected:
            return "There is no connection to the relay web socket."
        case .invalidRequest:
            return "The request was invalid."
        }
    }
}

/// An optional interface for receiving state updates and events
public protocol RelayDelegate: AnyObject {
    func relayStateDidChange(_ relay: Relay, state: Relay.State)
    func relay(_ relay: Relay, didReceive event: NostrEvent)
}

/// An object that communicates with a relay.
public final class Relay: ObservableObject, EventVerifying {
    
    /// Constants indicating the current state of the relay.
    public enum State: Equatable {
        public static func == (lhs: Relay.State, rhs: Relay.State) -> Bool {
            switch (lhs, rhs) {
            case (.notConnected, .notConnected), (.connecting, .connecting), (.connected, .connected):
                return true
            case (.error(let error1), .error(let error2)):
                return (error1 as NSError).isEqual((error2 as NSError))
            default:
                return false
            }
        }
        
        /// The relay is not connected.
        case notConnected
        
        /// The relay is connecting.
        case connecting
        
        /// The relay is connected.
        case connected
        
        /// The relay has an error.
        case error(Error)
    }
    
    /// A Publisher that publishes the relay's current state.
    @Published public private(set) var state: State = .notConnected {
        didSet {
            if state != oldValue {
                delegate?.relayStateDidChange(self, state: state)
            }
        }
    }
    
    let socket: WebSocket
    private var socketSubscription: AnyCancellable?
    
    /// A Publisher that publishes all events the relay receives.
    public private(set) var events = PassthroughSubject<NostrEvent, Never>()
    
    /// An optional delegate interface for receiving state updates and events
    public weak var delegate: RelayDelegate?
    
    private let logger = Logger(subsystem: "NostrSDK", category: "Relay")
    
    /// Creates a new Relay with the provided URL.
    /// - Parameter url: The websocket URL of the relay
    ///
    /// > Important: The url must have a websocket scheme (e.g. "wss" or "ws").
    public init(url: URL) throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw URLError(.badURL)
        }
        
        guard components.scheme == "wss" || components.scheme == "ws" else {
            throw RelayURLError.invalidScheme
        }
        
        socket = WebSocket(url)
        socketSubscription = socket.subject
            .sink { [weak self] event in
                switch event {
                case .connected:
                    self?.state = .connected
                    self?.logger.info("\(event.description)")
                case .message(let message):
                    self?.receive(message)
                    self?.logger.info("\(event.description)")
                case .disconnected:
                    self?.state = .notConnected
                    self?.logger.info("\(event.description)")
                case .error(let error):
                    self?.state = .error(error)
                    self?.logger.error("\(event.description)")
                }
            }
    }
    
    private func receive(_ message: URLSessionWebSocketTask.Message) {
        func handle(messageData: Data) {
            let response = RelayResponse.decode(data: messageData)
            switch response {
            case .event(_, let event):
                events.send(event)
                delegate?.relay(self, didReceive: event)
            default:
                break
            }
        }
        
        switch message {
        case .data(let data):
            handle(messageData: data)
        case .string(let string):
            if let data = string.data(using: .utf8) {
                handle(messageData: data)
            }
        @unknown default:
            break
        }
    }

    /// Connects to the relay if it is not already in a connected or connecting state.
    public func connect() {
        guard state != .connected && state != .connecting else {
            return
        }

        state = .connecting
        socket.connect()
    }

    /// Disconnects from the relay if it is in a connected or connecting state.
    public func disconnect() {
        guard state == .connected || state == .connecting else {
            return
        }

        socket.disconnect()
    }
    
    /// Sends a request to the relay.
    /// - Parameter request: The request to send
    public func send(request: String) {
        socket.send(URLSessionWebSocketTask.Message.string(request))
    }
    
    /// Sends a request to the relay with the provided filter.
    /// - Parameter filter: The filter to send to the relay
    /// - Returns: The subscription id
    ///
    /// Call this function to begin a new subscription to the relay, which should
    /// respond with events that match the provided filter.
    @discardableResult
    public func subscribe(with filter: Filter) throws -> String {
        guard state == .connected else {
            throw RelayRequestError.notConnected
        }

        let subscriptionId = UUID().uuidString
        guard let request = RelayRequest.request(subscriptionId: subscriptionId,
                                                 filter: filter).encoded else {
            throw RelayRequestError.invalidRequest
        }
        send(request: request)
        return subscriptionId
    }
    
    /// Sends a request to the relay to close the subscription with the provided id.
    /// - Parameter subscriptionId: The subscription id to close
    ///
    /// Call this function to cleanly close the subscription with the relay
    /// when the results of the subscription are no longer needed.
    public func closeSubscription(with subscriptionId: String) throws {
        guard state == .connected else {
            throw RelayRequestError.notConnected
        }

        guard let request = RelayRequest.close(subscriptionId: subscriptionId).encoded else {
            throw RelayRequestError.invalidRequest
        }
        send(request: request)
    }
    
    /// Publishes an event to the relay.
    /// - Parameter event: The ``NostrEvent`` to publish
    public func publishEvent(_ event: NostrEvent) throws {
        guard state == .connected else {
            throw RelayRequestError.notConnected
        }
        
        try verifyEvent(event)
        
        guard let request = RelayRequest.event(event).encoded else {
            throw RelayRequestError.invalidRequest
        }
        
        send(request: request)
    }
}
