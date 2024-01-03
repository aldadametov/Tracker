//
//  CategoryCreationViewController.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 23.12.2023.
//

import UIKit

final class CategoryCreationViewController: UIViewController {
    
    private let trackerCategoryStore = TrackerCategoryStore()
    var isEditingCategory = false
    var originalCategoryName: String?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.frame = CGRect(x: 0, y: 0, width: 149, height: 22)
        label.textColor = .ypBlack
        label.font = UIFont(name: "SFPro-Medium", size: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .ypBackgroundDay
        textField.font = UIFont(name: "SFPro-Regular", size: 17)
        textField.layer.cornerRadius = 16
        textField.layer.borderWidth = 0
        textField.layer.masksToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        let placeholderText = "Введите название категории"
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.ypGray]
        )
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.backgroundColor = .ypGray
        button.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        navigationItem.rightBarButtonItem = nil
        navigationItem.hidesBackButton = true
        
        if isEditingCategory {
            titleLabel.text = "Редактирование категории"
            nameTextField.text = originalCategoryName
        }
        
        addSubviews()
        setupConstraints()
        hideKeyboardWhenTappedAround()
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        updateDoneButtonState()
        
    }
    
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        view.addSubview(doneButton)
        }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 45),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.widthAnchor.constraint(equalToConstant: 343),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
            
        ])
    }
    
    @objc func doneButtonTapped() {
        guard let categoryName = nameTextField.text else { return }

        if isEditingCategory {
            if let originalName = originalCategoryName {
                trackerCategoryStore.updateCategory(oldTitle: originalName, newTitle: categoryName)
            }
        } else {
            trackerCategoryStore.addNewTrackerCategory(title: categoryName, trackers: [])
        }

        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateDoneButtonState()
    }
    
    private func updateDoneButtonState() {
        let isNameTextFieldEmpty = nameTextField.text?.isEmpty ?? true
        let isButtonEnabled = !isNameTextFieldEmpty
        doneButton.isEnabled = isButtonEnabled
        if isButtonEnabled {
            doneButton.backgroundColor = .ypBlack
            doneButton.setTitleColor(.ypWhite, for: .normal)
        } else {
            doneButton.backgroundColor = .ypGray
        }
    }
    
}
