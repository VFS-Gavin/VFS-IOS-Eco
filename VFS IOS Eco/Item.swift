//
//  Item.swift
//  VFS IOS Eco
//
//  Created by Gavin Etmanski on 2026-11-13.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
