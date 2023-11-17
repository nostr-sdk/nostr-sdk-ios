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

    /// Returns ``DateComponents`` from a string representation of a date in the format of yyyy-mm-dd
    /// or nil if the string does not match the format.
    var dateStringAsDateComponents: DateComponents? {
        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: "\\A(?<year>\\d{4})-(?<month>\\d{2})-(?<day>\\d{2})\\z")
        } catch {
            return nil
        }

        let matches = regex.matches(in: self, range: NSRange(location: 0, length: self.count))
        guard let match = matches.first else {
            return nil
        }

        var captures: [String: Int] = [:]

        // For each matched range, extract the named capture group
        for name in ["year", "month", "day"] {
            let matchRange = match.range(withName: name)

            // Extract the substring matching the named capture group
            if let substringRange = Range(matchRange, in: self) {
                let capture = Int(self[substringRange])
                captures[name] = capture
            }
        }

        guard let year = captures["year"], let month = captures["month"], let day = captures["day"] else {
            return nil
        }

        let dateComponents = DateComponents(calendar: Calendar(identifier: .iso8601), year: year, month: month, day: day)

        // Documentation for DateComponents.isValidDate says that this method is not necessarily cheap.
        // If performance becomes a concern, reconsider if this check should be performed.
        guard dateComponents.isValidDate else {
            return nil
        }

        return dateComponents
    }
}
