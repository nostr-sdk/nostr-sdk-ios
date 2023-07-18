//
//  ListOptionView.swift
//  NostrSDKDemo
//
//  Created by Joel Klabo on 6/14/23.
//

import SwiftUI

struct ListOptionView: View {
    var destinationView: AnyView
    var imageName: String
    var labelText: String

    var body: some View {
        NavigationLink(destination: destinationView) {
            Label(labelText, systemImage: imageName)
        }
    }
}

struct ListOptionView_Previews: PreviewProvider {
    static var previews: some View {
        ListOptionView(destinationView: AnyView(GenerateKeyView()), imageName: "key", labelText: "Key Generation")
    }
}

