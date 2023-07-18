//
//  NIP05VerificationView.swift
//  NostrSDKDemo
//
//  Created by Joel Klabo on 6/15/23.
//

import SwiftUI
import NostrSDK

struct NIP05VerficationView: View {

    @State private var identifier: String = ""
    @State private var pubkeyResult: String?
    @State private var validationKey: String = ""
    @State private var relays: [String] = []
    @State private var relayErrorString: String?
    @State private var validationResult: String?
    @State private var hasQueriedRelays = false

    private let validator = Validator()

    var body: some View {
        Form {

            Section("NIP-05 Identifier") {
                TextField(text: $identifier) {
                    Text("NIP-05 Identifier")
                }
                .autocorrectionDisabled()
                .autocapitalization(.none)
            }

            Section("Query Public Key") {
                Button {
                    Task {
                        do {
                            pubkeyResult = try await validator.pubkeyForNIP05Identifier(identifier) ?? ""
                        } catch {
                            pubkeyResult = error.localizedDescription
                        }
                    }
                } label: {
                    Text("Get Pubkey")
                }

                if let pubkeyResult  {
                    Text(pubkeyResult)
                        .textSelection(.enabled)
                }
            }

            Section("Query Relays URLs") {
                Button {
                    hasQueriedRelays = true
                    Task {
                        do {
                            relays = try await validator.relayURLsForNIP05Identifier(identifier) ?? []
                        } catch {
                            relayErrorString = error.localizedDescription
                        }
                    }
                } label: {
                    Text("Get Relays")
                }
                if relays.count > 0 {
                    List(relays, id: \.self) { item in
                        Text(item)
                    }
                } else if hasQueriedRelays {
                    Text(relayErrorString ?? "No relays found")
                        .textSelection(.enabled)
                }
            }

            Section("Validate Public Key") {
                TextField(text: $validationKey) {
                    Text("Hex Public Key to Validate")
                }
                Button {
                    Task {
                        do {
                            try await validator.validateNIP05Identifier(identifier, pubkey: validationKey)
                            validationResult = "Valid"
                        } catch {
                            validationResult = "Invalid: \(error.localizedDescription)"
                        }
                    }
                } label: {
                    Text("Validate")
                }

                if let validationResult {
                    Text(validationResult)
                        .textSelection(.enabled)
                }
            }
        }
    }
}

struct Validator: NIP05Validating, NIP05DataRequesting {}

struct NIP05VerficationView_Previews: PreviewProvider {
    static var previews: some View {
        NIP05VerficationView()
    }
}
