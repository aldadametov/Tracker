//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 25.11.2023.
//

import CoreData
import UIKit


final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    func addNewTrackerCategory(title: String, trackers: [Tracker]) {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = title
        
        trackers.forEach { tracker in
            let trackerCoreData = TrackerCoreData(context: context)
            trackerCoreData.id = tracker.id
            trackerCoreData.name = tracker.name
            trackerCoreData.color = tracker.color
            trackerCoreData.emoji = tracker.emoji
            trackerCoreData.schedule = tracker.schedule as NSObject
            
            categoryCoreData.addToTrackers(trackerCoreData)
        }
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func fetchAllCategoriesTitles() -> [String] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()

        do {
            let categories = try context.fetch(fetchRequest)
            return categories.map { $0.title ?? "" }
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
}
