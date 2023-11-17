//
//  RelayTagParameter.swift
//
//
//  Created by Terry Yiu on 11/15/23.
//

import Foundation

/// A relay tag parameter. This parameter may appear as metadata to various tags, such as pubkey tags and event tags.
public protocol RelayTagParameter {
    var relay: URL? { get }
}
