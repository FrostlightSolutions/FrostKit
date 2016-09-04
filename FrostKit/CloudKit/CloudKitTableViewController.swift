//
//  CloudKitTableViewController.swift
//  FrostKit
//
//  Created by James Barrow on 15/08/2016.
//  Copyright © 2016-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit
import CloudKit

public class CloudKitTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var records = [CKRecord]()
    private var firstLoad = true
    
    public var loading = false
    @IBInspectable public var recordsPerPage: Int = 25
    @IBInspectable public var recordType: String = ""
    
    public var container: CKContainer {
        return CKContainer.defaultContainer()
    }
    public var database: CKDatabase {
        return container.publicCloudDatabase
    }
    public var query: CKQuery {
        
        let predicate = NSPredicate(value: true)
        let _query = CKQuery(recordType: recordType, predicate: predicate)
        return _query
    }
    private var queryOperation: CKQueryOperation {
        
        let _queryOperation: CKQueryOperation
        if let cursor = queryCursor {
            _queryOperation = CKQueryOperation(cursor: cursor)
        } else {
            _queryOperation = CKQueryOperation(query: query)
        }
        
        _queryOperation.resultsLimit = recordsPerPage
        
        return _queryOperation
    }
    private var queryCursor: CKQueryCursor?
    
    @IBOutlet public var tableFooterView: UIView?
    
    // MARK: - Init
    
    public convenience init(recordType: String, style: UITableViewStyle) {
        self.init(style: style)
        
        self.recordType = recordType
    }
    
    public convenience init(recordType: String) {
        self.init(recordType: recordType, style: .Plain)
    }
    
    // MARK: - View Lifecycle
    
    public override func loadView() {
        super.loadView()
        
        if let refreshControl = self.refreshControl {
            refreshControl.addTarget(self, action: #selector(refreshControlValueChanged(_:)), forControlEvents: .ValueChanged)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        clearsSelectionOnViewWillAppear = true
        loadRecords()
    }
    
    // MARK: - Data
    
    public func recordsWillLoad() {
        
        if tableView.tableFooterView == nil {
            tableView.tableFooterView = tableFooterView
        }
    }
    
    public func recordsDidLoad(error: NSError?) {
        
        tableView.tableFooterView = nil
        
        if firstLoad == true {
            firstLoad = false
        }
    }
    
    public func clear() {
        
        records.removeAll()
        tableView.reloadData()
        queryCursor = nil
    }
    
    private func loadRecords() {
        
        loading = true
        recordsWillLoad()
        
        let operation = queryOperation
        operation.qualityOfService = .UserInteractive
        
        operation.recordFetchedBlock = { (record: CKRecord) in
            self.records.append(record)
        }
        
        operation.queryCompletionBlock = { (cursor: CKQueryCursor?, error: NSError?) in
            
            self.loading = false
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if let anError = error {
                    NSLog("Query Operation Error: \(anError.localizedDescription)")
                } else {
                    
                    self.queryCursor = cursor
                    self.tableView.reloadData()
                }
                
                self.recordsDidLoad(error)
                if let refreshControl = self.refreshControl where refreshControl.refreshing == true {
                    refreshControl.endRefreshing()
                }
            }
        }
        
        database.addOperation(operation)
    }
    
    private func loadNextPage() {
        
        if loading == false {
            loadRecords()
        }
    }
    
    // MARK: - Actions
    
    internal func refreshControlValueChanged(sender: UIRefreshControl) {
        loadRecords()
    }
    
    // MARK: - Table View
    
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier", forIndexPath: indexPath)
        
        let record = records[indexPath.row]
        cell.textLabel?.text = record.recordID.recordName
        
        return cell
    }
    
    // MARK: - Table View
    
    public override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if (firstLoad == true || queryCursor != nil) && loading == false &&
            tableView.contentOffset.y >= tableView.contentSize.height - tableView.frame.size.height {
            loadRecords()
        }
    }
    
}
