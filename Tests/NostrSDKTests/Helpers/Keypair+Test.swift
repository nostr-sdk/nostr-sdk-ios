//
//  Keypair+Test.swift
//
//
//  Created by Bryan Montz on 6/23/23.
//

import Foundation
import NostrSDK

extension Keypair {
    
    /// A ``Keypair`` for use in unit tests
    ///
    /// The corresponding npub is npub1n9rljevamqxrdqjq9dsj74z8u2pynxtlkdcf2qxr9fv9avyhwdqqf6w3at.
    static var test: Keypair {
        Keypair(nsec: "nsec163p74rxf58ndvav7ck8axx39qmt6dvwjgm8z98ckanenzf3mpjyq6875fz")!
    }
}
