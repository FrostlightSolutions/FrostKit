//
//  MapSearchViewController.swift
//  FrostKit
//
//  Created by James Barrow on 07/02/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit
import MapKit

public class MapSearchViewController: UITableViewController, UISearchControllerDelegate, UISearchBarDelegate {

    public let identifier = "FrostKitMapSearchCell"
    public weak var mapController: MapController?
    public weak var searchController: UISearchController?
    public var searchBar: UISearchBar? {
        return searchController?.searchBar
    }
    private var refreshControlHolder = UIRefreshControl()
    private var plottedSearchResults: [Address]?
    private var locationSeatchResponse: MKLocalSearchResponse?
    private var locationSearchResults: [MKMapItem]? {
        if let locationSeatchResponse = self.locationSeatchResponse {
            return locationSeatchResponse.mapItems as? [MKMapItem]
        } else {
            return nil
        }
    }
    
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
    
    public func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        if let searchBar = self.searchBar {
            var array: NSArray?
            switch searchBar.selectedScopeButtonIndex {
            case 0:
                array = self.plottedSearchResults
            case 1:
                array = self.locationSearchResults
            default:
                break
            }
            if let searchResults = array {
                if indexPath.row < searchResults.count {
                    return searchResults[indexPath.row]
                }
            }
        }
        return nil
    }

    // MARK: - Table view data source

    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let searchBar = self.searchBar {
            switch searchBar.selectedScopeButtonIndex {
            case 0:
                if let plottedSearchResults = self.plottedSearchResults {
                    return plottedSearchResults.count
                }
            case 1:
                if let locationSearchResults = self.locationSearchResults {
                    return locationSearchResults.count
                }
            default:
                break
            }
        }
        return 0
    }

    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: identifier)
        }
        
        if let address = objectAtIndexPath(indexPath) as? Address {
            cell?.textLabel?.text = address.name
            cell?.detailTextLabel?.text  = address.addressString
        } else if let item = objectAtIndexPath(indexPath) as? MKMapItem {
            cell?.textLabel?.text = item.name
            
            var addressComponents = Array<String>()
            if let thoroughfare = item.placemark.thoroughfare {
                addressComponents.append(thoroughfare)
            }
            if let locality = item.placemark.locality {
                addressComponents.append(locality)
            }
            if let administrativeArea = item.placemark.administrativeArea {
                addressComponents.append(administrativeArea)
            }
            if let postalCode = item.placemark.postalCode {
                addressComponents.append(postalCode)
            }
            if let country = item.placemark.country {
                addressComponents.append(country)
            }
            cell?.detailTextLabel?.text  = (addressComponents as NSArray).componentsJoinedByString(", ")
        }
        
        return cell!
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let searchBar = self.searchBar {
            switch searchBar.selectedScopeButtonIndex {
            case 0:
                if let address = objectAtIndexPath(indexPath) as? Address {
                    mapController?.zoomToAddress(address)
                }
            case 1:
                if let item = objectAtIndexPath(indexPath) as? MKMapItem {
                    mapController?.zoomToAnnotation(item.placemark)
                }
            default:
                break
            }
        }
        dismissViewControllerAnimated(true, completion: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - UISearchBarDelegate Methods
    
    public func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        switch searchBar.selectedScopeButtonIndex {
        case 0:
            // Search address points plotted on the map
            if let mapController = self.mapController {
                plottedSearchResults = mapController.searchAddresses(searchText)
                tableView.reloadData()
            }
        case 1:
            // Search location on the map (not plotted points)
            break
        default:
            break
        }
    }
    
    public func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        switch searchBar.selectedScopeButtonIndex {
        case 0:
            // Search address points plotted on the map
            break
        case 1:
            // Search location on the map (not plotted points)
            refreshControl?.beginRefreshing()
            let searchRequest = MKLocalSearchRequest()
            searchRequest.naturalLanguageQuery = searchBar.text
            if let mapController = self.mapController {
                searchRequest.region = mapController.mapView.region
            }
            let localSearch = MKLocalSearch(request: searchRequest)
            localSearch.startWithCompletionHandler({ (searchResponse, error) -> Void in
                if error != nil {
                    NSLog("Error performing local search: \(error.localizedDescription)")
                } else {
                    self.locationSeatchResponse = searchResponse
                }
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            })
        default:
            break
        }
    }
    
    public func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if selectedScope == 0 {
            refreshControl?.endRefreshing()
            refreshControl = nil
        } else {
            refreshControl = refreshControlHolder
        }
        tableView.reloadData()
    }
    
}
