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
    @State private var stateCancellable: AnyCancellable?
    @State private var eventsCancellable: AnyCancellable?
    @State private var errorString: String?

    private let kindOptions = [0, 1, 2]

    @State private var selectedKind = 1

    var body: some View {
        Form {
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
                    .onChange(of: selectedKind) { _ in
                        events = []
                    }

                    Button {
                        do {
                            let filter = Filter(authors: [authorPubkey], kinds: [selectedKind])
                            try relay?.subscribe(with: filter)

                            eventsCancellable = relay?.events
                                .receive(on: DispatchQueue.main)
                                .sink { event in
                                    events.insert(event, at: 0)
                                }
                        } catch {
                            errorString = error.localizedDescription
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
            } else {
                Text(errorString ?? "Must connect to relay")
                    .foregroundColor(.red)
            }
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
