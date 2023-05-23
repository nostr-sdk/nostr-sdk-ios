//
//  EventKind.swift
//  
//
//  Created by Bryan Montz on 5/22/23.
//

import Foundation

public enum EventKind: Int, Codable {
    case setMetadata = 0
    case textNote = 1
    case recommendServer = 2
    case repost = 6
}
