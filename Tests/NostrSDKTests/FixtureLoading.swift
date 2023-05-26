//
//  FixtureLoading.swift
//  
//
//  Created by Joel Klabo on 5/24/23.
//

import Foundation

enum FixtureLoadingError: Error {
    case missingFile
}

protocol FixtureLoading {}
extension FixtureLoading {

    func loadFixture(_ filename: String) throws -> Data {
        // Construct the URL for the fixtures directory.
        let bundle = Bundle.module
        guard let url = bundle.url(forResource: filename, withExtension: "json", subdirectory: "Fixtures") else {
            throw FixtureLoadingError.missingFile
        }
        // Load the data from the file.
        return try Data(contentsOf: url)
    }
}
