//
//  MapSearchViewController.swift
//  FrostKit
//
//  Created by James Barrow on 07/02/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit

public class MapSearchViewController: UITableViewController, UISearchControllerDelegate, UISearchBarDelegate {

    public let identifier = "FrostKitMapSearchCell"
    public weak var mapController: MapController?
    private var searchResults: [Address]?
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom Getter / Setter Methods
    
    public func objectAtIndexPath(indexPath: NSIndexPath) -> Address? {
        if let searchResults = self.searchResults {
            if indexPath.row < searchResults.count {
                return searchResults[indexPath.row]
            }
        }
        return nil
    }

    // MARK: - Table view data source

    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let searchResults = self.searchResults {
            return searchResults.count
        }
        return 0
    }

    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: identifier)
        }
        
        if let address = objectAtIndexPath(indexPath) {
            cell?.textLabel?.text = address.name
            cell?.detailTextLabel?.text  = address.simpleAddress
        }
        return cell!
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let address = objectAtIndexPath(indexPath) {
            dismissViewControllerAnimated(true, completion: nil)
            mapController?.zoomMapToAddress(address)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - UISearchBarDelegate Methods
    
    public func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if let mapController = self.mapController {
            searchResults = mapController.searchAddresses(searchText)
            tableView.reloadData()
        }
    }
    
}
