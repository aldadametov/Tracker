//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 02.01.2024.
//

import UIKit

enum FilterType: Int {
    case allTrackers = 0
    case trackersForToday
    case completed
    case notCompleted
}

protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filterType: FilterType)
}

class FiltersViewController: UIViewController {
    
    private let filterTitles = ["Все трекеры", "Трекеры на сегодня", "Завершённые", "Незавершённые"]
    weak var delegate: FiltersViewControllerDelegate?
    
    private var lastSelectedIndexPath: IndexPath?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Фильтры"
        label.frame = CGRect(x: 0, y: 0, width: 149, height: 22)
        label.textColor = .ypBlack
        label.font = UIFont(name: "SFPro-Medium", size: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var filtersTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let cornerRadius: CGFloat = 16.0
        tableView.layer.cornerRadius = cornerRadius
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let savedFilterIndex = UserDefaults.standard.integer(forKey: "selectedFilter")
        lastSelectedIndexPath = IndexPath(row: savedFilterIndex, section: 0)
        
        
        filtersTableView.delegate = self
        filtersTableView.dataSource = self
        filtersTableView.register(FiltersTableViewCell.self, forCellReuseIdentifier: "FiltersCell")
        
        addSubviews()
        setupConstraints()
    }
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(filtersTableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            
            filtersTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            filtersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filtersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersTableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
}

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FiltersCell", for: indexPath) as? FiltersTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: filterTitles[indexPath.row])
        
        cell.accessoryType = (indexPath == lastSelectedIndexPath) ? .checkmark : .none
        
        if indexPath.row == filterTitles.count - 1 {
            cell.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 16)
        } else {
            cell.roundCorners(corners: [], radius: 0)
        }
        return cell
    }
}


extension FiltersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let lastIndexPath = lastSelectedIndexPath,
           let lastCell = tableView.cellForRow(at: lastIndexPath) as? FiltersTableViewCell {
            lastCell.accessoryType = .none
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? FiltersTableViewCell {
            cell.accessoryType = .checkmark
            cell.tintColor = .systemBlue
        }
        
        UserDefaults.standard.set(indexPath.row, forKey: "selectedFilter")
        
        lastSelectedIndexPath = indexPath
        
        guard let filterType = FilterType(rawValue: indexPath.row) else { return }
        delegate?.didSelectFilter(filterType)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let separatorInset: CGFloat = 16
        if indexPath.row == filterTitles.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: separatorInset, bottom: 0, right: separatorInset)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
