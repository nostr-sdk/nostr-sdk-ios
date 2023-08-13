//
//  Helpers.swift
//  NostrSDKDemo
//
//  Created by Joel Klabo on 8/12/23.
//

import SwiftUI
import NostrSDK

struct DemoHelper {
    static var emptyString: Binding<String> {
        Binding.constant("")
    }
    static var previewRelay: Binding<Relay?> {
        let urlString = "wss://relay.damus.io"

        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL: \(urlString)")
        }
        // If the Relay initializer throws an error, replace 'try?' with your error handling.
        let relay = try? Relay(url: url)

        return Binding.constant(relay)
    }
    static var validNpub: Binding<String> {
        Binding.constant("npub1n9rljevamqxrdqjq9dsj74z8u2pynxtlkdcf2qxr9fv9avyhwdqqf6w3at")
    }
    static var validNsec: Binding<String> {
        Binding.constant("nsec163p74rxf58ndvav7ck8axx39qmt6dvwjgm8z98ckanenzf3mpjyq6875fz")
    }
    static var validHexPublicKey: Binding<String> {
        Binding.constant("9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
    }
    static var validHexPrivateKey: Binding<String> {
        Binding.constant("d443ea8cc9a1e6d6759ec58fd31a2506d7a6b1d246ce229f16ecf331263b0c88")
    }
    static var invalidKey: Binding<String> {
        Binding.constant("not-valid")
    }
}
