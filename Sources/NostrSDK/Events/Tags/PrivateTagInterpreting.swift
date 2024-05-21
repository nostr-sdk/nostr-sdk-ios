//
//  PrivateTagInterpreting.swift
//
//
//  Created by Bryan Montz on 12/24/23.
//

import Foundation

public protocol PrivateTagInterpreting: NIP04DirectMessageEncrypting {}
public extension PrivateTagInterpreting {
    
    /// The private tags encrypted in the content of the event.
    /// - Parameter content: The content from which to decrypt the content.
    /// - Parameter tagName: An optional ``TagName`` to filter the decrypted tags.
    /// - Parameter keypair: The keypair to use to decrypt the content.
    /// - Returns: The private tags.
    func privateTags(from content: String, withName tagName: TagName? = nil, using keypair: Keypair) -> [Tag] {
        guard let decryptedContent = try? nip04Decrypt(encryptedContent: content, privateKey: keypair.privateKey, publicKey: keypair.publicKey),
              let jsonData = decryptedContent.data(using: .utf8) else {
            return []
        }
        
        let tags = try? JSONDecoder().decode([Tag].self, from: jsonData)
        if let tagName {
            return tags?.filter { $0.name == tagName.rawValue } ?? []
        } else {
            return tags ?? []
        }
    }
    
    /// The values for the private tags encrypted in the content of the event.
    /// - Parameter content: The content from which to decrypt the content.
    /// - Parameter tagName: An optional ``TagName`` to filter the decrypted tags.
    /// - Parameter keypair: The keypair to use to decrypt the content.
    /// - Returns: The values for the private tags.
    func valuesForPrivateTags(from content: String, withName tagName: TagName? = nil, using keypair: Keypair) -> [String] {
        privateTags(from: content, withName: tagName, using: keypair).map { $0.value }
    }
}

public extension PrivateTagInterpreting where Self: NostrEvent {
    func privateTags(using keypair: Keypair) -> [Tag] {
        privateTags(from: content, using: keypair)
    }
}
