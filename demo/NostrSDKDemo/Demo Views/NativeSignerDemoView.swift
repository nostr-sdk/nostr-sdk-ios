//
//  NativeSignerDemoView.swift
//  NostrSDKDemo
//
//  Created by Terry Yiu on 1/27/25.
//

import NostrSDK
import SwiftUI
import UniformTypeIdentifiers

struct NativeSignerDemoView: View {
    @State private var npub: String = ""
    @State private var text: String = ""
    @State private var signedEvent: String = ""
    @State private var isShareSheetPresented: Bool = false

    var body: some View {
        Form {
            Section("npub") {
                TextField("Public Key", text: $npub)
            }

            Section("Text to sign") {
                TextField("Text to sign", text: $text)
                    .lineLimit(5)
            }

            Button("Sign Event") {
                isShareSheetPresented = true
            }
            .disabled(PublicKey(npub: npub) == nil || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            Section("Signed Event") {
                Text(signedEvent)
            }
        }
        .sheet(isPresented: $isShareSheetPresented) {
            if let publicKey = PublicKey(npub: npub) {
                let textNoteEvent = TextNoteEvent.Builder()
                    .content(text)
                    .build(pubkey: publicKey)
                if let eventJSON = try? JSONEncoder().encode(textNoteEvent),
                   let stringifiedJSON = String(data: eventJSON, encoding: .utf8) {
                    ShareSheet(items: [stringifiedJSON], signedEvent: $signedEvent)
                }
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    @Binding var signedEvent: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)

        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if let items = returnedItems, items.count > 0 {

                guard let textItem: NSExtensionItem = items[0] as? NSExtensionItem
                else {
                    return
                }

                let textItemProvider =
                textItem.attachments![0]

                if textItemProvider.hasItemConformingToTypeIdentifier(
                    UTType.text.identifier) {

                    textItemProvider.loadItem(
                        forTypeIdentifier: UTType.text.identifier,
                        options: nil,
                        completionHandler: {(string, error) -> Void in
                            if let newText = string as? String {
                                DispatchQueue.main.async(execute: {
                                    self.signedEvent = newText
                                })
                            }
                        })
                }
            }
        }

        return activityViewController
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    NativeSignerDemoView()
}
