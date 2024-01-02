//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 05.09.2023.
//

import UIKit


final class TrackersViewController: UIViewController {
    
    private let trackerStore: TrackerStore
    private let trackerCategoryStore: TrackerCategoryStore
    private let trackerRecordStore: TrackerRecordStore
    private let analyticsService: AnalyticsService
    private var filteredCategories: [TrackerCategory] = []
    private let searchBar: UISearchBar
    

    init(trackerStore: TrackerStore,
         trackerCategoryStore: TrackerCategoryStore,
         trackerRecordStore: TrackerRecordStore,
         analyticsService: AnalyticsService,
         searchBar: UISearchBar = UISearchBar()) {
        self.trackerStore = trackerStore
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore
        self.analyticsService = analyticsService
        self.searchBar = searchBar
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var currentFilter: FilterType = .allTrackers
    private var currentDate: Date = Date()
    private var searchResults: [TrackerCategory] = []
    private var isSearchActive: Bool = false
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale.current
        datePicker.calendar = Calendar.current
        datePicker.calendar.firstWeekday = 2
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return datePicker
    }()
    
    private let trackersLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("trackers", comment: "text for trackersLabel")
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
        label.text = NSLocalizedString("what_to_track", comment: "text for noTrackersCreatedLabel")
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
        label.text = NSLocalizedString("nothing_found", comment: "text for nothing_found")
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
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton()
        let filtersLabel = NSLocalizedString("filters", comment: "label for filtersButton")
        button.frame = CGRect(x: 0, y: 0, width: 114, height: 50)
        button.layer.cornerRadius = 16
        button.backgroundColor = .ypBlue
        button.setTitle(filtersLabel, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFPro-Regular", size: 17)
        button .translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private func showPlaceholder() -> Bool {
        let hasTrackersForCurrentDate = !trackerStore.filteredTrackers(for: currentDate).isEmpty
        let shouldShow = !isSearchActive && hasTrackersForCurrentDate

        noTrackersCreatedLabel.isHidden = shouldShow
        noTrackersCreatedImageView.isHidden = shouldShow
        trackersCollectionView.isHidden = !shouldShow
        filtersButton.isHidden = !shouldShow

        return !shouldShow
    }

    private func showNoResultsPlaceholder() {
        if showPlaceholder() {
            noTrackersFoundLabel.isHidden = true
            noTrackersFoundImageView.isHidden = true
            return
        }

        let noTrackersAfterFilter = !isSearchActive && filteredCategories.isEmpty
        let noResultsFromSearch = isSearchActive && searchResults.isEmpty
        let shouldShowNoResultsPlaceholder = noTrackersAfterFilter || noResultsFromSearch

        noTrackersFoundLabel.isHidden = !shouldShowNoResultsPlaceholder
        noTrackersFoundImageView.isHidden = !shouldShowNoResultsPlaceholder
        trackersCollectionView.isHidden = shouldShowNoResultsPlaceholder
    }

    
    @objc func addTrackerButtonTapped() {
        analyticsService.report(event: "click", screen: "Main", item: "add_track")
        let trackerTypeSelectionVC = TrackerTypeSelectionViewController()
        trackerTypeSelectionVC.delegate = self
        let navController = UINavigationController(rootViewController: trackerTypeSelectionVC)
        present(navController, animated: true, completion: nil)
    }
    
    @objc func filterButtonTapped() {
        analyticsService.report(event: "click", screen: "Main", item: "filter")
        let filtersVC = FiltersViewController()
        filtersVC.delegate = self
        present(filtersVC, animated: true, completion: nil)
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        let selectedDate = sender.date
        let calendar = Calendar.current
        let localDate = calendar.startOfDay(for: selectedDate)
        currentDate = localDate
        updateFilteredCategories()
        trackersCollectionView.reloadData()
        showPlaceholder()
        showNoResultsPlaceholder()
        
    }
    
    private func addSubViews() {
        view.addSubview(searchBar)
        view.addSubview(trackersLabel)
        view.addSubview(noTrackersCreatedImageView)
        view.addSubview(noTrackersCreatedLabel)
        view.addSubview(noTrackersFoundImageView)
        view.addSubview(noTrackersFoundLabel)
        view.addSubview(trackersCollectionView)
        view.addSubview(filtersButton)
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
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84),
            filtersButton.bottomAnchor.constraint(equalTo: trackersCollectionView.bottomAnchor, constant: -16),
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        analyticsService.report(event: "open", screen: "Main", item: nil)

        
        if let navBar = navigationController?.navigationBar {
            navBar.tintColor = UIColor.black
            let customImage = UIImage(named: "Add tracker")
            let leftButton = UIBarButtonItem(image: customImage, style: .plain, target: self, action: #selector(addTrackerButtonTapped))
            navBar.topItem?.setLeftBarButton(leftButton, animated: false)
            navBar.topItem?.setRightBarButton(UIBarButtonItem(customView: datePicker), animated: false)
        }
        
        trackersCollectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        
        searchBar.placeholder = NSLocalizedString("search", comment: "placeholder text for searchBar")
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        trackersCollectionView.delegate = self
        trackersCollectionView.dataSource = self
        trackersCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        trackerStore.delegate = self
        addSubViews()
        setUpConstraints()
        hideKeyboardWhenTappedAround()
        showPlaceholder()
        updateFilteredCategories()
        
        filtersButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        analyticsService.report(event: "close", screen: "Main", item: nil)
    }
    
    private func updateFilteredCategories() {
        let categories = isSearchActive ? searchResults : trackerStore.filteredTrackers(for: currentDate)
        filteredCategories = categories.compactMap { category in
            let filteredTrackers: [Tracker]
            switch currentFilter {
            case .allTrackers, .trackersForToday:
                filteredTrackers = category.trackers
            case .completed:
                filteredTrackers = category.trackers.filter { trackerRecordStore.isTrackerCompleted($0, on: currentDate) }
            case .notCompleted:
                filteredTrackers = category.trackers.filter { !trackerRecordStore.isTrackerCompleted($0, on: currentDate) }
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
    }
    
    private func getSectionHeaderTitle(forSection section: Int) -> String? {
        let categories = isSearchActive ? searchResults : trackerStore.filteredTrackers(for: currentDate)
        let filteredCategories = categories.filter { category in
            switch currentFilter {
            case .allTrackers, .trackersForToday:
                return !category.trackers.isEmpty
            case .completed:
                return category.trackers.contains { trackerRecordStore.isTrackerCompleted($0, on: currentDate) }
            case .notCompleted:
                return category.trackers.contains { !trackerRecordStore.isTrackerCompleted($0, on: currentDate) }
            }
        }

        return filteredCategories[section].title
    }
}


//MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCollectionViewCell
        
        cell.indexPath = indexPath
        cell.delegate = self
        
        let currentTracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        cell.configureWith(tracker: currentTracker)
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
        cell.daysCountLabel.text = String.localizedStringWithFormat(NSLocalizedString("daysCount", comment: ""), daysCount)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeaderView
            
            let sectionTitle = getSectionHeaderTitle(forSection: indexPath.section)
            headerView.titleLabel.text = sectionTitle
            
            return headerView
        }
        return UICollectionReusableView()
    }
}
//MARK: - UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let categories = isSearchActive ? searchResults : trackerStore.filteredTrackers(for: currentDate)
        let tracker = categories[indexPath.section].trackers[indexPath.row]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            let pinActionTitle = tracker.isPinned ? "Открепить" : "Закрепить"
            let pinAction = UIAction(title: pinActionTitle) { action in
                if tracker.isPinned {
                    self.trackerStore.unpinTracker(withId: tracker.id)
                } else {
                    self.trackerStore.pinTracker(withId: tracker.id)
                }
            }

            let editAction = UIAction(title: "Редактировать") { [weak self] action in
                guard let self = self else { return }
                let categoryTitle = self.trackerStore.getCategoryForTracker(withId: tracker.id) ?? ""
                analyticsService.report(event: "click", screen: "Main", item: "edit")
                
                let allDaysOfWeek: Set<Schedule> = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
                let isEvent = Set(tracker.schedule) == allDaysOfWeek

                let trackerEditVC = TrackerCreationViewController(trackerToEdit: tracker, category: categoryTitle, isEvent: isEvent)
                trackerEditVC.delegate = self
                let navController = UINavigationController(rootViewController: trackerEditVC)
                self.present(navController, animated: true, completion: nil)
            }


            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] action in
                guard let self = self else { return }
                analyticsService.report(event: "click", screen: "Main", item: "delete")

                let alertController = UIAlertController(title: "", message: "Уверены что хотите удалить трекер?", preferredStyle: .actionSheet)

                let delete = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                    self.trackerStore.deleteTracker(withId: tracker.id)
                }

                let cancel = UIAlertAction(title: "Отменить", style: .cancel)

                alertController.addAction(delete)
                alertController.addAction(cancel)

                self.present(alertController, animated: true)
            }

            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
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
        updateFilteredCategories()
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
        
        let selectedTracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        
        let today = Date()
        if currentDate > today {
            return
        }
        analyticsService.report(event: "click", screen: "Main", item: "track")
        
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
        NotificationCenter.default.post(name: .didUpdateTrackerData, object: nil)
        showNoResultsPlaceholder()
    }
}

//MARK: - TrackerViewControllerDelegate

extension TrackersViewController: TrackerCreationDelegate {
    func didUpdateTracker(_ tracker: Tracker, category: String) {
        trackerStore.updateTracker(tracker, inCategory: category)
        dismiss(animated: true)
    }
    
    func didCreateTracker(_ tracker: Tracker, category: TrackerCategory, isEvent: Bool) {
        let categoryTitle = category.title
        trackerStore.addNewTracker(tracker, to: TrackerCategory(title: categoryTitle, trackers: []))
        dismiss(animated: true)
    }
}

//MARK: - TrackerStoreDelegate

extension TrackersViewController: TrackerStoreDelegate {
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
        updateFilteredCategories()
        trackersCollectionView.reloadData()
        showNoResultsPlaceholder()
        showPlaceholder()
    }
}

//MARK: - FiltersViewControllerDelegate

extension TrackersViewController: FiltersViewControllerDelegate {
    func didSelectFilter(_ filterType: FilterType) {
        currentFilter = filterType

        if filterType == .trackersForToday {
            currentDate = Date()
            datePicker.date = currentDate
        }

        updateFilteredCategories()
        trackersCollectionView.reloadData()
        showPlaceholder()
        showNoResultsPlaceholder()
    }
}











