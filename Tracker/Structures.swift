//
//  Structures.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 15.09.2023.
//

import UIKit

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}
struct TrackerRecord {
    let id: UUID
    let date: Date
}

struct Tracker {
    let id = UUID()
    let name: String
    let color: UIColor?
    let emoji: String
    let schedule: [Schedule]
}

enum Schedule: Int, CaseIterable {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7
    
    func representation() -> String {
        switch self {
        case .monday:
            return "Понеделиник"
        case .tuesday:
            return "Вторник"
        case .wednesday:
            return "Среда"
        case .thursday:
            return "Четверг"
        case .friday:
            return "Пятница"
        case .saturday:
            return "Суббота"
        case .sunday:
            return "Воскресенье"
        }
    }
    
    func shortRepresentation() -> String {
        switch self {
        case .monday:
            return "Пн"
        case .tuesday:
            return "Вт"
        case .wednesday:
            return "Ср"
        case .thursday:
            return "Чт"
        case .friday:
            return "Пт"
        case .saturday:
            return "Сб"
        case .sunday:
            return "Вс"
        }
    }
}

