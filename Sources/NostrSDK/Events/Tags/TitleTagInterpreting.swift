//
//  TitleTagInterpreting.swift
//  
//
//  Created by Terry Yiu on 12/16/23.
//

import Foundation

public protocol TitleTagInterpreting: NostrEvent {}
public extension TitleTagInterpreting {
    /// The title of the event.
    var title: String? {
        firstValueForTagName(.title)
    }
}
