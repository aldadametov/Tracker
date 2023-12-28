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

struct TrackerStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
    let insertedSections: IndexSet
    let deletedSections: IndexSet
}

protocol TrackerStoreDelegate: AnyObject {
    func store(
        _ store: TrackerStore,
        didUpdate update: TrackerStoreUpdate
    )
}

class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    weak var delegate: TrackerStoreDelegate?
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerStoreUpdate.Move>?
    private var insertedSections: IndexSet?
    private var deletedSections: IndexSet?
    

    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            try self.init(context: context)
        } catch {
            assertionFailure("Ошибка инициализации TrackerStore: \(error)")
            self.init(fallbackContext: context)
        }
    }

    init(fallbackContext: NSManagedObjectContext) {
        self.context = fallbackContext
        super.init()
    }

    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "isPinned", ascending: false),
            NSSortDescriptor(key: "category.title", ascending: true),
        ]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: "category.title",
                                                    cacheName: nil)
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
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
        let isPinned = trackerCoreData.isPinned
        return Tracker(
            id: id,
            name: name,
            color: color as? UIColor,
            emoji: emoji,
            schedule: schedule as! [Schedule],
            isPinned: isPinned
        )
            
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
        trackerCoreData.isPinned = tracker.isPinned
        
        if !tracker.isPinned && trackerCoreData.originalCategory != nil {
            let originalCategory = getTrackerCategoryCoreData(by: trackerCoreData.originalCategory! )
            trackerCoreData.category = originalCategory
            trackerCoreData.originalCategory = nil
        }
    }
    
    func updateTracker(_ updatedTracker: Tracker, inCategory categoryName: String) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", updatedTracker.id as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            if let trackerToUpdate = results.first {
                trackerToUpdate.name = updatedTracker.name
                trackerToUpdate.color = updatedTracker.color
                trackerToUpdate.emoji = updatedTracker.emoji
                trackerToUpdate.schedule = updatedTracker.schedule as NSObject
                trackerToUpdate.isPinned = updatedTracker.isPinned

                let category = getTrackerCategoryCoreData(by: categoryName) ?? {
                    let newCategory = TrackerCategoryCoreData(context: context)
                    newCategory.title = categoryName
                    return newCategory
                }()
                trackerToUpdate.category = category

                try context.save()
            }
        } catch {
            print("Error updating tracker: \(error)")
        }
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
    
    func getCategoryForTracker(withId id: UUID) -> String? {
        guard let sections = fetchedResultsController.sections else { return nil }

        for section in sections {
            if let trackersInCategory = section.objects as? [TrackerCoreData],
               trackersInCategory.contains(where: { $0.id == id }) {
                return section.name
            }
        }
        return nil
    }

    func moveToPinnedCategory(withId id: UUID) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            if let trackerToMove = results.first {
                if trackerToMove.originalCategory == nil {
                    trackerToMove.originalCategory = trackerToMove.category?.title
                }

                let pinnedCategoryTitle = "Закрепленные"
                var pinnedCategory = getTrackerCategoryCoreData(by: pinnedCategoryTitle)
                if pinnedCategory == nil {
                    pinnedCategory = TrackerCategoryCoreData(context: context)
                    pinnedCategory!.title = pinnedCategoryTitle
                }

                trackerToMove.category = pinnedCategory
                try context.save()
            }
        } catch {
            print("Error moving tracker to pinned category: \(error)")
        }
    }
    
    func moveToOriginalCategory(withId id: UUID) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            if let trackerToMove = results.first,
               let originalCategoryTitle = trackerToMove.originalCategory {
                let originalCategory = getTrackerCategoryCoreData(by: originalCategoryTitle) ?? TrackerCategoryCoreData(context: context)
                trackerToMove.category = originalCategory

                trackerToMove.originalCategory = nil
                try context.save()
            }
        } catch {
            print("Error moving tracker to original category: \(error)")
        }
    }

    
    func pinTracker(withId id: UUID) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            if let trackerToPin = results.first {
                trackerToPin.isPinned = true
                moveToPinnedCategory(withId: id)
                try context.save()
            }
        } catch {
            print("Error pinning tracker: \(error)")
        }
    }

    func unpinTracker(withId id: UUID) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            if let trackerToUnpin = results.first {
                trackerToUnpin.isPinned = false
                moveToOriginalCategory(withId: id)
                try context.save()
            }
        } catch {
            print("Error unpinning tracker: \(error)")
        }
    }
    
    func filteredTrackers(for currentDate: Date) -> [TrackerCategory] {
        guard let sections = fetchedResultsController.sections else { return [] }

        var filteredCategories = [TrackerCategory]()

        for section in sections {
            let categoryTitle = section.name
            let trackersInCategory = section.objects as? [TrackerCoreData] ?? []

            let filteredTrackers = trackersInCategory.compactMap { trackerCoreData -> Tracker? in
                guard let schedule = trackerCoreData.schedule as? [Schedule],
                      let selectedDay = getDayOfWeek(currentDate),
                      schedule.contains(selectedDay) else {
                    return nil
                }
                return try? tracker(from: trackerCoreData)
            }

            if !filteredTrackers.isEmpty {
                let category = TrackerCategory(title: categoryTitle, trackers: filteredTrackers)
                filteredCategories.append(category)
            }
        }

        return filteredCategories
    }


    
    func sectionHeaderTitle(_ section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] as? NSFetchedResultsSectionInfo else { return nil }
        
        if let firstObject = sectionInfo.objects?.first as? TrackerCoreData,
           let category = firstObject.category,
           let categoryName = category.title {
            return categoryName
        }
        
        return nil
    }
    
    func tracker(for indexPath: IndexPath, currentDate: Date) -> Tracker? {
        guard let sectionInfo = fetchedResultsController.sections?[indexPath.section],
              let trackerCoreData = sectionInfo.objects?[indexPath.row] as? TrackerCoreData,
              let schedule = trackerCoreData.schedule as? [Schedule],
              let selectedDay = getDayOfWeek(currentDate) else {
            return nil
        }

        if schedule.contains(selectedDay) {
            return try? tracker(from: trackerCoreData)
        } else {
            return nil
        }
    }

    func getDayOfWeek(_ date: Date) -> Schedule? {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        return Schedule(rawValue: dayOfWeek)
    }
    
    func fetchAllTrackers() -> [TrackerCategory] {
        guard let sections = fetchedResultsController.sections else { return [] }

        var allCategories = [TrackerCategory]()

        for section in sections {
            let categoryTitle = section.name
            let trackersInCategory = (section.objects as? [TrackerCoreData] ?? []).compactMap { try? tracker(from: $0) }

            let category = TrackerCategory(title: categoryTitle, trackers: trackersInCategory)
            allCategories.append(category)
        }

        return allCategories
    }
}


extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerStoreUpdate.Move>()
        insertedSections = IndexSet()
        deletedSections = IndexSet ()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerStoreUpdate(
                insertedIndexes: insertedIndexes ?? IndexSet(),
                deletedIndexes: deletedIndexes ?? IndexSet(),
                updatedIndexes: updatedIndexes ?? IndexSet(),
                movedIndexes: movedIndexes ?? Set<TrackerStoreUpdate.Move>(),
                insertedSections: insertedSections ?? IndexSet(),
                deletedSections: deletedSections ?? IndexSet()
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
        insertedSections = nil
        deletedSections = nil
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError() }
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else { fatalError() }
            updatedIndexes?.insert(indexPath.item)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
        @unknown default:
            fatalError()
        }
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        switch type {
        case .insert:
            insertedSections?.insert(sectionIndex)
        case .delete:
            deletedSections?.insert(sectionIndex)
        default:
            break
        }
    }
}



