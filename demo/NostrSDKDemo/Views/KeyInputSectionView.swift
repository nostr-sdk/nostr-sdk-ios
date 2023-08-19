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
    var label: String {
        switch self {
        case .public: return "Public Key"
        case .private: return "Private Key"
        }
    }
}

struct KeyInputSectionView: View {
    
    @Binding var key: String
    @Binding var isValid: Bool

    var type: KeyType

    var body: some View {
        HStack {
            TextField(type.label,
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
        .onChange(of: key) { _ in
            isValid = isKeyValid(key, type: type)
        }
        .onAppear {
            isValid = isKeyValid(key, type: type)
        }
    }

    private func isKeyValid(_ key: String, type: KeyType) -> Bool {
        switch type {
        case .public:
            return isValid(publicKey: key)
        case .private:
            return isValid(privateKey: key)
        }
    }

    private func isValid(publicKey: String) -> Bool {
        if publicKey.contains("npub") {
            return PublicKey(npub: publicKey) != nil
        } else {
            return PublicKey(hex: publicKey) != nil
        }
    }

    private func isValid(privateKey: String) -> Bool {
        if privateKey.contains("nsec") {
            return PrivateKey(nsec: privateKey) != nil
        } else {
            return PrivateKey(hex: privateKey) != nil
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
