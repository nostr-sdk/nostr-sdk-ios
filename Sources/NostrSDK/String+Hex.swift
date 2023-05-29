//
//  String+Hex.swift
//
//
//  Copied by Terry Yiu on 5/28/23 from https://github.com/planetary-social/nos/blob/main/Nos/Extensions/String%2BHex.swift
//  Permission to redistribute this code under MIT license granted nostr:note1q39598qkdc093sdq4enudjf0dall76s7n779k07nutgd9r2zt6vq96l8c2
//  Created by Matthew Lorentz for Nos on 2/7/23.
//

import Foundation

extension String {
    
    var hexDecoded: Data? {
        guard self.count.isMultiple(of: 2) else { return nil }
        
        // https://stackoverflow.com/a/62517446/982195
        let stringArray = Array(self)
        var data = Data()
        for i in stride(from: 0, to: count, by: 2) {
            let pair = String(stringArray[i]) + String(stringArray[i + 1])
            if let byteNum = UInt8(pair, radix: 16) {
                let byte = Data([byteNum])
                data.append(byte)
            } else {
                return nil
            }
        }
        return data
    }
}
