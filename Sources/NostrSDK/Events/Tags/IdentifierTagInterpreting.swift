//
//  IdentifierTagInterpreting.swift
//  
//
//  Created by Terry Yiu on 12/16/23.
//

import Foundation

public protocol IdentifierTagInterpreting: NostrEvent {}
public extension IdentifierTagInterpreting {
    /// The identifier of the event. For parameterized replaceable events, this identifier remains stable across replacements.
    /// This identifier is represented by the "d" tag, which is distinctly different from the `id` field on ``NostrEvent``.
    var identifier: String? {
        firstValueForTagName(.identifier)
    }
}
