//
//  QueryRelayView.swift
//  NostrSDKDemo
//
//  Created by Joel Klabo on 6/15/23.
//

import SwiftUI
import NostrSDK
import Combine

struct QueryRelayView: View {

    @State private var relayURLString = ""
    @State private var relay: Relay?
    @State private var relayError: String?
    @State private var state: Relay.State = .notConnected
    @State private var authorPubkey: String = ""
    @State private var events: [NostrEvent] = []
    @State private var stateCancellable: AnyCancellable?
    @State private var eventsCancellable: AnyCancellable?

    private let kindOptions = [0, 1, 2]

    @State private var selectedKind = 1

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

            if relay?.state == .connected {
                Section("Query Relay") {

                    TextField(text: $authorPubkey) {
                        Text("Author Public Key (HEX)")
                    }

                    Picker("Kind", selection: $selectedKind) {
                        ForEach(kindOptions, id: \.self) { number in
                            Text("\(number)")
                        }
                    }
                    .onChange(of: selectedKind) { newValue in
                        events = []
                    }

                    Button {
                        do {
                            guard let relay else {
                                relayError = "No relay"
                                return
                            }
                            let filter = Filter(authors: [authorPubkey], kinds: [selectedKind])
                            try relay.subscribe(with: filter)

                            eventsCancellable = relay.events
                                .receive(on: DispatchQueue.main)
                                .sink { event in
                                    events.insert(event, at: 0)
                                }
                        } catch {
                            relayError = error.localizedDescription
                        }
                    } label: {
                        Text("Query")
                    }
                }

                if events.count > 0 {
                    Section("Results") {
                        Text("Note: send an event from this account and see it appear here.")
                            .foregroundColor(.gray)
                            .font(.footnote)
                        List(events, id: \.id) { event in
                            Text("\(event.content)")
                        }
                    }
                }
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

struct QueryRelayView_Previews: PreviewProvider {
    static var previews: some View {
        QueryRelayView()
    }
}
