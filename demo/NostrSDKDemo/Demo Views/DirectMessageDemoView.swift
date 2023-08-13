//
//  DirectMessageDemoView.swift
//  NostrSDKDemo
//
//  Created by Honk on 8/13/23.
//

import SwiftUI
import NostrSDK

struct DirectMessageDemoView: View, EventCreating {

    @Binding var relay: Relay?

    @State private var recipientPublicKey = ""
    @State private var recipientPublicKeyIsValid: Bool = false

    @State private var senderPublicKey = ""
    @State private var senderPublicKeyIsValid: Bool = false

    @State private var senderPrivateKey = ""
    @State private var senderPrivateKeyIsValid: Bool = false

    @State private var message: String = ""

    var body: some View {
        RelayFormView(relay: $relay) {
            Section("Recipient") {
                KeyInputSectionView(key: $recipientPublicKey,
                                    isValid: $recipientPublicKeyIsValid,
                                    type: .public)
            }
            Section("Sender") {
                KeyInputSectionView(key: $senderPublicKey,
                                    isValid: $senderPublicKeyIsValid,
                                    type: .public)
                KeyInputSectionView(key: $senderPrivateKey,
                                    isValid: $senderPrivateKeyIsValid,
                                    type: .private)
            }
            Section("Message") {
                TextField("Enter a message.", text: $message)
            }
            Button("Send") {
//                let directMessage = directmes
            }
            .disabled(!readyToSend())
        }
    }

    private func readyToSend() -> Bool {
        if !message.isEmpty &&
            recipientPublicKeyIsValid &&
            senderPublicKeyIsValid &&
            senderPrivateKeyIsValid {
            return true
        }
        return false
    }
}

struct DirectMessageDemoView_Previews: PreviewProvider {
    static var previews: some View {
        DirectMessageDemoView(relay: DemoHelper.previewRelay)
    }
}
