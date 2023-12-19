//
//  ReferenceTagInterpreting.swift
//
//
//  Created by Terry Yiu on 11/16/23.
//

import Foundation

/// Interprets reference tags on events. References are URLs.
public protocol ReferenceTagInterpreting: NostrEvent {}
public extension ReferenceTagInterpreting {
    /// The reference URLs of the event.
    var references: [URL] {
        allValues(forTagName: .webURL)?.compactMap { URL(string: $0) } ?? []
    }
}
