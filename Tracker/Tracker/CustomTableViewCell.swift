//
//  CustomTableViewCell.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 15.09.2023.
//
import UIKit

class CustomTableViewCell: UITableViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1)
        return label
    }()

    var titleLabelTopConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(descriptionLabel)

        titleLabelTopConstraint = titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14)

        NSLayoutConstraint.activate([
            titleLabelTopConstraint,
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        ])

        self.backgroundColor = UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        self.layer.borderWidth = 0
        self.layer.masksToBounds = true

        let disclosureIndicator = UIImageView(image: UIImage(systemName: "chevron.right"))
        disclosureIndicator.tintColor = .black
        self.accessoryView = disclosureIndicator
    }

    func configure(title: String, description: String) {
        titleLabel.text = title
        descriptionLabel.text = description

        
        if description.isEmpty {
            titleLabelTopConstraint.constant = 14
        } else {
            titleLabelTopConstraint.constant = 10
        }
    }
}


