//
//  ConnectRelayView.swift
//  NostrSDKDemo
//
//  Created by Joel Klabo on 8/12/23.
//

import SwiftUI
import NostrSDK
import Combine

struct ConnectRelayView: View {

    @Binding var relay: Relay?

    @State private var relayURLString = "wss://relay.damus.io"
    @State private var relayError: String?
    @State private var state: Relay.State = .notConnected
    @State private var stateCancellable: AnyCancellable?

    var body: some View {
        VStack(spacing: 12) {
            if relay?.state == .connected {
                Text("Connected to: \(relayURLString)")
                    .font(.footnote)
                Button(role: .destructive) {
                    relay?.disconnect()
                } label: {
                    Text("Disconnect")
                }
            } else {
                TextField(text: $relayURLString) {
                    Text("wss://relay.damus.io")
                }
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .autocorrectionDisabled()

                Button("Connect") {
                    attemptRelayConnect()
                }
                Text(relayError ?? status(state))
            }
        }
        .padding()
        .onAppear {
            attemptRelayConnect()
        }
    }

    private func attemptRelayConnect() {
        if let relayURL = URL(string: relayURLString.lowercased()) {
            do {
                relay = try Relay(url: relayURL)
                relay?.connect()
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
        NavigationView {
            ConnectRelayView(relay: DemoHelper.previewRelay)
        }
    }
}
