//
//  trackersCollectionViewCell.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 04.11.2023.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func addButtonTappedForTracker(at indexPath: IndexPath)
}


class TrackerCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: TrackerCellDelegate?
    
    var isTrackerCompleted = false
    var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    let trackerCardView: UIView = {
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 167, height: 90)
        view.layer.backgroundColor = UIColor(red: 0.765, green: 0.706, blue: 0.969, alpha: 1).cgColor
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 0.3).cgColor
        //view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emojiBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        return view
    }()
    
    let emojiLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 16, height: 22)
        label.font = UIFont(name: "SFPro-Medium", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let trackerLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 143, height: 34)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.font = UIFont(name: "SFPro-Medium", size: 12)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let quantityManagementView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 167, height: 58)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    let daysCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0 дней"
        label.frame = CGRect(x: 0, y: 0, width: 101, height: 18)
        label.textColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
        label.font = UIFont(name: "SFPro-Medium", size: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let addButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white 
        button.layer.cornerRadius = 17
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    @objc private func addButtonTapped() {
        delegate?.addButtonTappedForTracker(at: indexPath)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(trackerCardView)
        trackerCardView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        trackerCardView.addSubview(trackerLabel)
        contentView.addSubview(quantityManagementView)
        quantityManagementView.addSubview(daysCountLabel)
        quantityManagementView.addSubview(addButton)
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            trackerCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerCardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            trackerLabel.leadingAnchor.constraint(equalTo: trackerCardView.leadingAnchor, constant: 12),
            trackerLabel.bottomAnchor.constraint(equalTo: trackerCardView.bottomAnchor, constant: -12),
            trackerLabel.widthAnchor.constraint(equalToConstant: 143),
            
            quantityManagementView.topAnchor.constraint(equalTo: trackerCardView.bottomAnchor),
            quantityManagementView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            quantityManagementView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            quantityManagementView.heightAnchor.constraint(equalToConstant: 58),
            
            daysCountLabel.leadingAnchor.constraint(equalTo: quantityManagementView.leadingAnchor, constant: 12),
            daysCountLabel.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            
            addButton.trailingAnchor.constraint(equalTo: quantityManagementView.trailingAnchor, constant: -12),
            addButton.topAnchor.constraint(equalTo: quantityManagementView.topAnchor, constant: 8),
            addButton.widthAnchor.constraint(equalToConstant: 34),
            addButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
