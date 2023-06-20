//
//  Data+Additions.swift
//
//
//  Created by Bryan Montz on 6/20/23.
//

import CommonCrypto
import Foundation

extension Data {
    
    /// The SHA256 hash of the data.
    var sha256: Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(count), &hash)
        }
        return Data(hash)
    }
    
    /// Random data of a given size.
    static func randomBytes(count: Int) -> Data {
        var bytes = [Int8](repeating: 0, count: count)
        guard SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess else {
            fatalError("can't copy secure random data")
        }
        return Data(bytes: bytes, count: count)
    }
}
