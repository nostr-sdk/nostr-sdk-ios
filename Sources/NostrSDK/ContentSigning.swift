//
//  ContentSigning.swift
//
//
//  Created by Bryan Montz on 6/20/23.
//

import Foundation
import secp256k1

public protocol ContentSigning {}
public extension ContentSigning {
    
    /// Produces a Schnorr signature of the provided `content` using the `privateKey`.
    ///
    /// - Parameters:
    ///   - content: The content to sign.
    ///   - privateKey: A private key to sign the content with.
    /// - Returns: The signature.
    func signatureForContent(_ content: String, privateKey: String) throws -> String {
        let privateKeyBytes = try privateKey.bytes
        let signingKey = try secp256k1.Schnorr.PrivateKey(dataRepresentation: privateKeyBytes)
        var contentBytes = try content.bytes
        var rand = Data.randomBytes(count: 64)
        let signature = try signingKey.signature(message: &contentBytes, auxiliaryRand: &rand)
        return signature.dataRepresentation.hexString
    }
}

extension PrivateKey: ContentSigning {
    func signatureForContent(_ content: String) throws -> String {
        try signatureForContent(content, privateKey: hex)
    }
}
