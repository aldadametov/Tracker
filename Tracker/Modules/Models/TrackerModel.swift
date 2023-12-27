//
//  TrackerModel.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 14.11.2023.
//

import UIKit

struct Tracker: Hashable {
    let id: UUID
    let name: String
    let color: UIColor?
    let emoji: String
    let schedule: [Schedule]
    var isPinned: Bool = false
    var originalCategory: String? // Добавлено новое свойство

    init(id: UUID = UUID(), name: String, color: UIColor?, emoji: String, schedule: [Schedule], isPinned: Bool = false, originalCategory: String? = nil) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.isPinned = isPinned
        self.originalCategory = originalCategory
    }
}
