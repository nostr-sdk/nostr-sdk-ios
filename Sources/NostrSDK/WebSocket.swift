//
//  WebSocket.swift
//
//
//  Created by Bryan Montz on 4/13/23.
//

import Combine
import Foundation

enum WebSocketEvent: CustomStringConvertible {
    case connected
    case message(URLSessionWebSocketTask.Message)
    case disconnected(URLSessionWebSocketTask.CloseCode, String?)
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

final class WebSocket: NSObject, URLSessionWebSocketDelegate {

    private let url: URL
    private let session: URLSession
    private lazy var webSocketTask: URLSessionWebSocketTask = {
        let task = session.webSocketTask(with: url)
        task.delegate = self
        return task
    }()

    let subject = PassthroughSubject<WebSocketEvent, Never>()

    init(_ url: URL, session: URLSession = .shared) {
        self.url = url
        self.session = session
    }

    func ping(receiveHandler: @escaping (Error?) -> Void) {
        webSocketTask.sendPing(pongReceiveHandler: receiveHandler)
    }

    func connect() {
        resume()
    }

    func disconnect(closeCode: URLSessionWebSocketTask.CloseCode = .normalClosure, reason: Data? = nil) {
        webSocketTask.cancel(with: closeCode, reason: reason)

        // reset after disconnecting to be ready for reconnecting
        let task = session.webSocketTask(with: url)
        task.delegate = self
        webSocketTask = task

        let reasonString: String?
        if let reason {
            reasonString = String(data: reason, encoding: .utf8)
        } else {
            reasonString = nil
        }
        subject.send(.disconnected(closeCode, reasonString))
    }

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
