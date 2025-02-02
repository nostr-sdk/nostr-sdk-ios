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
    @State private var text: String = "Hello, world!"
    @State private var signedEvent: String = ""
    @State private var isShareSheetPresented: Bool = false

    var body: some View {
        Form {
            Section("npub") {
                Text(npub)
            }

            Section("Text to sign") {
                TextField("Text to sign", text: $text)
                    .lineLimit(5)
            }

            Button("Sign Event") {
                isShareSheetPresented = true
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            Section("Signed Event") {
                Text(signedEvent)
            }
        }
        .sheet(isPresented: $isShareSheetPresented) {
            if let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
                Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
                let signableNostrEvent = SignableNostrEvent(
                    createdAt: Int64(Date.now.timeIntervalSince1970),
                    kind: .textNote,
                    tags: [],
                    content: "Hello, world!"
                )

                if let eventJSON = try? JSONEncoder().encode(signableNostrEvent),
                   let stringifiedJSON = String(data: eventJSON, encoding: .utf8) {
//                    let getPublicKeyRequest = NostrSignerRequest(type: .getPublicKey, returnType: .event, payload: nil)
                    let signEventRequest = NostrSignerRequest(
                        type: .signEvent,
                        returnType: .event,
                        payload: stringifiedJSON
                    )
                    let requests = NostrSignerRequests(
                        requests: [/*getPublicKeyRequest, */signEventRequest],
                        source: appName
                    )
                    if let requestsJSON = try? JSONEncoder().encode(requests) {
                        ShareSheet(items: [requestsJSON], signedEvent: $signedEvent)
                    }
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

                guard let extensionItem: NSExtensionItem = items[0] as? NSExtensionItem
                else {
                    return
                }

                let itemProvider = extensionItem.attachments![0]

                if itemProvider.hasItemConformingToTypeIdentifier(UTType.data.identifier) {
                    itemProvider.loadItem(
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
