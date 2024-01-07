//
//  NostrSDKDemoApp.swift
//  NostrSDKDemo
//
//  Created by Honk on 6/10/23.
//

import NostrSDK
import SwiftUI

@main
struct NostrSDKDemoApp: App {
    @StateObject var relayPool = try! RelayPool(relayURLs: [
        URL(string: "wss://relay.damus.io")!,
        URL(string: "wss://relay.snort.social")!,
        URL(string: "wss://nos.lol")!
    ])
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(relayPool)
        }
    }
}
