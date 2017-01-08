//
//  CloudKitTableViewController.swift
//  FrostKit
//
//  Created by James Barrow on 15/08/2016.
//  Copyright © 2016 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit
import CloudKit

open class CloudKitTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var records = [CKRecord]()
    private var firstLoad = true
    
    public var loading = false
    @IBInspectable public var recordsPerPage: Int = 25
    @IBInspectable public var recordType: String = ""
    
    open var container: CKContainer {
        return CKContainer.default()
    }
    open var database: CKDatabase {
        return container.publicCloudDatabase
    }
    open var query: CKQuery {
        
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
        self.init(recordType: recordType, style: .plain)
    }
    
    // MARK: - View Lifecycle
    
    open override func loadView() {
        super.loadView()
        
        if let refreshControl = self.refreshControl {
            refreshControl.addTarget(self, action: #selector(refreshControlValueChanged(_:)), for: .valueChanged)
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        clearsSelectionOnViewWillAppear = true
        loadRecords()
    }
    
    // MARK: - Data
    
    open func recordsWillLoad() {
        
        if tableView.tableFooterView == nil {
            tableView.tableFooterView = tableFooterView
        }
    }
    
    open func recordsDidLoad(error: Error?) {
        
        tableView.tableFooterView = nil
        
        if firstLoad == true {
            firstLoad = false
        }
    }
    
    open func clear() {
        
        records.removeAll()
        tableView.reloadData()
        queryCursor = nil
    }
    
    private func loadRecords() {
        
        loading = true
        recordsWillLoad()
        
        let operation = queryOperation
        operation.qualityOfService = .userInteractive
        
        operation.recordFetchedBlock = { (record: CKRecord) in
            self.records.append(record)
        }
        
        operation.queryCompletionBlock = { (cursor: CKQueryCursor?, error: Error?) in
            
            self.loading = false
            
            DispatchQueue.main.async {
                
                if let anError = error {
                    NSLog("Query Operation Error: \(anError.localizedDescription)")
                } else {
                    
                    self.queryCursor = cursor
                    self.tableView.reloadData()
                }
                
                self.recordsDidLoad(error: error)
                if let refreshControl = self.refreshControl, refreshControl.isRefreshing == true {
                    refreshControl.endRefreshing()
                }
            }
        }
        
        database.add(operation)
    }
    
    private func loadNextPage() {
        
        if loading == false {
            loadRecords()
        }
    }
    
    // MARK: - Actions
    
    internal func refreshControlValueChanged(_ sender: UIRefreshControl) {
        loadRecords()
    }
    
    // MARK: - Table View
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath as IndexPath)
        
        let record = records[indexPath.row]
        cell.textLabel?.text = record.recordID.recordName
        
        return cell
    }
    
    // MARK: - Table View
    
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (firstLoad == true || queryCursor != nil) && loading == false &&
            tableView.contentOffset.y >= tableView.contentSize.height - tableView.frame.size.height {
            loadRecords()
        }
    }
    
}
