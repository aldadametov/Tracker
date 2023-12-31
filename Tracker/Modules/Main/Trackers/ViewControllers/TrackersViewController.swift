//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 05.09.2023.
//

import UIKit


final class TrackersViewController: UIViewController {
    
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private var currentDate: Date = Date()
    private let searchBar = UISearchBar()
    private var searchResults: [TrackerCategory] = []
    private var isSearchActive: Bool = false
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar = Calendar(identifier: .gregorian)
        datePicker.calendar.firstWeekday = 2
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return datePicker
    }()
    
    private let trackersLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.textColor = .ypBlack
        label.font = UIFont(name: "SFPro-Bold", size: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let noTrackersCreatedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "noTrackersSet")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    private let noTrackersCreatedLabel: UILabel  = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 343, height: 18)
        label.text = "Что будем отслеживать?"
        label.textColor = .ypBlack
        label.font = UIFont(name: "SFPro-Medium", size: 12)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    } ()
    
    private let noTrackersFoundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "noTrackersFound")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    private let noTrackersFoundLabel: UILabel  = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 343, height: 18)
        label.text = "Ничего не найдено"
        label.textColor = .ypBlack
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
        collectionView.backgroundColor = .ypWhite
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private func showPlaceholder() {
        if !isSearchActive {
            let hasTrackers = !trackerStore.filteredTrackers(for: currentDate).isEmpty
            noTrackersCreatedLabel.isHidden = hasTrackers
            noTrackersCreatedImageView.isHidden = hasTrackers
            trackersCollectionView.isHidden = !hasTrackers
        } else {
            noTrackersCreatedLabel.isHidden = true
            noTrackersCreatedImageView.isHidden = true
        }
    }
    
    private func showNoResultsPlaceholder() {
        let shouldShowNoResultsPlaceholder = isSearchActive && searchResults.isEmpty
        
        noTrackersFoundLabel.isHidden = !shouldShowNoResultsPlaceholder
        noTrackersFoundImageView.isHidden = !shouldShowNoResultsPlaceholder
        trackersCollectionView.isHidden = shouldShowNoResultsPlaceholder
    }
    @objc func addTrackerButtonTapped() {
        let trackerTypeSelectionVC = TrackerTypeSelectionViewController()
        trackerTypeSelectionVC.delegate = self 
        let navController = UINavigationController(rootViewController: trackerTypeSelectionVC)
        present(navController, animated: true, completion: nil)
    }
    
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        let selectedDate = sender.date
        let calendar = Calendar.current
        let localDate = calendar.startOfDay(for: selectedDate)
        currentDate = localDate
        trackersCollectionView.reloadData()
        showPlaceholder()
    }
    
    private func addSubViews() {
        view.addSubview(searchBar)
        view.addSubview(trackersLabel)
        view.addSubview(noTrackersCreatedImageView)
        view.addSubview(noTrackersCreatedLabel)
        view.addSubview(noTrackersFoundImageView)
        view.addSubview(noTrackersFoundLabel)
        view.addSubview(trackersCollectionView)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            trackersLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 94),
            trackersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 136),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            noTrackersCreatedImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 402),
            noTrackersCreatedImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -330),
            noTrackersCreatedImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noTrackersCreatedImageView.widthAnchor.constraint(equalToConstant: 80),
            noTrackersCreatedImageView.heightAnchor.constraint(equalToConstant: 80),
            noTrackersCreatedLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 490),
            noTrackersCreatedLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -304),
            noTrackersCreatedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noTrackersCreatedLabel.widthAnchor.constraint(equalToConstant: 343),
            noTrackersCreatedLabel.heightAnchor.constraint(equalToConstant: 18),
            noTrackersFoundImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 402),
            noTrackersFoundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -330),
            noTrackersFoundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noTrackersFoundImageView.widthAnchor.constraint(equalToConstant: 80),
            noTrackersFoundImageView.heightAnchor.constraint(equalToConstant: 80),
            noTrackersFoundLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 490),
            noTrackersFoundLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -304),
            noTrackersFoundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noTrackersFoundLabel.widthAnchor.constraint(equalToConstant: 343),
            noTrackersFoundLabel.heightAnchor.constraint(equalToConstant: 18),
            trackersCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84)
        ])
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        if let navBar = navigationController?.navigationBar {
            navBar.tintColor = UIColor.black
            let customImage = UIImage(named: "Add tracker")
            let leftButton = UIBarButtonItem(image: customImage, style: .plain, target: self, action: #selector(addTrackerButtonTapped))
            navBar.topItem?.setLeftBarButton(leftButton, animated: false)
            
            navBar.topItem?.setRightBarButton(UIBarButtonItem(customView: datePicker), animated: false)
        }
        
        trackersCollectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        
        searchBar.placeholder = "Поиск"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        trackersCollectionView.delegate = self
        trackersCollectionView.dataSource = self
        trackerStore.delegate = self
        addSubViews()
        setUpConstraints()
        hideKeyboardWhenTappedAround()
        showPlaceholder()
    }
}


//MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return isSearchActive ? searchResults.count : trackerStore.filteredTrackers(for: currentDate).count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let categories = isSearchActive ? searchResults : trackerStore.filteredTrackers(for: currentDate)
        return categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCollectionViewCell
        
        cell.indexPath = indexPath
        cell.delegate = self
        
        let categories = isSearchActive ? searchResults : trackerStore.filteredTrackers(for: currentDate)
        let currentTracker = categories[indexPath.section].trackers[indexPath.row]
        
        cell.trackerCardView.backgroundColor = currentTracker.color
        cell.emojiLabel.text = currentTracker.emoji
        cell.trackerLabel.text = currentTracker.name
        cell.addButton.backgroundColor = currentTracker.color
        
        let trackerIsCompleted = trackerRecordStore.isTrackerCompleted(currentTracker, on: currentDate)
        
        if trackerIsCompleted {
            cell.addButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            cell.addButton.backgroundColor = currentTracker.color?.withAlphaComponent(0.3)
        } else {
            cell.addButton.setImage(UIImage(systemName: "plus"), for: .normal)
            cell.addButton.backgroundColor = currentTracker.color
        }
        
        let daysCount = trackerRecordStore.countCompletedDays(for: currentTracker)
        cell.daysCountLabel.text = formatDaysString(daysCount)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeaderView
            if let sectionTitle = trackerStore.sectionHeaderTitle(indexPath.section) {
                headerView.titleLabel.text = sectionTitle
            }
            return headerView
        }
        return UICollectionReusableView()
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

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


//MARK: - UISearchBarDelegate

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearchActive = false
        } else {
            isSearchActive = true
            let allTrackers = trackerStore.fetchAllTrackers()
            searchResults = allTrackers.compactMap { category in
                let matchingTrackers = category.trackers.filter { $0.name.lowercased().contains(searchText.lowercased()) }
                return matchingTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: matchingTrackers)
            }
        }
        trackersCollectionView.reloadData()
        showPlaceholder()
        showNoResultsPlaceholder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}




//MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    
    func addButtonTappedForTracker(at indexPath: IndexPath) {
        print("Current date: \(currentDate)")
        
        let categories = isSearchActive ? searchResults : trackerStore.filteredTrackers(for: currentDate)
        let selectedTracker = categories[indexPath.section].trackers[indexPath.row]
        
        let today = Date()
        if currentDate > today {
            return
        }
        
        let isCompleted = trackerRecordStore.isTrackerCompleted(selectedTracker, on: currentDate)
        print("Is tracker completed: \(isCompleted) for tracker \(selectedTracker.id)")
        
        if isCompleted {
            print("Deleting tracker record for \(selectedTracker.id)")
            trackerRecordStore.deleteTrackerRecord(for: selectedTracker, on: currentDate)
        } else {
            print("Adding new tracker record for \(selectedTracker.id)")
            let newRecord = TrackerRecord(id: selectedTracker.id, date: currentDate)
            trackerRecordStore.addNewTrackerRecord(newRecord, for: selectedTracker)
        }
        trackersCollectionView.reloadItems(at: [indexPath])
    }
    
    
    func formatDaysString(_ days: Int) -> String {
        let remainder10 = days % 10
        let remainder100 = days % 100
        
        if remainder10 == 1, remainder100 != 11 {
            return "\(days) день"
        } else if remainder10 >= 2, remainder10 <= 4, (remainder100 < 10 || remainder100 >= 20) {
            return "\(days) дня"
        } else {
            return "\(days) дней"
        }
    }
}

//MARK: - TrackerViewControllerDelegate

extension TrackersViewController: TrackerCreationDelegate {
    
    func didCreateTracker(_ tracker: Tracker, category: TrackerCategory, isEvent: Bool) {
        let categoryTitle = category.title
        trackerStore.addNewTracker(tracker, to: TrackerCategory(title: categoryTitle, trackers: []))
        dismiss(animated: true)
    }
}

//MARK: - TrackerStoreDelegate

extension TrackersViewController: TrackerStoreDelegate {
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
        trackersCollectionView.reloadData()
        showPlaceholder()
    }
}











