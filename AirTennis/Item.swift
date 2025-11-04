//
//  Item.swift
//  AirTennis
//
//  Created by 谢增添 on 2025/11/4.
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
