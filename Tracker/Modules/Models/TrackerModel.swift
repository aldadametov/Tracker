//
//  TrackerModel.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 14.11.2023.
//

import UIKit

struct Tracker {
    let id = UUID()
    let name: String
    let color: UIColor?
    let emoji: String
    let schedule: [Schedule]
}
