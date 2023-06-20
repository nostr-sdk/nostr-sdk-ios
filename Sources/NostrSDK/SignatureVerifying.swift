//
//  SignatureVerifying.swift
//  
//
//  Created by Bryan Montz on 6/18/23.
//

import Foundation
import secp256k1

/// An error for specifying different ways signature verification could fail.
public enum SignatureVerifyingError: Error, CustomStringConvertible {
    /// The signature was not the expected length.
    case unexpectedSignatureLength
    /// The public key was not the expected length.
    case unexpectedPublicKeyLength
    /// The message could not be converted to Data.
    case invalidMessage
    /// The signature was not valid.
    case invalidSignature
    
    public var description: String {
        switch self {
        case .unexpectedSignatureLength:    return "The signature was not the expected length."
        case .unexpectedPublicKeyLength:    return "The public key was not the expected length."
        case .invalidMessage:               return "The message could not be converted to Data."
        case .invalidSignature:             return "The signature was not valid."
        }
    }
}

/// An interface for verifying Schnorr signatures of variable-length content
public protocol SignatureVerifying {}
public extension SignatureVerifying {
    
    /// Verifies a Schnorr signature.
    /// - Parameters:
    ///   - signature: The signature, based on the message.
    ///   - message: The content that was signed.
    ///   - publicKey: The public key for verifying the signature.
    ///
    /// Throws an error if there is a problem with the input parameters or if the signature is invalid. See ``SignatureVerifyingError``.
    ///
    /// If this function does not throw an error, then the signature has been successfully verified.
    func verifySignature(_ signature: String, for message: String, with publicKey: String) throws {
        guard let signatureData = signature.hexadecimalData, signatureData.count == 64 else {
            throw SignatureVerifyingError.unexpectedSignatureLength
        }
        
        guard let publicKeyData = publicKey.hexadecimalData, publicKeyData.count == 32 else {
            throw SignatureVerifyingError.unexpectedPublicKeyLength
        }
        
        guard let messageData = message.hexadecimalData else {
            throw SignatureVerifyingError.invalidMessage
        }
        
        var bytes = [UInt8](messageData)
        let xonly = secp256k1.Schnorr.XonlyKey(dataRepresentation: publicKeyData)
        let schnorr = try secp256k1.Schnorr.SchnorrSignature(dataRepresentation: signatureData)
        
        if !xonly.isValid(schnorr, for: &bytes) {
            throw SignatureVerifyingError.invalidSignature
        }
    }
}
