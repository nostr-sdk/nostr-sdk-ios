//
//  EncryptMessageDemoView.swift
//  NostrSDKDemo
//
//  Created by Fabian Lachman on 31/12/24.
//

import SwiftUI
import NostrSDK

struct EncryptMessageDemoView: View, EventCreating {

    @EnvironmentObject var relayPool: RelayPool

    @State private var recipientPublicKey = ""
    @State private var recipientPublicKeyIsValid: Bool = false

    @State private var senderPrivateKey = ""
    @State private var senderPrivateKeyIsValid: Bool = false

    @State private var message: String = ""
    @State private var encryptedMessage: String = ""

    var body: some View {
        Form {
            Text("Encrypt Demo")
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
            Button("Encrypt") {
                guard let recipientPublicKey = publicKey(),
                      let senderKeyPair = keypair() else {
                    return
                }
                do {
                    encryptedMessage = try encrypt(plaintext: message, privateKeyA: senderKeyPair.privateKey, publicKeyB: recipientPublicKey)
                } catch {
                    encryptedMessage = ""
                    print(error.localizedDescription)
                }
            }
            .disabled(!ready())
            
            if encryptedMessage != "" {
                Section("Encrypted Message") {
                    TextField("Encrypted Message", text: $encryptedMessage)
                }
            }
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

    private func ready() -> Bool {
        !message.isEmpty &&
        recipientPublicKeyIsValid &&
        senderPrivateKeyIsValid
    }
}

struct EncryptDecryptDemoView_Previews: PreviewProvider {
    static var previews: some View {
        EncryptMessageDemoView()
    }
}
