//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 24.09.2023.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    let colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(colorView)
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            colorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            colorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            colorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        colorView.layer.cornerRadius = 8
        colorView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

