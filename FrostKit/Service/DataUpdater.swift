//
//  DataUpdater.swift
//  FrostKit
//
//  Created by James Barrow on 26/01/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit

/// 
/// The data updater is a class that helpers update data from a FUS based system. It is made to be inserted into IB via an NSObject.
///
/// It handles controlling loading, updating, saving of data along wit using the request store and data stores to mange these functions. It is also written to work with a data soruce for either UITableView or UICollectionView.
///
public class DataUpdater: NSObject, DataStoreDelegate {
    
    /// The request store for this data updater to manage it's request calls.
    public let requestStore = RequestStore()
    /// The view controller this data updater is related to. This can be set in IB and will automatically attempt to add a UIRefreshControl to a UITableViewController or UICollectionViewController.
    @IBOutlet var viewController: UIViewController! {
        didSet { setRefreshControlForViewController(viewController) }
    }
    /// The table view to display data on.
    @IBOutlet var tableView: UITableView? {
        didSet { setupTableView() }
    }
    /// The collection view to display data on.
    @IBOutlet var collectionView: UICollectionView? {
        didSet { setupCollectionView() }
    }
    /// The section dictionary from FUS describing the URL and name of the section to make requests for.
    private var sectionDictionary: NSDictionary?
    /// The parameters to use when updating the data.
    public var updateParameters = Dictionary<String, AnyObject>()
    /// The data store of data loaded, to update and to save.
    public var dataStore: DataStore?
    /// The highest loaded page. As the user scrolls down, this will incriment automatically. It will only be set back tot zero when the user pulls down to refresh on the table view or collection view.
    private var lastRequestedPage: Int = 1
    /// An array of loaded pages.
    private var loadingPages = NSMutableSet()
    
