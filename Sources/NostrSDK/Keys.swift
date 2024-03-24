//
//  Keys.swift
//  
//
//  Created by Terry Yiu on 5/23/23.
//

import Foundation
import secp256k1

public struct Keypair {
    public let publicKey: PublicKey
    public let privateKey: PrivateKey

    public init?() {
        guard let key = try? secp256k1.Signing.PrivateKey() else {
            Loggers.keypairs.error("Could not generate new secp256k1 private key.")
            return nil
        }

        guard let privateKey = PrivateKey(dataRepresentation: key.dataRepresentation) else {
            Loggers.keypairs.error("Could not create keypair from generated secp256k1 private key.")
            return nil
        }

        self.init(privateKey: privateKey)
    }

    public init?(hex: String) {
        guard let privateKey = PrivateKey(hex: hex) else {
            Loggers.keypairs.error("Could not create keypair from private key hex.")
            return nil
        }

        self.init(privateKey: privateKey)
    }

    public init?(nsec: String) {
        guard let privateKey = PrivateKey(nsec: nsec) else {
            Loggers.keypairs.error("Could not create keypair from private key nsec")
            return nil
        }

        self.init(privateKey: privateKey)
    }

    public init?(privateKey: PrivateKey) {
        self.privateKey = privateKey

        guard let secp256k1PrivateKey = try? secp256k1.Signing.PrivateKey(dataRepresentation: privateKey.dataRepresentation) else {
            Loggers.keypairs.error("Could not create secp256k1 private key.")
            return nil
        }

        let publicKeyDataRepresentation = Data(secp256k1PrivateKey.publicKey.xonly.bytes)
        guard let publicKey = PublicKey(dataRepresentation: publicKeyDataRepresentation) else {
            Loggers.keypairs.error("Could not create secp256k1 public key from private key.")
            return nil
        }

        self.publicKey = publicKey
    }
}

public struct PublicKey: Equatable {
    static let humanReadablePrefix = "npub"

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hex == rhs.hex
    }

    public let hex: String
    public let npub: String
    public let dataRepresentation: Data

    public init?(dataRepresentation: Data) {
        self.init(npub: Bech32.encode(PublicKey.humanReadablePrefix, baseEightData: dataRepresentation))
    }

    public init?(hex: String) {
        guard hex.isEmpty == false else {
            Loggers.keypairs.error("Trying to create public key with empty string")
            return nil
        }

        guard let dataRepresentation = hex.hexDecoded else {
            Loggers.keypairs.error("Could not decode hex representation of public key.")
            return nil
        }

        self.init(dataRepresentation: dataRepresentation)
    }

    public init?(npub: String) {
        guard let (humanReadablePart, checksum) = try? Bech32.decode(npub) else {
            Loggers.keypairs.error("Could not create public key because npub could not be bech32 decoded.")
           return nil
        }

        guard humanReadablePart == PublicKey.humanReadablePrefix else {
            Loggers.keypairs.error("Could not create public key because the human readable part, \(humanReadablePart), is not equal to npub.")
            return nil
        }

        guard let checksumBase8 = checksum.base8FromBase5 else {
            Loggers.keypairs.error("Could not convert data representation of public key from base 5 encoding to base 8.")
            return nil
        }

        self.npub = npub
        dataRepresentation = checksumBase8
        hex = checksumBase8.hexString
    }
}

public struct PrivateKey {
    static let humanReadablePrefix = "nsec"

    public let hex: String
    public let nsec: String
    public let dataRepresentation: Data

    public init?(dataRepresentation: Data) {
        self.init(nsec: Bech32.encode(PrivateKey.humanReadablePrefix, baseEightData: dataRepresentation))
    }

    public init?(hex: String) {
        guard hex.isEmpty == false else {
            Loggers.keypairs.error("Trying to create private key with empty string")
            return nil
        }

        guard let dataRepresentation = hex.hexDecoded else {
            Loggers.keypairs.error("Could not decode hex representation of private key.")
            return nil
        }

        self.init(dataRepresentation: dataRepresentation)
    }

    public init?(nsec: String) {
        guard let (humanReadablePart, checksum) = try? Bech32.decode(nsec) else {
            Loggers.keypairs.error("Could not create private key because nsec could not be bech32 decoded.")
           return nil
        }

        guard humanReadablePart == PrivateKey.humanReadablePrefix else {
            Loggers.keypairs.error("Could not create private key because the human readable part, \(humanReadablePart), is not equal to nsec.")
            return nil
        }

        guard let checksumBase8 = checksum.base8FromBase5 else {
            Loggers.keypairs.error("Could not convert data representation of private key from base 5 encoding to base 8.")
            return nil
        }

        self.nsec = nsec
        dataRepresentation = checksumBase8
        hex = checksumBase8.hexString
    }
}
