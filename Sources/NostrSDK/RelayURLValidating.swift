//
//  RelayURLValidating.swift
//
//
//  Created by Terry Yiu on 12/18/23.
//

import Foundation

public protocol RelayURLValidating {}
public extension RelayURLValidating {

    /// Validates that a URL string is well-formatted as a relay URL and returns it if it is valid.
    /// - Parameters:
    ///   - relayURLString: The URL string.
    /// - Returns: The ``URL`` of the relay if it is well-formatted.
    /// - Throws: URLError.Code.badURL,  RelayURLError.invalidScheme
    func validateRelayURLString(_ relayURLString: String) throws -> URL {
        guard let url = URL(string: relayURLString) else {
            throw URLError(.badURL)
        }

        try validateRelayURL(url)

        return url
    }

    /// Validates that a URL string is well-formatted as a relay URL.
    /// - Parameters:
    ///   - relayURLString: The URL string.
    /// - Throws: URLError.Code.badURL,  RelayURLError.invalidScheme
    func validateRelayURL(_ relayURL: URL) throws {
        guard let components = URLComponents(url: relayURL, resolvingAgainstBaseURL: false) else {
            throw URLError(.badURL)
        }

        guard components.scheme == "wss" || components.scheme == "ws" else {
            throw RelayURLError.invalidScheme
        }
    }
}

/// Validates that a relay URL is well-formed.
/// This class is exposed so that relay URLs may be validated in initializers.
/// Outside of initializers, the ``RelayURLValidating`` extension should be used instead.
final class RelayURLValidator: RelayURLValidating {
    static let shared = RelayURLValidator()
}
