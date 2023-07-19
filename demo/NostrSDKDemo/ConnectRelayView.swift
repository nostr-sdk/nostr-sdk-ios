//
//  ConnectRelayView.swift
//  NostrSDKDemo
//
//  Created by Honk on 6/14/23.
//

import SwiftUI
import NostrSDK
import Combine

struct ConnectRelayView: View {

    @State private var relayURLString = ""
    @State private var relay: Relay?
    @State private var relayError: String?
    @State private var state: Relay.State = .notConnected

    @State private var stateCancellable: AnyCancellable?

    var body: some View {
        Form {

            Section("Connect to relay") {
                TextField(text: $relayURLString) {
                    Text("wss://relay.damus.io")
                }
                .autocapitalization(.none)
                .autocorrectionDisabled()

                Button("Connect") {
                    // connect to relay
                    if let relayURL = URL(string: relayURLString.lowercased()) {
                        do {
                            relay = try Relay(url: relayURL)
                            stateCancellable = relay?.$state
                                .receive(on: DispatchQueue.main)
                                .sink { newState in
                                    state = newState
                                }
                        } catch {
                            relayError = error.localizedDescription
                        }
                    } else {
                        relayError = "Invalid URL String"
                    }
                }
                Text(relayError ?? status(state))
            }
        }
    }

    private func status(_ state: Relay.State?) -> String {
        guard let state else {
            return "No status"
        }
        switch state {
        case .notConnected:
            return "Not connected"
        case .connecting:
            return "Connecting"
        case .connected:
            return "Connected"
        case .error(let error):
            return error.localizedDescription
        }
    }
}

struct ConnectRelayView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectRelayView()
    }
}
