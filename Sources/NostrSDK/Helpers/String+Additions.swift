//
//  String+Additions.swift
//  
//
//  Created by Bryan Montz on 6/16/23.
//

import Foundation

public extension String {
    
    /// The hexadecimal data representation of the `String`.
    ///
    /// For example, given a `String` "8F31", the result would be a `Data` of `0x8F31.` It does not convert each character to its Unicode representation.
    ///
    /// > Note: This function will fail and return nil if any character in the `String` is not in the set 0-9 or A-F.
    var hexadecimalData: Data? {
        var hex = self
        var data = Data()

        while !hex.isEmpty {
            let hexPair = hex.prefix(2)
            hex = String(hex.dropFirst(2))

            if let byte = UInt8(hexPair, radix: 16) {
                data.append(byte)
            } else {
                return nil
            }
        }

        return data
    }
    
    func decoded(using encoding: String.Encoding = .utf8) -> String? {
        guard let hexData = hexadecimalData else {
            return nil
        }
        return String(data: hexData, encoding: encoding)
    }
}
