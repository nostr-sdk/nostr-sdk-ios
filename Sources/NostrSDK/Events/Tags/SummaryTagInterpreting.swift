//
//  SummaryTagInterpreting.swift
//
//
//  Created by Terry Yiu on 8/4/24.
//

import Foundation

public protocol SummaryTagInterpreting: NostrEvent {}
public extension SummaryTagInterpreting {
    /// The summary of the content.
    var summary: String? {
        firstValueForTagName(.summary)
    }
}
