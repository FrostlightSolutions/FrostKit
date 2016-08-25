//
//  CoreDataTableViewController.swift
//  FrostKit
//
//  Created by James Barrow on 18/06/2016.
//  Copyright © 2016-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit
import CoreData

public class CoreDataTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    @IBOutlet public weak var dataController: CoreDataController! {
        didSet { dataController.fetchedResultsController.delegate = self }
    }
    public var fetchedResultsController: NSFetchedResultsController {
        return dataController.fetchedResultsController
    }
    
    // MARK: - View lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        clearsSelectionOnViewWillAppear = true
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchAndReloadData()
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
    
    // MARK: - Fetched results controller
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
    
    public func fetchAndReloadData() {
        
        // Refresh and reload data
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch let error as NSError {
            NSLog("Fetch error: \(error.localizedDescription)\n\(error)")
        }
    }
    
}
