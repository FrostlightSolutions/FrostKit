//
//  CoreDataController.swift
//  FrostKit
//
//  Created by James Barrow on 18/06/2016.
//  Copyright © 2016 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataController: NSObject {
    
    // MARK: - Properties
    
    public var entityName: String! { return nil }
    public var sectionNameKeyPath: String? { return nil }
    public var cacheName: String? { return nil }
    public var sortDescriptors: [NSSortDescriptor] { return Array<NSSortDescriptor>() }
    public var predicate: NSPredicate? { return nil }
    private var _fetchedResultsController: NSFetchedResultsController?
    public var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let context = DataProxy.shared.managedObjectContextMain!
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Set the sort descriptors
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate
        fetchRequest.predicate = predicate
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try aFetchedResultsController.performFetch()
        } catch let error as NSError {
            NSLog("Fetch error: \(error.localizedDescription)\n\(error)")
        }
        
        return _fetchedResultsController!
    }
    
}
