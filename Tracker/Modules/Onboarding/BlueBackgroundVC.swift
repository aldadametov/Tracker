//
//  BlueBackgroundVC.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 21.12.2023.
//

import UIKit

class BlueBackgroundVC: UIViewController {
    
    let backgroundView: UIImageView = {
        let view = UIImageView()
        let image = UIImage(named: "blueBackground")
        view.image = image
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let onboardingLabel: UILabel = {
        let label = UILabel()
        label.text = "Отслеживайте только то, что хотите"
        label.font = UIFont(name: "SFPro-Bold", size: 32)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(backgroundView)
        view.addSubview(onboardingLabel)
        
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            onboardingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            onboardingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            onboardingLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -304),
            onboardingLabel.heightAnchor.constraint(equalToConstant: 77)
        ])
    }
}