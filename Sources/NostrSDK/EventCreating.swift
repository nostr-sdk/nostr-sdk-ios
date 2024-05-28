//
//  EventCreating.swift
//
//
//  Created by Bryan Montz on 6/25/23.
//

import Foundation

enum EventCreatingError: Error {
    case invalidInput
}

public protocol EventCreating: DirectMessageEncrypting, NIP44v2Encrypting, RelayURLValidating {}
