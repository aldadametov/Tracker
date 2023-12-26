//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Алишер Дадаметов on 26.12.2023.
//

import XCTest
import SnapshotTesting
@testable import Tracker

class MockTrackerStore: TrackerStore {
    var testTrackers: [TrackerCategory] = []
    
    override func filteredTrackers(for currentDate: Date) -> [TrackerCategory] {
        return testTrackers
    }
    
    override func fetchAllTrackers() -> [TrackerCategory] {
        return testTrackers
    }
    
    override func sectionHeaderTitle(_ section: Int) -> String? {
        guard section < testTrackers.count else { return nil }
        return testTrackers[section].title
    }
}

final class TrackerTests: XCTestCase {
    func testTrackersViewControllerWithEmptyState() {
        let mockStore = MockTrackerStore()
        mockStore.testTrackers = [] // Пустой массив для симуляции пустого состояния
        
        let viewController = TrackersViewController(
            trackerStore: mockStore,
            trackerCategoryStore: TrackerCategoryStore(),
            trackerRecordStore: TrackerRecordStore()
        )
        
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneX))
    }
    
    func testTrackersViewControllerWithData() {
        let mockStore = MockTrackerStore()
        // Предоставьте тестовые данные трекеров здесь
        mockStore.testTrackers = [TrackerCategory(
            title: "Уборка",
            trackers: [
                Tracker(
                    name: "Помыть посуду",
                    color: .ypBlue,
                    emoji: "💦",
                    schedule: [.monday, .tuesday, .saturday, .friday]),
            ]),
                                  TrackerCategory(
                                    title: "Отдых",
                                    trackers: [
                                        Tracker(
                                            name: "Пройти СпайдерМена на Платину",
                                            color: .ypRed,
                                            emoji: "🕷️",
                                            schedule: [.sunday])
                                    ])]
        
        let viewController = TrackersViewController(
            trackerStore: mockStore,
            trackerCategoryStore: TrackerCategoryStore(),
            trackerRecordStore: TrackerRecordStore()
        )
        
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneX))
    }
    
    func testTrackersViewControllerSearchActive() {
        let mockStore = MockTrackerStore()
        let mockSearchBar = UISearchBar()
        mockStore.testTrackers = [TrackerCategory(
            title: "Отдых",
            trackers: [
                Tracker(
                    name: "Пройти СпайдерМена на Платину",
                    color: .ypRed,
                    emoji: "🕷️",
                    schedule: [.sunday])
            ])]
        
        let viewController = TrackersViewController(
            trackerStore: mockStore,
            trackerCategoryStore: TrackerCategoryStore(),
            trackerRecordStore: TrackerRecordStore(),
            searchBar: mockSearchBar
        )
        viewController.loadViewIfNeeded()
        
        mockSearchBar.text = "Пройти"
        viewController.searchBar(mockSearchBar, textDidChange: "Пройти")
        
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneX))
    }
    
    func testTrackersViewControllerTrackersNotfound() {
        let mockStore = MockTrackerStore()
        let mockSearchBar = UISearchBar()
        mockStore.testTrackers = []
        
        let viewController = TrackersViewController(
            trackerStore: mockStore,
            trackerCategoryStore: TrackerCategoryStore(),
            trackerRecordStore: TrackerRecordStore(),
            searchBar: mockSearchBar
        )
        viewController.loadViewIfNeeded()
        
        mockSearchBar.text = "Пройти"
        viewController.searchBar(mockSearchBar, textDidChange: "Пройти")
        
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneX))
    }
}

