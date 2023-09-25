//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 05.09.2023.
//

import UIKit


class TrackersViewController: UIViewController {
    
    let datePicker = UIDatePicker()
    let searchBar = UISearchBar()
    let trackersLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.textColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
        label.font = .boldSystemFont(ofSize: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let noTrackersImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "noTrackersSet")
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
    
    let noTrackersLabel: UILabel  = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 343, height: 18)
        label.text = "Что будем отслеживать?"
        label.textColor = .black
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    } ()
    
    @objc func addTrackerButtonTapped() {
        let categorySelectionVC = CategorySelectionViewController()
        let navController = UINavigationController(rootViewController: categorySelectionVC)
        present(navController, animated: true, completion: nil)
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        //to do
      }
      
    private func addSubViews() {
        view.addSubview(searchBar)
        view.addSubview(trackersLabel)
        view.addSubview(noTrackersImageView)
        view.addSubview(noTrackersLabel)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            trackersLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 94),
            trackersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 136),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            noTrackersImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 402),
            noTrackersImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -330),
            noTrackersImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noTrackersImageView.widthAnchor.constraint(equalToConstant: 80),
            noTrackersImageView.heightAnchor.constraint(equalToConstant: 80),
            noTrackersLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 490),
            noTrackersLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -304),
            noTrackersLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noTrackersLabel.widthAnchor.constraint(equalToConstant: 343),
            noTrackersLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        if let navBar = navigationController?.navigationBar {
            navBar.tintColor = UIColor.black
            let customImage = UIImage(named: "Add tracker")
            let leftButton = UIBarButtonItem(image: customImage, style: .plain, target: self, action: #selector(addTrackerButtonTapped))
            navBar.topItem?.setLeftBarButton(leftButton, animated: false)
            
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .compact
            datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
            let dateBarButton = UIBarButtonItem(customView: datePicker)
            navBar.topItem?.setRightBarButton(dateBarButton, animated: false)
        }
        searchBar.placeholder = "Поиск"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        addSubViews()
        setUpConstraints()
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            print("Вы выполнили поиск с запросом: \(searchText)")
        }
        searchBar.resignFirstResponder()
    }
}
