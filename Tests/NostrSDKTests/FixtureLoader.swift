//
//  FixtureLoader.swift
//  
//
//  Created by Joel Klabo on 5/24/23.
//

import Foundation

class FixtureLoader {
    func loadFixture(_ filename: String) -> Data? {
        // Construct the URL for the fixtures directory.
        let bundle = Bundle.module
        guard let url = bundle.url(forResource: filename, withExtension: "json", subdirectory: "Fixtures") else {
            return nil
        }
        // Load the data from the file.
        let data = try? Data(contentsOf: url)

        return data
    }
}
