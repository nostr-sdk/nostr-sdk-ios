//
//  DecryptMessageDemoView.swift
//  NostrSDKDemo
//
//  Created by Fabian Lachman on 31/12/24.
//

import SwiftUI
import NostrSDK

struct DecryptMessageDemoView: View, EventCreating {

    @EnvironmentObject var relayPool: RelayPool

    @State private var senderPublicKey = ""
    @State private var senderPublicKeyIsValid: Bool = false

    @State private var receiverPrivateKey = ""
    @State private var receiverPrivateKeyIsValid: Bool = false

    @State private var encryptedMessage: String = ""
    @State private var message: String = ""

    var body: some View {
        Form {
            Text("Decrypt Demo")
            Section("Sender") {
                KeyInputSectionView(key: $senderPublicKey,
                                    isValid: $senderPublicKeyIsValid,
                                    type: .public)
            }
            Section("Receiver") {
                KeyInputSectionView(key: $receiverPrivateKey,
                                    isValid: $receiverPrivateKeyIsValid,
                                    type: .private)
            }
            Section("Encrypted Message") {
                TextField("Enter encrypted message.", text: $encryptedMessage)
            }
            Button("Decrypt") {
                guard let senderPublicKey = publicKey(),
                      let receiverPrivateKey = keypair() else {
                    return
                }
                do {
                    message = try decrypt(payload: encryptedMessage, privateKeyA: receiverPrivateKey.privateKey, publicKeyB: senderPublicKey)
                } catch {
                    message = ""
                    print(error.localizedDescription)
                }
            }
            .disabled(!ready())
            
            if message != "" {
                Section("Decrypted Message") {
                    TextField("Decrypted Message", text: $message)
                }
            }
        }
    }

    private func keypair() -> Keypair? {
        if receiverPrivateKey.contains("nsec") {
            return Keypair(nsec: receiverPrivateKey)
        } else {
            return Keypair(hex: receiverPrivateKey)
        }
    }

    private func publicKey() -> PublicKey? {
        if senderPublicKey.contains("npub") {
            return PublicKey(npub: senderPublicKey)
        } else {
            return PublicKey(hex: senderPublicKey)
        }
    }

    private func ready() -> Bool {
        !encryptedMessage.isEmpty &&
        senderPublicKeyIsValid &&
        receiverPrivateKeyIsValid
    }
}

struct DecryptMessageDemoView_Previews: PreviewProvider {
    static var previews: some View {
        DecryptMessageDemoView()
    }
}