    public override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "clearData", name: UserStoreLogoutClearData, object: nil)
    }
    
    /**
    A convenience init for programatically creating a data update with a table view.
    
    :param: viewController The view controller to link to the data updater.
    :param: tableView      The table view to link to the data updater.
    */
    convenience public init(viewController: UIViewController, tableView: UITableView) {
        self.init()
        
        self.viewController = viewController
        self.tableView = tableView
        
        setRefreshControlForViewController(viewController)
    }
    
    /**
    A convenience init for programatically creating a data update with a collection view.
    
    :param: viewController The view controller to link to the data updater.
    :param: tableView      The collection view to link to the data updater.
    */
    convenience public init(viewController: UIViewController, collectionView: UICollectionView) {
        self.init()
        
        self.viewController = viewController
        self.collectionView = collectionView
        
        setRefreshControlForViewController(viewController)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if let viewController = self.viewController {
            NSNotificationCenter.defaultCenter().removeObserver(viewController)
        }
    }
    
    /**
    Notifies the data updater that its view was added to a view hierarchy.
    
    :param: animated If true, the view was added to the window using an animation.
    */
    public func viewWillAppear(animated: Bool) {
        endRefreshing()
        updateData()
    }
    
    public func viewDidAppear(animated: Bool) {
        
    }
    
    // MARK: - Notifications
    
    func clearData() {
        if let dataStore = self.dataStore {
            dataStore.removeAllObjects()
            reloadData()
        }
    }
    
    // MARK: - Setup and Update Methods
    
    /**
    Sets up the table view with some default values and settings.
    */
    private func setupTableView() {
        if let tableView = self.tableView {
            tableView.estimatedRowHeight = 44
            if UIDevice.SystemVersion.majorVersion >= 8 {
                tableView.rowHeight = UITableViewAutomaticDimension
            }
            updateTableFooter()
        }
    }
    
    /**
    Sets up the collection view with some default values and settings.
    */
    private func setupCollectionView() {
        if let collectionView = self.collectionView {
            // TODO: Setup and update a "No Content" footer.
        }
    }
    
    /**
    Updates the table footer. If there is no data to display then a label is added displaying to the user that there is no content found. Otherwise it just adds an empty, clear, 0 height view to stop any extra cells being automatically generated by iOS.
    
    :param: count The count of data objects. By default 0 is passed in.
    */
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
    
    // MARK: - Getter / Setter Methods
    
    /**
    This is used to set the view controller if the data updater was created in code with the standard `init()` function.
    
    :param: viewController The view controller to set.
    */
    public func setUpdaterViewController(viewController: UIViewController) {
        self.viewController = viewController
        if viewController.respondsToSelector("updateSection") == true {
            NSNotificationCenter.defaultCenter().addObserver(viewController, selector: "updateSection", name: FUSServiceClientUpdateSections, object: nil)
        }
        setRefreshControlForViewController(self.viewController)
    }
    
    /**
    This is used to set the table view if the data updater was created in code with the standard `init()` function.
    
    :param: tableView The table view to set.
    */
    public func setUpdaterTableView(tableView: UITableView) {
        self.tableView = tableView
        setupTableView()
    }
    
    /**
    This is used to set the collection view if the data updater was created in code with the standard `init()` function.
    
    :param: tableView The collection view to set.
    */
    public func setUpdaterCollectionView(collectionView: UICollectionView) {
        self.collectionView = collectionView
        setupCollectionView()
    }
    
    /**
    Set the section dictionary so that the data updater knows the URL of the data to update. Calling this function automatically calls an update of data once the section dictionary is set.
    
    :param: sectionDictionary The section dictionary returned from FUS.
    */
    public func setSectionDictionary(sectionDictionary: NSDictionary, updateData: Bool = true) {
        if self.sectionDictionary == nil || self.sectionDictionary?.isEqualToDictionary(sectionDictionary as [NSObject : AnyObject]) == false {
            self.sectionDictionary = sectionDictionary
            
            if let sectionDictionary = self.sectionDictionary {
                let urlString = sectionDictionary["url"] as! String
                let saveString = Router.Custom(urlString, nil, self.updateParameters).saveString
                if let localDataStore = UserStore.current.dataStoreForURL(saveString) {
                    dataStore = localDataStore
                    dataStore?.delegate = self
                    reloadData()
                }
            }
            
            if updateData == true {
                self.updateData()
            }
        }
    }
    
    /**
    Creates and set a `UIRefreshControl` for the passed in view controller, assuming it is either an `UITableViewController` or a `UICollectionViewController`.
    
    :param: viewController The view controller to add the refresh control to.
    */
    private func setRefreshControlForViewController(viewController: UIViewController) {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlTriggered:", forControlEvents: .ValueChanged)
        refreshControl.tintColor = FrostKit.tintColor
        
        if let tableViewController = viewController as? UITableViewController {
            tableViewController.refreshControl = refreshControl
        } else if let collectionViewController = viewController as? UICollectionViewController {
            collectionViewController.refreshControl = refreshControl
        }
    }

    /**
    Gets the object in the data store for a specific index path. By default this assumes 1 section only, and so the section component of indexPath is removed.
    
    :param: indexPath The index object to return.
    
    :returns: The object found at indexPath or `nil` if it is out of bounds or not found.
    */
    public func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        if indexPath.row < dataStore?.count {
            return dataStore?[indexPath.row]
        }
        return nil
    }
    
    // MARK: - Update and Load Methods
    
    /**
    Called by the refresh controll and triggers the data to be updated and the lastLoadedPage to be reset.
    
    :param: sender The refresh control that triggered this function.
    */
    func refreshControlTriggered(sender: UIRefreshControl!) {
        lastRequestedPage = 1
        loadingPages.removeAllObjects()
        updateData()
    }
    
    /**
    Updates the data using the section dictionary as a reference for the URL or path to call with the servervice client.
    
    This function will automatically deal with the refresh control and request store.
    
    Once complete it will call the loadJSON function or log an error to the console.
    */
    public func updateData() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            if let sectionDictionary = self.sectionDictionary {
                let urlString = sectionDictionary["url"] as! String
                let page = self.lastRequestedPage
                let urlRouter = Router.Custom(urlString, page, self.updateParameters)
                let request = FUSServiceClient.request(urlRouter, completed: { (json, error) -> () in
                    self.requestStore.removeRequestFor(router: urlRouter)
                    self.loadingPages.removeObject(page)
                    if let anError = error {
                        NSLog("Data Updater Failure for page \(page): \(anError.localizedDescription)")
                    } else if let object: AnyObject = json {
                        self.loadJSON(object, router: urlRouter)
                    }
                    self.endRefreshing()
                })
                self.requestStore.addRequest(request, router: urlRouter)
                self.loadingPages.addObject(page)
            } else {
                self.endRefreshing()
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // TODO: Call updatedData() function in the current view controller.
            })
        })
    }
    
    /**
    Loads the JSON passed in for a specific page. This function is called by the updateData function automatically when the data is successfully returned from the FUS based system.
    
    The function takes care of automatically updating the data store and updating the table footer if needed.
    
    :param: json The JSON to update/load into the data store.
    :param: page The page the JSON is related to, or `nil` if the JSON is a non-paged response.
    */
    private func loadJSON(json: AnyObject, router: Router) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            var shouldUpdate = false
            if let dataStore = self.dataStore {
                shouldUpdate = dataStore.setFrom(object: json, page: router.page)
            } else if router.page == nil || router.page! == 1 {
                self.dataStore = DataStore(object: json)
                self.dataStore?.delegate = self
                shouldUpdate = true
            } else {
                NSLog("Can't create a data store for a non-page 1 object!")
            }
        
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if shouldUpdate == true {
                    if let dataStore = self.dataStore {
                        self.updateTableFooter(count: dataStore.count)
                        
                        if let sectionDictionary = self.sectionDictionary {
                            let saveString = router.saveString
                            UserStore.current.setDataStore(dataStore, urlString: saveString)
                        }
                    }
                    self.reloadData()
                }
                
                // TODO: Call loadedData() function in the current view controller.
            })
        })
    }
    
    /**
    Calls the reloadData function is the releated table view or collection view.
    */
    public func reloadData() {
        if let tableView = self.tableView {
            tableView.reloadData()
        } else if let collectionView = self.collectionView {
            collectionView.reloadData()
        }
    }
    
    /**
    Calls the reloadRowsAtIndexPaths function is the releated table view or collection view.
    
    :param: indexPaths An array of the index paths to reload.
    */
    public func reloadRowsAtIndexPaths(indexPaths: [AnyObject]) {
        if let tableView = self.tableView {
            tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        } else if let collectionView = self.collectionView {
            collectionView.reloadItemsAtIndexPaths(indexPaths)
        }
    }
    
    /**
    Calls the endRefreshing function for the refresh control in the releated table view or collection view.
    */
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
        if loadingPages.containsObject(page) == false {
            lastRequestedPage = page
            updateData()
        }
    }
    
}
