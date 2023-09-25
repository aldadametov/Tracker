//
//  CategorySelectionViewController.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 13.09.2023.
//

import UIKit

class CategorySelectionViewController: UIViewController {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.frame = CGRect(x: 0, y: 0, width: 149, height: 22)
        label.textColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let habitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.frame = CGRect(x: 0, y: 0, width: 335, height: 60)
        button.layer.backgroundColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1).cgColor
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let eventButton: UIButton = {
        let button = UIButton()
        button.setTitle("Нерегулярное событие", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.frame = CGRect(x: 0, y: 0, width: 335, height: 60)
        button.layer.backgroundColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1).cgColor
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
        view.addSubview(titleLabel)
        view.addSubview(habitButton)
        view.addSubview(eventButton)
        
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalToConstant: 375),
            titleLabel.heightAnchor.constraint(equalToConstant: 114),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -698),
            
            habitButton.widthAnchor.constraint(equalToConstant: 335),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 281),
            
            eventButton.widthAnchor.constraint(equalToConstant: 335),
            eventButton.heightAnchor.constraint(equalToConstant: 60),
            eventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            eventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            eventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
        ])
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        eventButton.addTarget(self, action: #selector(eventButtonTapped), for: .touchUpInside)
    }
    
    @objc func habitButtonTapped() {
        let createHabitVC = NewHabitViewController() // Создайте экземпляр контроллера создания привычки
        let navController = UINavigationController(rootViewController: createHabitVC) // Упаковываем контроллер в навигационный контроллер
        present(navController, animated: true, completion: nil) // Отображаем экран модально
    }

    
    @objc func eventButtonTapped() {
        // Обработка нажатия на кнопку "Нерегулярное событие"
    }
}

