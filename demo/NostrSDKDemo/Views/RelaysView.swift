//
//  RelaysView.swift
//  NostrSDKDemo
//
//  Created by Bryan Montz on 1/1/24.
//

import Foundation
import NostrSDK
import SwiftUI

extension Relay {
    var statusImage: some View {
        switch state {
        case .connected: return Image(systemName: "checkmark.circle").foregroundStyle(.green)
        default:        return Image(systemName: "questionmark.circle").foregroundStyle(.yellow)
        }
    }
}

struct RelaysView: View {
    
    @EnvironmentObject var pool: RelayPool
    
    var body: some View {
        List {
            ForEach(relays, id: \.url) { relay in
                HStack {
                    Text(relay.url.absoluteString)
                    Spacer()
                    relay.statusImage
                }
            }
            .onDelete(perform: remove)
        }
        .navigationTitle("Relays")
        .toolbar {
            EditButton()
        }
    }
    
    private var relays: [Relay] {
        pool.relays.sorted()
    }
    
    private func remove(at offsets: IndexSet) {
        guard let index = offsets.first else {
            return
        }
        let relay = relays[index]
        pool.remove(relay: relay)
    }
}
