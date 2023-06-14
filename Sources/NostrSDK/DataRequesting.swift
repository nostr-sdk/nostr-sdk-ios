//
//  DataRequesting.swift
//  
//
//  Created by Bryan Montz on 6/14/23.
//

import Foundation

/// An interface for retrieving data for a URL.
///
/// Use this protocol to create a mock for URLSession and return custom data.
public protocol DataRequesting {
    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

extension URLSession: DataRequesting {}
