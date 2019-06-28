//
//  CoreDataController.swift
//  FrostKit
//
//  Created by James Barrow on 18/06/2016.
//  Copyright © 2016 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation
import CoreData

// Needs to be a subclass of NSObject to allow it to be used with @IBOutlet
@available(iOS, deprecated: 10.0, message: "This is no longer needed as of iOS 10. Use NSPersistentContainer instead. This class will be removed in v2.0.0 of FrostKit.")
open class CoreDataController: NSObject {
    
    // MARK: - Properties
    
    open var context: NSManagedObjectContext { return CoreDataProxy.shared.managedObjectContextMain }
    open var entityName: String! { return nil }
    open var sectionNameKeyPath: String? { return nil }
    open var cacheName: String? { return nil }
    open var sortDescriptors: [NSSortDescriptor] { return [NSSortDescriptor]() }
    open var predicate: NSPredicate? { return nil }
    open var filterPredicate: NSPredicate? {
        didSet { resetFetchedResultsController() }
    }
    private var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    open var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Set the sort descriptors
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate
        if let filterPredicate = self.filterPredicate {
            
            var predicates = [NSPredicate]()
            if let predicate = self.predicate {
                predicates.append(predicate)
            }
            predicates.append(filterPredicate)
            
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            
        } else {
            fetchRequest.predicate = predicate
        }
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try aFetchedResultsController.performFetch()
        } catch let error {
            DLog("Fetch error: \(error.localizedDescription)")
        }
        
        return _fetchedResultsController!
    }
    
    public func object<T: NSManagedObject>(at indexPath: IndexPath) -> T? {
        
        guard let sections = fetchedResultsController.sections, indexPath.section < sections.count else {
            return nil
        }
        
        let section = sections[indexPath.section]
        guard indexPath.row < section.numberOfObjects else {
            return nil
        }
        
        return fetchedResultsController.object(at: indexPath) as? T
    }
    
    public func resetFetchedResultsController() {
        _fetchedResultsController = nil
    }
    
    open func updateDateIfNeeded() {
        // Use mainly in subclasses, otherwise this will just reset
        resetFetchedResultsController()
    }
}
