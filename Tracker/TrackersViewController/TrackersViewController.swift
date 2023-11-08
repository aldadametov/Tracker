//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 05.09.2023.
//

import UIKit


class TrackersViewController: UIViewController {
    
    private var categories: [TrackerCategory] = [
        TrackerCategory(
            title: "Уборка",
            trackers: [
                Tracker(
                    name: "Помыть посуду",
                    color: .colorSelection[1],
                    emoji: "💦",
                    schedule: [.monday, .tuesday, .saturday, .friday]),
                Tracker(
                    name: "Запустить робот - пылесос",
                    color: .colorSelection[2],
                    emoji: "🤖",
                    schedule: [.wednesday]),
                Tracker(
                    name: "Постирать вещи",
                    color: .colorSelection[2],
                    emoji: "🧺",
                    schedule: [.wednesday])
            ]),
        TrackerCategory(
            title: "Отдых",
            trackers: [
                Tracker(
                    name: "Пройти СпайдерМена на Платину",
                    color: .colorSelection[3],
                    emoji: "🕷️",
                    schedule: [.sunday])
            ]),
        TrackerCategory(
            title: "Учёба",
            trackers: [
                Tracker(
                    name: "Учить SWIFT минимум 4 часа",
                    color: .colorSelection[4],
                    emoji: "👨‍💻",
                    schedule: [.tuesday]),
                Tracker(
                    name: "Повторять правила дорожного движения",
                    color: .colorSelection[5],
                    emoji: "🚗",
                    schedule: [.saturday])
            ]),
    ]
    
    var visibleCategories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var currentDate: Date = Date() {
        didSet {
            updateVisibleCategories()
        }
    }
    let datePicker = UIDatePicker()
    let searchBar = UISearchBar()
    let trackersLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.textColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
        label.font = UIFont(name: "SFPro-Bold", size: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let noTrackersImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "noTrackersSet")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    let noTrackersLabel: UILabel  = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 343, height: 18)
        label.text = "Что будем отслеживать?"
        label.textColor = .black
        label.font = UIFont(name: "SFPro-Medium", size: 12)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    } ()
    
    private lazy var trackersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private func showPlaceHolder() {
        if visibleCategories.isEmpty {
            noTrackersLabel.isHidden = false
            noTrackersImageView.isHidden = false
            trackersCollectionView.isHidden = true
        } else {
            noTrackersLabel.isHidden = true
            noTrackersImageView.isHidden = true
            trackersCollectionView.isHidden = false 
        }
    }
    
    @objc func addTrackerButtonTapped() {
        let categorySelectionVC = TrackerTypeViewController()
        let navController = UINavigationController(rootViewController: categorySelectionVC)
        present(navController, animated: true, completion: nil)
    }
    
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        let selectedDate = sender.date
        let localTimeZone = TimeZone.current
        
        let localDate = selectedDate.addingTimeInterval(TimeInterval(localTimeZone.secondsFromGMT(for: selectedDate)))
        currentDate = localDate
        
        updateVisibleCategories()
        trackersCollectionView.reloadData()
    }
    
    func updateVisibleCategories() {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: currentDate)
        
        if let selectedDay = Schedule(rawValue: dayOfWeek) {
            visibleCategories = categories.compactMap { category in
                let filteredTrackers = category.trackers.filter { $0.schedule.contains(selectedDay) }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
            }
            
            print("Updated visible categories: \(visibleCategories)")
        } else {
            print("Не удалось определить день недели")
        }
        trackersCollectionView.reloadData()
        showPlaceHolder()
        
    }
    
    private func addSubViews() {
        view.addSubview(searchBar)
        view.addSubview(trackersLabel)
        view.addSubview(noTrackersImageView)
        view.addSubview(noTrackersLabel)
        view.addSubview(trackersCollectionView)
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
            noTrackersLabel.heightAnchor.constraint(equalToConstant: 18),
            trackersCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84)
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
        
        trackersCollectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        
        
        
        searchBar.placeholder = "Поиск"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        trackersCollectionView.delegate = self
        trackersCollectionView.dataSource = self
        addSubViews()
        setUpConstraints()
        showPlaceHolder()
        //addNewTrackers()
    }
}


//MARK: UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCollectionViewCell
        
        cell.delegate = self
        cell.indexPath = indexPath
        
        let currentTracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        cell.trackerCardView.backgroundColor = currentTracker.color
        cell.emojiLabel.text = currentTracker.emoji
        cell.trackerLabel.text = currentTracker.name
        cell.addButton.backgroundColor = currentTracker.color
        
        let trackerIsCompleted = completedTrackers.contains(where: { $0.id == currentTracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate) })
        
        if trackerIsCompleted {
            cell.isTrackerCompleted = true
            cell.daysCountLabel.text = "1 день"
            cell.addButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            cell.addButton.backgroundColor = currentTracker.color?.withAlphaComponent(0.3)
        } else {
            cell.isTrackerCompleted = false
            cell.daysCountLabel.text = "0 дней"
            cell.addButton.setImage(UIImage(systemName: "plus"), for: .normal)
            cell.addButton.backgroundColor = currentTracker.color
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeaderView
            headerView.titleLabel.text = visibleCategories[indexPath.section].title
            return headerView
        }
        return UICollectionReusableView()
    }
    
}

//MARK: UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {
    
}

//MARK: UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 41) / 2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 28, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
}


//MARK: UISearchBarDelegate

extension TrackersViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            print("Вы выполнили поиск с запросом: \(searchText)")
        }
        searchBar.resignFirstResponder()
    }
}

//MARK: TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    func addButtonTappedForTracker(at indexPath: IndexPath) {
        let selectedCategory = visibleCategories[indexPath.section]
        let selectedTracker = selectedCategory.trackers[indexPath.row]
        
        let today = Date()
        if currentDate > today {
            print("Вы не можете отметить трекер для будущей даты.")
            return
        }
        
        if let existingRecord = completedTrackers.first(where: { $0.id == selectedTracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }) {
            if let index = completedTrackers.firstIndex(where: { $0.id == existingRecord.id }) {
                completedTrackers.remove(at: index)
                if let cell = trackersCollectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell {
                    cell.isTrackerCompleted = false
                    cell.daysCountLabel.text = "0 дней"
                    cell.addButton.setImage(UIImage(systemName: "plus"), for: .normal)
                    cell.addButton.backgroundColor = selectedTracker.color
                }
            }
        } else {
            let newRecord = TrackerRecord(id: selectedTracker.id, date: currentDate)
            completedTrackers.append(newRecord)
            
            if let cell = trackersCollectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell {
                cell.isTrackerCompleted = true
                cell.daysCountLabel.text = "1 день"
                cell.addButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
                cell.addButton.backgroundColor = selectedTracker.color?.withAlphaComponent(0.3)
            }
        }
        print(completedTrackers)
    }
}



