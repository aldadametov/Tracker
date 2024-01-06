//
//  Helpers.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 02.01.2024.
//
import UIKit

func createLabel(text: String, font: UIFont, textColor: UIColor) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = font
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = textColor
    return label
}

extension Notification.Name {
    static let didUpdateTrackerData = Notification.Name("didUpdateTrackerData")
}
