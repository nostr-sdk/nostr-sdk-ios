//
//  KeyInputSectionView.swift
//  NostrSDKDemo
//
//  Created by Joel Klabo on 8/13/23.
//

import SwiftUI
import NostrSDK

enum KeyType {
    case `public`
    case `private`
}

struct KeyInputSectionView: View {
    
    @Binding var key: String
    @Binding var isValid: Bool

    var type: KeyType

    var body: some View {
        HStack {
            TextField(label(for: type),
                      text: $key)
                .font(.system(size: 16, weight: .regular, design: .monospaced))
                .autocapitalization(.none)
                .autocorrectionDisabled()

            if key.isEmpty {
                EmptyView()
            } else if isValid {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "x.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .onChange(of: key) { newValue in
            isValid = checkValidity(key: key, type: type)
        }
        .onAppear {
            isValid = checkValidity(key: key, type: type)
        }
    }

    private func label(for type: KeyType) -> String {
        switch type {
        case .public:
            return "Public Key"
        case .private:
            return "Private Key"
        }
    }

    private func checkValidity(key: String, type: KeyType) -> Bool {
        switch type {
        case .public:
            return checkValidity(publicKey: key)
        case .private:
            return checkValidity(privateKey: key)
        }
    }

    private func checkValidity(publicKey: String) -> Bool {
        if publicKey.contains("npub") {
            if let _ = PublicKey(npub: publicKey) {
                return true
            } else {
                return false
            }
        } else {
            if let _ = PublicKey(hex: publicKey) {
                return true
            } else {
                return false
            }
        }
    }

    private func checkValidity(privateKey: String) -> Bool {
        if privateKey.contains("nsec") {
            if let _ = PrivateKey(nsec: privateKey) {
                return true
            } else {
                return false
            }
        } else {
            if let _ = PrivateKey(hex: privateKey) {
                return true
            } else {
                return false
            }
        }
    }
}

struct KeyInputSectionView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            Section("Public") {
                KeyInputSectionView(key: DemoHelper.emptyString,
                                    isValid: Binding.constant(true),
                                    type: .public)
                KeyInputSectionView(key: DemoHelper.validNpub,
                                    isValid: Binding.constant(true),
                                    type: .public)
                KeyInputSectionView(key: DemoHelper.validHexPublicKey,
                                    isValid: Binding.constant(true),
                                    type: .public)
                KeyInputSectionView(key: DemoHelper.invalidKey,
                                    isValid: Binding.constant(false),
                                    type: .public)
            }
            Section("Private") {
                KeyInputSectionView(key: DemoHelper.emptyString,
                                    isValid: Binding.constant(true),
                                    type: .private)
                KeyInputSectionView(key: DemoHelper.validNsec,
                                    isValid: Binding.constant(true),
                                    type: .private)
                KeyInputSectionView(key: DemoHelper.validHexPrivateKey,
                                    isValid: Binding.constant(true),
                                    type: .private)
                KeyInputSectionView(key: DemoHelper.invalidKey,
                                    isValid: Binding.constant(false),
                                    type: .private)
            }
        }
    }
}
