//
//  RelayProviding.swift
//
//
//  Created by Terry Yiu on 11/15/23.
//

import Foundation

/// A relay provider.
public protocol RelayProviding {
    /// The URL of the relay.
    var relayURL: URL? { get }
}
