//
//  PubkeyTag.swift
//  
//
//  Created by Terry Yiu on 11/15/23.
//

import Foundation

/// A public key provider.
public protocol PubkeyProviding {
    /// The public key.
    var pubkey: PublicKey? { get }
}
