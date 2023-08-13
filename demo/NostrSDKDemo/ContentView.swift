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
                ConnectRelayView(relay: $relay)
                List {
                    ListOptionView(destinationView: AnyView(QueryRelayDemoView(relay: $relay)),
                                   imageName: "list.bullet.rectangle.portrait",
                                   labelText: "Query relay")
                    ListOptionView(destinationView: AnyView(GenerateKeyDemoView()),
                                   imageName: "key",
                                   labelText: "Key Generation")
                    ListOptionView(destinationView: AnyView(NIP05VerficationDemoView()),
                                   imageName: "checkmark.seal",
                                   labelText: "NIP-05")
                }
            }
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
