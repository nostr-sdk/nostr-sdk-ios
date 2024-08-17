//
//  ImageTagInterpreting.swift
//
//
//  Created by Terry Yiu on 8/4/24.
//

import Foundation

public protocol ImageTagInterpreting: NostrEvent {}
public extension ImageTagInterpreting {
    /// The image of the event.
    var imageURL: URL? {
        guard let imageURLString = firstValueForTagName(.image) else {
            return nil
        }
        return URL(string: imageURLString)
    }
}
