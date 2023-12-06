//
//  TrackerStore.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 25.11.2023.
//

import CoreData
import UIKit

enum TrackerStoreError: Error {
    case decodingErroeInvalidId
    case decodingErrorInvalidName
    case decodingErrorInvalidColor
    case decodingErrorInvalidEmoji
    case decodingErrorInvalidSchedule
}


final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
    }

    
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id else {
            throw TrackerStoreError.decodingErroeInvalidId
        }
        guard let name = trackerCoreData.name else {
            throw TrackerStoreError.decodingErrorInvalidName
        }
        guard let color = trackerCoreData.color else {
            throw TrackerStoreError.decodingErrorInvalidColor
        }
        guard let emoji = trackerCoreData.emoji else {
            throw TrackerStoreError.decodingErrorInvalidEmoji
        }
        guard let schedule = trackerCoreData.schedule else {
            throw TrackerStoreError.decodingErrorInvalidSchedule
        }
        return Tracker(
            name: name,
            color: color as? UIColor,
            emoji: emoji,
            schedule: schedule as! [Schedule])
    }

    func addNewTracker(_ tracker: Tracker, to category: TrackerCategory?) {
        let trackerCoreData = TrackerCoreData(context: context)
        let categoryCoreData = category != nil ? getTrackerCategoryCoreData(by: category!.title) : nil
        updateExistingTracker(trackerCoreData, with: tracker, category: categoryCoreData)

        if let categoryCoreData = categoryCoreData {
            categoryCoreData.addToTrackers(trackerCoreData)
        }

        AppDelegate.shared?.saveContext()
    }


    func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker, category: TrackerCategoryCoreData?) {
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule as NSObject
        trackerCoreData.category = category // Устанавливаем связь с категорией
    }
    
    
    func getTrackerCategoryCoreData(by title: String) -> TrackerCategoryCoreData? {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)

        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching TrackerCategoryCoreData: \(error)")
            return nil
        }
    }
    
    func printAllTrackersFromCoreData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCoreData")
        do {
            let trackers = try context.fetch(fetchRequest) as! [TrackerCoreData]
            for tracker in trackers {
                guard let id = tracker.id else {throw TrackerStoreError.decodingErroeInvalidId}
                let name = tracker.name ?? "N/A"
                let color = tracker.color
                let emoji = tracker.emoji ?? "N/A"
                guard let schedule = tracker.schedule else { throw TrackerStoreError.decodingErrorInvalidSchedule }
                
                print("ID: \(id), Name: \(name), Color: \(String(describing: color)), Emoji: \(emoji), Schedule: \(String(describing: schedule))")
            }
        } catch {
            print("Failed to fetch trackers from CoreData: \(error)")
        }
    }
    
    
}
