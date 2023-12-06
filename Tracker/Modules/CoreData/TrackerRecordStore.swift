//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 25.11.2023.
//


import UIKit
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext

    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func addNewTrackerRecord(_ trackerRecord: TrackerRecord, for tracker: Tracker) {
        guard let trackerCoreData = getTrackerCoreData(for: tracker) else {
            print("Error: Tracker not found in Core Data.")
            return
        }

        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        updateExistingTrackerRecord(trackerRecordCoreData, with: trackerRecord)
        
        trackerRecordCoreData.tracker = trackerCoreData

        AppDelegate.shared?.saveContext()
    }

    func updateExistingTrackerRecord(_ trackerRecordCoreData: TrackerRecordCoreData, with trackerRecord: TrackerRecord) {
        trackerRecordCoreData.date = trackerRecord.date
        trackerRecordCoreData.id = trackerRecord.id
    }

    private func getTrackerCoreData(for tracker: Tracker) -> TrackerCoreData? {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching TrackerCoreData: \(error)")
            return nil
        }
    }
}

