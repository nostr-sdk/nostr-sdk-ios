//
//  JSONTesting.swift
//  
//
//  Created by Joel Klabo on 5/26/23.
//

import Foundation

protocol JSONTesting {}

extension JSONTesting {
    func areEquivalentJSONArrayStrings(_ first: String?, _ second: String?) -> Bool {
        guard let first, let second else {
            return first == nil && second == nil
        }

        guard let dataOne = first.data(using: .utf8),
              let dataTwo = second.data(using: .utf8) else {
            return false
        }

        do {
            if let jsonArrayOne = try JSONSerialization.jsonObject(with: dataOne, options: []) as? [AnyHashable],
               let jsonArrayTwo = try JSONSerialization.jsonObject(with: dataTwo, options: []) as? [AnyHashable] {
                return Set(jsonArrayOne) == Set(jsonArrayTwo)
            } else {
                return false
            }
        } catch {
            return false
        }
    }

    func areEquivalentJSONObjectStrings(_ first: String?, _ second: String?) -> Bool {
        guard let first, let second else {
            return first == nil && second == nil
        }

        guard let dataOne = first.data(using: .utf8),
              let dataTwo = second.data(using: .utf8) else {
            return false
        }

        do {
            if let jsonOne = try JSONSerialization.jsonObject(with: dataOne, options: []) as? [String: Any],
               let jsonTwo = try JSONSerialization.jsonObject(with: dataTwo, options: []) as? [String: Any] {
                return NSDictionary(dictionary: jsonOne).isEqual(to: jsonTwo)
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}
