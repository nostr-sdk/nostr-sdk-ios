//
//  PubkeyTag.swift
//  
//
//  Created by Terry Yiu on 11/15/23.
//

import Foundation

/// A public key tag.
public protocol PubkeyTag {
    /// The pubkey of a tag.
    var pubkey: PublicKey? { get }
}
