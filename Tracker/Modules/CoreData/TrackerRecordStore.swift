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
    private let trackerStore = TrackerStore()
    
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewTrackerRecord(_ trackerRecord: TrackerRecord, for tracker: Tracker) {
        guard let trackerCoreData = getTrackerCoreData(for: tracker) else {
            return
        }
        
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.date = trackerRecord.date
        trackerRecordCoreData.id = trackerRecord.id
        trackerRecordCoreData.tracker = trackerCoreData

        do {
            try context.save()
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
            return nil
        }
    }
    
    func deleteTrackerRecord(for tracker: Tracker, on date: Date) {
        guard let trackerCoreData = getTrackerCoreData(for: tracker) else {
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
            return 0
        }
    }

}

extension TrackerRecordStore {
    func totalCompletedTrackers() -> Int {
        let fetchRequest: NSFetchRequest<NSNumber> = NSFetchRequest(entityName: "TrackerRecordCoreData")
        fetchRequest.resultType = .countResultType
        
        do {
            let countResult = try context.fetch(fetchRequest)
            return countResult.first?.intValue ?? 0
        } catch {
            print("Error counting completed trackers: \(error)")
            return 0
        }
    }
    
    func countPerfectDays() -> Int {
        var perfectDaysCount = 0

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TrackerRecordCoreData")
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToGroupBy = ["date"]
        fetchRequest.propertiesToFetch = ["date"]

        do {
            let results = try context.fetch(fetchRequest) as! [NSDictionary]

            for result in results {
                if let date = result["date"] as? Date {
                    let dayStart = Calendar.current.startOfDay(for: date)

                    let activeTrackersCount = trackerStore.filteredTrackers(for: dayStart).flatMap { $0.trackers }.count

                    let completedFetchRequest: NSFetchRequest<NSNumber> = NSFetchRequest(entityName: "TrackerRecordCoreData")
                    completedFetchRequest.resultType = .countResultType
                    completedFetchRequest.predicate = NSPredicate(format: "date == %@", dayStart as NSDate)

                    let completedCount = try context.count(for: completedFetchRequest)

                    if completedCount == activeTrackersCount {
                        perfectDaysCount += 1
                    }
                }
            }

            return perfectDaysCount
        } catch {
            print("Error in counting perfect days: \(error)")
            return 0
        }
    }
    
    func averageCompletedTrackers() -> Int {
        let completedCountRequest: NSFetchRequest<NSNumber> = NSFetchRequest(entityName: "TrackerRecordCoreData")
        completedCountRequest.resultType = .countResultType

        let uniqueDaysRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TrackerRecordCoreData")
        uniqueDaysRequest.resultType = .dictionaryResultType
        uniqueDaysRequest.propertiesToGroupBy = ["date"]
        uniqueDaysRequest.propertiesToFetch = ["date"]

        do {
            let completedCount = try context.count(for: completedCountRequest)
            let uniqueDaysResults = try context.fetch(uniqueDaysRequest)
            let uniqueDaysCount = uniqueDaysResults.count

            if uniqueDaysCount > 0 {
                let average = Double(completedCount) / Double(uniqueDaysCount)
                return Int(round(average))
            }
        } catch {
            print("Error calculating average completed trackers: \(error)")
        }

        return 0
    }

    func findLongestStreak() -> Int {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        do {
            let records = try context.fetch(fetchRequest)
            var longestStreak = 0
            var currentStreak = 1
            var previousDate: Date?

            for record in records {
                guard let date = record.date else { continue }
                
                if let prevDate = previousDate {
                    let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: prevDate)!
                    
                    if Calendar.current.isDate(date, inSameDayAs: prevDate) {
                        continue
                    } else if Calendar.current.isDate(date, inSameDayAs: nextDay) {
                        currentStreak += 1
                    } else {
                        longestStreak = max(longestStreak, currentStreak)
                        currentStreak = 1
                    }
                }
                previousDate = date
            }
            longestStreak = max(longestStreak, currentStreak)

            return longestStreak
        } catch {
            print("Error finding longest streak: \(error)")
            return 0
        }
    }



}
