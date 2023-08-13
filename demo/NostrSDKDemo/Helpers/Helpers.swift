//
//  Helpers.swift
//  NostrSDKDemo
//
//  Created by Joel Klabo on 8/12/23.
//

import SwiftUI
import NostrSDK

struct DemoHelper {
    static var previewRelay: Binding<Relay?> {
        let urlString = "wss://relay.damus.io"

        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL: \(urlString)")
        }
        // If the Relay initializer throws an error, replace 'try?' with your error handling.
        let relay = try? Relay(url: url)

        return Binding.constant(relay)
    }
}
