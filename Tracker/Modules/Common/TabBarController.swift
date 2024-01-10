//
//  TabBarController.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 08.09.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let trackerStore = TrackerStore()
        let trackerCategoryStore = TrackerCategoryStore()
        let trackerRecordStore = TrackerRecordStore()
        let analyticsService = AnalyticsService()

        let trackersViewController = TrackersViewController(
            trackerStore: trackerStore,
            trackerCategoryStore: trackerCategoryStore,
            trackerRecordStore: trackerRecordStore,
            analyticsService: analyticsService
        )

        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        let trackersLabel = NSLocalizedString("trackers", comment: "Label title for tabBarController")
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: trackersLabel,
            image: UIImage(named: "trackersButton"),
            selectedImage: nil
        )

        let statisticsViewController = StatisticsViewContoller()
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        let statisticsLabel = NSLocalizedString("statistics", comment: "Label title for tabBarController")
        statisticsNavigationController.tabBarItem = UITabBarItem(
            title: statisticsLabel,
            image: UIImage(named: "statsButton"),
            selectedImage: nil
        )
        
        if #available(iOS 13.0, *) {
            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBarAppearance.backgroundColor = .ypWhite
            UITabBar.appearance().standardAppearance = tabBarAppearance

            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
        }

        self.viewControllers = [trackersNavigationController, statisticsNavigationController]
        
    }
}

