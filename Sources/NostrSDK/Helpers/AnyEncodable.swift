//
//  AnyEncodable.swift
//  
//
//  Created by Joel Klabo on 5/26/23.
//

import Foundation

struct AnyEncodable: Encodable {
    private var _encode: (Encoder) throws -> Void

    init<T: Encodable>(_ encodable: T) {
        self._encode = encodable.encode
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
