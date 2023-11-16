//
//  SectionHeaderColectionReusableView.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 15.11.2023.
//

import UIKit

class SectionHeaderCollectionReusableView: UICollectionReusableView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFPro-Bold", size: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

