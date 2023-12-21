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
        trackerRecordCoreData.date = trackerRecord.date
        trackerRecordCoreData.id = trackerRecord.id
        trackerRecordCoreData.tracker = trackerCoreData // Установите свойство tracker

        do {
            try context.save()
            print("Saving TrackerRecord for \(trackerRecord.id) on \(trackerRecord.date)")
        } catch {
            print("Error saving TrackerRecord: \(error)")
        }
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
    
    func deleteTrackerRecord(for tracker: Tracker, on date: Date) {
        guard let trackerCoreData = getTrackerCoreData(for: tracker) else {
            print("Error: Tracker not found in Core Data.")
            return
        }

        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!

        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.predicate = NSPredicate(format: "tracker == %@ AND date >= %@ AND date < %@", trackerCoreData, startDate as CVarArg, endDate as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            for record in results {
                context.delete(record)
            }
            AppDelegate.shared?.saveContext()
        } catch {
            print("Error deleting TrackerRecordCoreData: \(error)")
        }
    }
    
    func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        guard let trackerCoreData = getTrackerCoreData(for: tracker) else { return false }

        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!

        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker == %@ AND date >= %@ AND date < %@", trackerCoreData, startDate as CVarArg, endDate as CVarArg)

        do {
            let records = try context.fetch(fetchRequest)
            return !records.isEmpty
        } catch {
            print("Error checking if tracker is completed: \(error)")
            return false
        }
    }
    
    func countCompletedDays(for tracker: Tracker) -> Int {
        guard let trackerCoreData = getTrackerCoreData(for: tracker) else { return 0 }

        let fetchRequest: NSFetchRequest<NSNumber> = NSFetchRequest(entityName: "TrackerRecordCoreData")
        fetchRequest.resultType = .countResultType
        fetchRequest.predicate = NSPredicate(format: "tracker == %@", trackerCoreData)

        do {
            let countResult = try context.fetch(fetchRequest)
            return countResult.first?.intValue ?? 0
        } catch {
            print("Error counting completed days: \(error)")
            return 0
        }
    }

}


