//
//  ContentView.swift
//  NostrSDKDemo
//
//  Created by Joel Klabo on 6/10/23.
//

import SwiftUI
import NostrSDK

struct ContentView: View {

    var body: some View {
        NavigationView {
            List {
                ListOptionView(destinationView: AnyView(ConnectRelayView()),
                               imageName: "powerplug",
                               labelText: "Connect to relay")
                ListOptionView(destinationView: AnyView(QueryRelayView()),
                               imageName: "list.bullet.rectangle.portrait",
                               labelText: "Query relay")
                ListOptionView(destinationView: AnyView(GenerateKeyView()),
                               imageName: "key",
                               labelText: "Key Generation")
                ListOptionView(destinationView: AnyView(NIP05VerficationView()),
                               imageName: "checkmark.seal",
                               labelText: "NIP-05")
            }
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
