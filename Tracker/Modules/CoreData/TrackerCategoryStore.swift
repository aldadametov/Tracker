//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 25.11.2023.
//

import CoreData
import UIKit

struct TrackerCategoryStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}

protocol TrackerCategoryStoreProtocol {
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func sectionHeaderTitle(_ section: Int) -> String?
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true) ]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: "title",
                                                    cacheName: nil)
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
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
    

    func getAllTrackerCategories() -> [TrackerCategory] {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")

        do {
            let categories = try context.fetch(fetchRequest)
            return categories.map { categoryCoreData in
                let trackers = (categoryCoreData.trackers as? Set<TrackerCoreData> ?? []).map { trackerCoreData in
                    let tracker = Tracker(
                        name: trackerCoreData.name ?? "",
                        color: trackerCoreData.color as? UIColor,
                        emoji: trackerCoreData.emoji ?? "",
                        schedule: trackerCoreData.schedule as? [Schedule] ?? []
                    )
                    return tracker
                }

                return TrackerCategory(title: categoryCoreData.title ?? "", trackers: trackers)
            }
        } catch {
            print("Error fetching categories: \(error)")
            return []
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
    
    func printAllTrackerCategories() {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")

        do {
            let categories = try context.fetch(fetchRequest)
            for category in categories {
                print("Category: \(category.title ?? "")")
                if let trackers = category.trackers as? Set<TrackerCoreData> {
                    for tracker in trackers {
                        print("  Tracker: \(tracker.name ?? "")")
                    }
                }
            }
        } catch {
            print("Error fetching categories: \(error)")
        }
    }
}


extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func sectionHeaderTitle(_ section: Int) -> String? {
        guard let sections = fetchedResultsController.sections, section < sections.count else {
            return nil
        }
        
        let title = sections[section].name
        return title.isEmpty == false ? title : "Default Section Title"
    }
    
    func item(at indexPath: IndexPath) -> Tracker {
        let categoryCoreData = fetchedResultsController.object(at: indexPath)
        
        let trackerCoreData = (categoryCoreData.trackers as? Set<TrackerCoreData> ?? []).first!
        
        let tracker = Tracker(
            name: trackerCoreData.name ?? "",
            color: trackerCoreData.color as? UIColor,
            emoji: trackerCoreData.emoji ?? "",
            schedule: trackerCoreData.schedule as? [Schedule] ?? []
        )
        
        return tracker
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerCategoryStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}
