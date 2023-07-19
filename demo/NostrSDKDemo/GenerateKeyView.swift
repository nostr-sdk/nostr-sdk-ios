//
//  GenerateKeyView.swift
//  NostrSDKDemo
//
//  Created by Joel Klabo on 6/14/23.
//

import SwiftUI
import NostrSDK

struct GenerateKeyView: View {

    @State private var privateKey: String?
    @State private var publicKey: String?
    @State private var nsec: String?
    @State private var npub: String?

    private let noValueString = "Must generate key"

    var body: some View {
        Form {
            Button("Generate Key") {
                let keypair = Keypair()
                privateKey = keypair?.privateKey.hex ?? ""
                publicKey = keypair?.publicKey.hex ?? ""
                nsec = keypair?.privateKey.nsec ?? ""
                npub = keypair?.publicKey.npub
            }
            Section("Private Key") {
                Text(privateKey ?? noValueString)
            }
            Section("Public Key") {
                Text(publicKey ?? noValueString)
            }
            Section("nsec") {
                Text(nsec ?? noValueString)
            }
            Section("npub") {
                Text(npub ?? noValueString)
            }
        }
    }
}

struct GenerateKeyView_Previews: PreviewProvider {
    static var previews: some View {
        GenerateKeyView()
    }
}
