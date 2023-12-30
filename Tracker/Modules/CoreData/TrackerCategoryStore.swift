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
            trackerCoreData.color = tracker.color?.toHexString()
            trackerCoreData.emoji = tracker.emoji
            trackerCoreData.schedule = tracker.schedule as NSObject
            trackerCoreData.isPinned = tracker.isPinned
            categoryCoreData.addToTrackers(trackerCoreData)
        }
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func deleteCategory(named categoryName: String) {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", categoryName)

        do {
            let results = try context.fetch(fetchRequest)
            if let categoryToDelete = results.first {
                context.delete(categoryToDelete)
                try context.save()
            }
        } catch {
            print("Error deleting category: \(error)")
        }
    }
    
    func updateCategory(oldTitle: String, newTitle: String) {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", oldTitle)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let categoryToUpdate = results.first {
                categoryToUpdate.title = newTitle
                try context.save()
            }
        } catch {
            print("Error updating category: \(error)")
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
