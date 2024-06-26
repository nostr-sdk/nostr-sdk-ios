//
//  WebSocket.swift
//
//
//  Created by Bryan Montz on 4/13/23.
//

import Combine
import Foundation

/// An enumeration of various types of socket events.
enum WebSocketEvent: CustomStringConvertible {
    /// Indicates that the socket has been successfully connected.
    case connected
    
    /// Indicates that a message has been received through the connection.
    case message(URLSessionWebSocketTask.Message)
    
    /// Indicates that the socket has been disconnected and includes the closure type and reason.
    case disconnected(URLSessionWebSocketTask.CloseCode, String?)
    
    /// Indicates that an error has occurred with the conection.
    case error(Error)
    
    var description: String {
        switch self {
        case .connected:
            return "Connected."
        case .message(let message):
            return "Received message: \(message)"
        case .disconnected(let closeCode, let reason):
            return "Disconnected. close code: \(closeCode), reason: \(String(describing: reason))"
        case .error(let error):
            return "Error: \(error)"
        }
    }
}

/// An object that manages the socket connection to a server.
final class WebSocket: NSObject, URLSessionWebSocketDelegate {
    
    /// The server's URL.
    let url: URL
    
    private let session: URLSession
    private lazy var webSocketTask: URLSessionWebSocketTask = {
        let task = session.webSocketTask(with: url)
        task.delegate = self
        return task
    }()
    
    /// A channel through which socket events are reported.
    let subject = PassthroughSubject<WebSocketEvent, Never>()
    
    /// Initializes a ``WebSocket`` with a provided server URL and optionally, a ``URLSession``.
    /// - Parameters:
    ///   - url: The URL of the server to connect to.
    ///   - session: The session in which to make the socket connection. If not provided, the standard one will be used.
    init(_ url: URL, session: URLSession = .shared) {
        self.url = url
        self.session = session
    }
    
    /// Establishes a connection with the server at the configured URL.
    func connect() {
        resume()
    }
    
    /// Disconnects the socket from the server.
    /// - Parameters:
    ///   - closeCode: The type of closure that is being requested.
    ///   - reason: The reason for the closure.
    func disconnect(closeCode: URLSessionWebSocketTask.CloseCode = .normalClosure, reason: Data? = nil) {
        webSocketTask.cancel(with: closeCode, reason: reason)

        // reset after disconnecting to be ready for reconnecting
        let task = session.webSocketTask(with: url)
        task.delegate = self
        webSocketTask = task

        let reasonString: String?
        if let reason {
            reasonString = String(decoding: reason, as: UTF8.self)
        } else {
            reasonString = nil
        }
        subject.send(.disconnected(closeCode, reasonString))
    }
    
    /// Sends a message through the socket to the server.
    /// - Parameter message: The message to send to the server.
    func send(_ message: URLSessionWebSocketTask.Message) {
        webSocketTask.send(message) { [weak self] error in
            if let error {
                self?.subject.send(.error(error))
            }
        }
    }

    private func resume() {
        webSocketTask.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.subject.send(.message(message))
                self?.resume()
            case .failure(let error):
                self?.subject.send(.error(error))
            }
        }

        webSocketTask.resume()
    }

    // MARK: - URLSessionWebSocketDelegate

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol theProtocol: String?) {
        subject.send(.connected)
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        disconnect(closeCode: closeCode, reason: reason)
    }
}
