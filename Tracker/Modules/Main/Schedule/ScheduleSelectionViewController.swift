//
//  ScheduleViewContoller.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 30.09.2023.
//

import UIKit

protocol ScheduleSelectionDelegate: AnyObject {
    func didSelectSchedule(_ selectedSchedule: [Schedule])
}

final class ScheduleSelectionViewController: UIViewController {
    
    var selectedSchedule: [Schedule] = []
    private var selectedDays: [Schedule] = []
    weak var delegate: ScheduleSelectionDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.frame = CGRect(x: 0, y: 0, width: 149, height: 22)
        label.textColor = .ypBlack
        label.font = UIFont(name: "SFPro-Medium", size: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.rowHeight = 75
        tableView.separatorStyle = .singleLine
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0.01))
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .ypBlack
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        button.layer.cornerRadius = 16
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setInitialToggleStates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: "ScheduleCell")
        
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        setupConstraints()
        
        navigationItem.rightBarButtonItem = nil
        navigationItem.hidesBackButton = true
        
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalToConstant: 375),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 44),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 49),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setInitialToggleStates() {
        for day in selectedSchedule {
            if let index = Schedule.allCases.firstIndex(of: day) {
                let indexPath = IndexPath(row: index, section: 0)
                if let cell = tableView.cellForRow(at: indexPath) as? ScheduleTableViewCell {
                    cell.toggleSwitch.isOn = true
                }
            }
        }
    }
    
    @objc private func doneButtonTapped() {
            delegate?.didSelectSchedule(selectedDays)
            navigationController?.popViewController(animated: true)
        }
}

//MARK: TableView Delegate&DataSource

extension ScheduleSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleTableViewCell
        
        let day: Schedule
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            day = .sunday
        } else {
            day = Schedule(rawValue: indexPath.row + 2)!
        }
        
        cell.textLabel?.text = day.representation()
        cell.selectionStyle = .none
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 375)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        cell.toggleSwitchAction = { [weak self] isOn in
            guard let self = self else { return }
            
            if isOn {
                self.selectedDays.append(day)
            } else {
                if let index = self.selectedDays.firstIndex(of: day) {
                    self.selectedDays.remove(at: index)
                }
            }
        }
        return cell
    }
}
