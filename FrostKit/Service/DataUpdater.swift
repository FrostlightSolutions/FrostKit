//
//  DataUpdater.swift
//  FrostKit
//
//  Created by James Barrow on 26/01/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit

public class DataUpdater: NSObject, DataStoreDelegate {

    public let requestStore = RequestStore()
    @IBOutlet var viewController: UIViewController! {
        didSet {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: "refreshControlTriggered:", forControlEvents: .ValueChanged)
            refreshControl.tintColor = FrostKit.shared.tintColor
            
            if let tableViewController = viewController as? UITableViewController {
                tableViewController.refreshControl = refreshControl
            } else if let collectionViewController = viewController as? UICollectionViewController {
                collectionViewController.refreshControl = refreshControl
            }
        }
    }
    @IBOutlet var tableView: UITableView? {
        didSet {
            if let tableView = self.tableView {
                tableView.estimatedRowHeight = 44
                if UIDevice.SystemVersion.majorVersion >= 8 {
                    tableView.rowHeight = UITableViewAutomaticDimension
                }
                updateTableFooter()
            }
        }
    }
    @IBOutlet var collectionView: UICollectionView?
    public var sectionDictionary: NSDictionary? {
        didSet {
            if let sectionDictionary = self.sectionDictionary {
                let urlString = sectionDictionary["url"] as String
                if let localDataStore = UserStore.current.dataStoreForURL(urlString) {
                    dataStore = localDataStore
                }
            }
        }
    }
    public lazy var dataStore = DataStore()
    private var lastLoadedPage: Int?
    
    convenience public init(viewController: UIViewController, tableView: UITableView) {
        self.init()
        
        self.viewController = viewController
        self.tableView = tableView
    }
    
    convenience public init(viewController: UIViewController, collectionView: UICollectionView) {
        self.init()
        
        self.viewController = viewController
        self.collectionView = collectionView
    }
    
    public func viewWillAppear(animated: Bool) {
        endRefreshing()
        updateData()
    }
    
    func updateTableFooter(count: Int = 0) {
        if let tableView = self.tableView {
            // If the data array is empty, add a table footer with a label telling the user
            if count <= 0 {
                let noContentLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44))
                noContentLabel.backgroundColor = UIColor.clearColor()
                noContentLabel.text = FKLocalizedString("NO_CONTENT_FOUND", comment: "No Content Found")
                noContentLabel.textColor = UIColor.lightGrayColor()
                noContentLabel.textAlignment = .Center
                noContentLabel.font = UIFont.systemFontOfSize(14)
                noContentLabel.minimumScaleFactor = 0.5
                tableView.tableFooterView = noContentLabel
            } else {
                let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0))
                footerView.backgroundColor = UIColor.clearColor()
                tableView.tableFooterView = footerView
            }
        }
    }
    
    // MARK: - Data Getter / Setter Methods
    
    public func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        if indexPath.row < dataStore.count {
            return dataStore[indexPath.row]
        }
        return nil
    }
    
    // MARK: - Update and Load Methods
    
    func refreshControlTriggered(sender: UIRefreshControl!) {
        lastLoadedPage = nil
        updateData()
    }
    
    public func updateData() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            if let sectionDictionary = self.sectionDictionary {
                let urlString = sectionDictionary["url"] as String
                let page = self.lastLoadedPage
                let urlRouter = Router.Custom(urlString, page)
                let request = ServiceClient.request(urlRouter, completed: { (json, error) -> () in
                    self.requestStore.removeRequestFor(router: urlRouter)
                    if let anError = error {
                        NSLog("Data Updater Failure: %@", anError.localizedDescription)
                    } else {
                        if let object: AnyObject = json {
                            self.loadJSON(object, page: page)
                        }
                    }
                    self.endRefreshing()
                })
                self.requestStore.addRequest(request, router: urlRouter)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // TODO: Call updatedData() function in the current view controller.
            })
        })
    }
    
    private func loadJSON(json: AnyObject, page: Int?) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if self.dataStore.setFrom(object: json, page: page) == true {
                self.dataStore.delegate = self
                self.updateTableFooter(count: self.dataStore.count)
                self.reloadData()
                
                if let sectionDictionary = self.sectionDictionary {
                    let urlString = sectionDictionary["url"] as String
                    UserStore.current.setDataStore(self.dataStore, urlString: urlString)
                }
            }
            
            // TODO: Call loadedData() function in the current view controller.
        })
    }
    
    public func reloadData() {
        if let tableView = self.tableView {
            tableView.reloadData()
        } else if let collectionView = self.collectionView {
            collectionView.reloadData()
        }
    }
    
    public func reloadRowsAtIndexPaths(indexPaths: [AnyObject]) {
        if let tableView = self.tableView {
            tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        } else if let collectionView = self.collectionView {
            collectionView.reloadItemsAtIndexPaths(indexPaths)
        }
    }
    
    public func endRefreshing() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            var refreshControl: UIRefreshControl?
            if let tableViewController = self.viewController as? UITableViewController {
                refreshControl = tableViewController.refreshControl
            } else if let collectionViewController = self.viewController as? UICollectionViewController {
                refreshControl = collectionViewController.refreshControl
            }
            
            if refreshControl?.refreshing == true {
                refreshControl?.endRefreshing()
            }
        })
    }
    
    // MARK: - Data Store Delegate Methods
    
    public func dataStore(dataStore: DataStore, willAccessPage page: Int) {
        if page > lastLoadedPage && page != 1 {
            lastLoadedPage = page
            updateData()
        }
    }
    
}
