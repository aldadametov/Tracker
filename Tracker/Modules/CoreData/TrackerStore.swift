//
//  TrackerStore.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 25.11.2023.
//

import CoreData
import UIKit

final class TrackerStore {
    private let context: NSManagedObjectContext
    
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewTracker (_ tracker: Tracker) {
        let trackerCoreData = TrackerCoreData(context: context)
        
    }
    
    func updateExistingTracker (_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule as NSObject
    }
}
