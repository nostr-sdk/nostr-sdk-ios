//
//  RelayFormView.swift
//  NostrSDKDemo
//
//  Created by Joel Klabo on 8/13/23.
//

import SwiftUI
import NostrSDK

struct RelayFormView<Content: View>: View {

    @Binding var relay: Relay?

    @State private var errorString: String?

    let content: () -> Content

    init(relay: Binding<Relay?>, @ViewBuilder content: @escaping () -> Content) {
        self._relay = relay
        self.content = content
    }

    var body: some View {
        Form {
            if relay?.state == .connected {
                content()
            } else {
                Section("Error") {
                    Text(errorString ?? "Must connect to relay")
                        .foregroundColor(.red)
                }
            }
        }
    }
}
