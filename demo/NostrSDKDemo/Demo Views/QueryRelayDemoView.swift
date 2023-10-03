//
//  QueryRelayDemoView.swift
//  NostrSDKDemo
//
//  Created by Joel Klabo on 6/15/23.
//

import SwiftUI
import NostrSDK
import Combine

struct QueryRelayDemoView: View {

    @Binding var relay: Relay?

    @State private var authorPubkey: String = ""
    @State private var events: [NostrEvent] = []
    @State private var eventsCancellable: AnyCancellable?
    @State private var errorString: String?
    @State private var subscriptionId: String?

    private let kindOptions = [0, 1, 2]

    @State private var selectedKind = 1

    var body: some View {
        RelayFormView(relay: $relay) {
            Section("Query Relay") {

                TextField(text: $authorPubkey) {
                    Text("Author Public Key (HEX)")
                }

                Picker("Kind", selection: $selectedKind) {
                    ForEach(kindOptions, id: \.self) { number in
                        Text("\(number)")
                    }
                }
            }

            Button {
                updateSubscription()
            } label: {
                Text("Query")
            }

            if !events.isEmpty {
                Section("Results") {
                    if !authorPubkey.isEmpty {
                        Text("Note: send an event from this account and see it appear here.")
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }
                    List(events, id: \.id) { event in
                        Text("\(event.content)")
                    }
                }
            }
        }
        .onChange(of: authorPubkey) { _ in
            events = []
            updateSubscription()
        }
        .onChange(of: selectedKind) { _ in
            events = []
            updateSubscription()
        }
    }
    
    private var currentFilter: Filter {
        let authors: [String]?
        if authorPubkey.isEmpty {
            authors = nil
        } else {
            authors = [authorPubkey]
        }
        return Filter(authors: authors, kinds: [selectedKind])
    }
    
    private func updateSubscription() {
        do {
            if let subscriptionId {
                try relay?.closeSubscription(with: subscriptionId)
            }
            
            subscriptionId = try relay?.subscribe(with: currentFilter)
            
            eventsCancellable = relay?.events
                .receive(on: DispatchQueue.main)
                .map {
                    $0.event
                }
                .sink { event in
                    events.insert(event, at: 0)
                }
        } catch {
            errorString = error.localizedDescription
        }
    }
}

struct QueryRelayView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            QueryRelayDemoView(relay: DemoHelper.previewRelay)
        }
    }
}
