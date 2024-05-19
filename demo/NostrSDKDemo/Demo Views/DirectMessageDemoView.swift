//
//  DirectMessageDemoView.swift
//  NostrSDKDemo
//
//  Created by Honk on 8/13/23.
//

import SwiftUI
import NostrSDK

struct DirectMessageDemoView: View, EventCreating {

    @EnvironmentObject var relayPool: RelayPool

    @State private var recipientPublicKey = ""
    @State private var recipientPublicKeyIsValid: Bool = false

    @State private var senderPrivateKey = ""
    @State private var senderPrivateKeyIsValid: Bool = false

    @State private var message: String = ""

    var body: some View {
        Form {
            Section("Recipient") {
                KeyInputSectionView(key: $recipientPublicKey,
                                    isValid: $recipientPublicKeyIsValid,
                                    type: .public)
            }
            Section("Sender") {
                KeyInputSectionView(key: $senderPrivateKey,
                                    isValid: $senderPrivateKeyIsValid,
                                    type: .private)
            }
            Section("Message") {
                TextField("Enter a message.", text: $message)
            }
            Button("Send") {
                guard let recipientPublicKey = publicKey(),
                      let senderKeyPair = keypair() else {
                    return
                }
                do {
                    let directMessage = try directMessage(withContent: message,
                                                          toRecipient: recipientPublicKey,
                                                          signedBy: senderKeyPair)
                    relayPool.publishEvent(directMessage)
                } catch {
                    print(error.localizedDescription)
                }
            }
            .disabled(!readyToSend())
        }
    }

    private func keypair() -> Keypair? {
        if senderPrivateKey.contains("nsec") {
            return Keypair(nsec: senderPrivateKey)
        } else {
            return Keypair(hex: senderPrivateKey)
        }
    }

    private func publicKey() -> PublicKey? {
        if recipientPublicKey.contains("npub") {
            return PublicKey(npub: recipientPublicKey)
        } else {
            return PublicKey(hex: recipientPublicKey)
        }
    }

    private func readyToSend() -> Bool {
        !message.isEmpty &&
        recipientPublicKeyIsValid &&
        senderPrivateKeyIsValid
    }
}

struct DirectMessageDemoView_Previews: PreviewProvider {
    static var previews: some View {
        DirectMessageDemoView()
    }
}
