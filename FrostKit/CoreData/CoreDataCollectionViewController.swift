//
//  CoreDataCollectionViewController.swift
//  FrostKit
//
//  Created by James Barrow on 18/06/2016.
//  Copyright © 2016 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit
import CoreData

open class CoreDataCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    @IBOutlet public weak var dataController: CoreDataController! {
        didSet { dataController.fetchedResultsController.delegate = self }
    }
    
    open var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        return dataController.fetchedResultsController
    }
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        clearsSelectionOnViewWillAppear = false
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchAndReloadData()
    }
    
    // MARK: Collection view
    
    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let sections = fetchedResultsController.sections, sections.count > section {
            
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
            
        } else {
            return 0
        }
    }
    
    // MARK: - Fetched results controller
    
    open func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.reloadData()
    }
    
    open func fetchAndReloadData() {
        
        // Refresh and reload data
        do {
            try fetchedResultsController.performFetch()
            collectionView?.reloadData()
        } catch let error {
            NSLog("Fetch error: \(error.localizedDescription)")
        }
    }
}
