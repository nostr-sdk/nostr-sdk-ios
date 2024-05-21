//
//  ContentView.swift
//  NostrSDKDemo
//
//  Created by Joel Klabo on 6/10/23.
//

import SwiftUI
import NostrSDK

struct ContentView: View {

    @State private var relay: Relay?

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ListOptionView(destinationView: AnyView(RelaysView()),
                                   imageName: "network",
                                   labelText: "Configure Relays")
                    ListOptionView(destinationView: AnyView(QueryRelayDemoView()),
                                   imageName: "list.bullet.rectangle.portrait",
                                   labelText: "Query Relays")
                    ListOptionView(destinationView:
                                    AnyView(NIP04DirectMessageDemoView()),
                                   imageName: "list.bullet",
                                   labelText: "NIP-04 Direct Message")
                    ListOptionView(destinationView: AnyView(GenerateKeyDemoView()),
                                   imageName: "key",
                                   labelText: "Key Generation")
                    ListOptionView(destinationView: AnyView(NIP05VerficationDemoView()),
                                   imageName: "checkmark.seal",
                                   labelText: "NIP-05")
                }
            }
            .navigationTitle("Nostr SDK Demo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
