//
//  CoreDataTableViewController.swift
//  CoreDataTableViewController
//
//  Created by James Barrow on 18/06/2016.
//  Copyright (c) 2015-Current Pig on a Hill Productions. All rights reserved.
//

import UIKit
import CoreData

public class CoreDataTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
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
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try aFetchedResultsController.performFetch()
        } catch let error as NSError {
            NSLog("Fetch error: \(error.localizedDescription)\n\(error)")
        }
        
        return _fetchedResultsController!
    }
    public var cellIdentifier: String! { return nil }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        clearsSelectionOnViewWillAppear = true
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Refresh data
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            NSLog("Fetch error: \(error.localizedDescription)\n\(error)")
        }
    }
    
    // MARK: - Table view
    
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let sections = fetchedResultsController.sections where sections.count > section {
            
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
            
        } else {
            return 0
        }
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) 
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        // For overriding in subclasses
    }
    
    // MARK: - Fetched results controller
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }

}
