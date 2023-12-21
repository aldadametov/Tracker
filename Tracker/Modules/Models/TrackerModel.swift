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

    init(id: UUID = UUID(), name: String, color: UIColor?, emoji: String, schedule: [Schedule]) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
}
