//
//  CustomTableViewCell.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 15.09.2023.
//
import UIKit

class CustomTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    private func setupUI() {
        self.backgroundColor = UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        self.textLabel?.font = UIFont.systemFont(ofSize: 16)
        self.textLabel?.textColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
        self.layer.borderWidth = 0
        self.layer.masksToBounds = true

        let disclosureIndicator = UIImageView(image: UIImage(systemName: "chevron.right"))
        disclosureIndicator.tintColor = .black
        self.accessoryView = disclosureIndicator
    }
}
