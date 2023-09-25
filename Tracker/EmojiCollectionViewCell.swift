//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 14.09.2023.
//

import UIKit

class EmojiCollectionViewCell: UICollectionViewCell {
    let emojiImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(emojiImageView)
        NSLayoutConstraint.activate([
            emojiImageView.topAnchor.constraint(equalTo: topAnchor),
            emojiImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            emojiImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            emojiImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

