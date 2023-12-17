//
//  Keypair+Test.swift
//
//
//  Created by Bryan Montz on 6/23/23.
//

import Foundation
import NostrSDK

extension Keypair {
    
    /// A ``Keypair`` for use in unit tests.
    ///
    /// The corresponding npub is `npub1n9rljevamqxrdqjq9dsj74z8u2pynxtlkdcf2qxr9fv9avyhwdqqf6w3at`.
    ///
    /// The Nostr SDK project and its maintainers take no responsibility of events signed with this private key which has been open sourced.
    /// Its purpose is for only testing and demos.
    static var test: Keypair {
        Keypair(nsec: "nsec163p74rxf58ndvav7ck8axx39qmt6dvwjgm8z98ckanenzf3mpjyq6875fz")!
    }
}
