//
//  MapSearchViewController.swift
//  FrostKit
//
//  Created by James Barrow on 07/02/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit
import MapKit

///
/// The map search view controller is used with the search control in a map view controller. It allows searching of points plotted on the map view as well a locations.
///
public class MapSearchViewController: UITableViewController, UISearchControllerDelegate, UISearchBarDelegate {
    
    /// The reuse identifier for the cell for the table view. This should be overriden when subclassing.
    public let identifier = "FrostKitMapSearchCell"
    /// The map controller related to the map search view controller.
    public weak var mapController: MapController?
    /// The search controller releated to the map search view controller.
    public weak var searchController: UISearchController?
    /// A helper method to get the search controller's search bar.
    public var searchBar: UISearchBar? {
        return searchController?.searchBar
    }
    /// The refresh control for the table view controller when searching locations.
    private var refreshControlHolder = UIRefreshControl()
    /// An array of addresses returned after searching, or `nil` if no results are found.
    private var plottedSearchResults: [Address]?
    /// The local search response from a locations search.
    private var locationSeatchResponse: MKLocalSearchResponse?
    /// A helper to access the results array from a local search response.
    private var locationSearchResults: [MKMapItem]? {
        if let locationSeatchResponse = self.locationSeatchResponse {
            return locationSeatchResponse.mapItems
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
    
    /**
    The object at an index path of the selected array (plotted if segment 0 or location if segment 1).
    
    - parameter indexPath: The index path of the object.
    
    - returns: The object at the index path.
    */
    public func objectAt(_ indexPath: NSIndexPath) -> AnyObject? {
        if let searchBar = self.searchBar {
            var array: [AnyObject]?
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
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        }
        
        if let address = objectAt(indexPath) as? Address {
            cell?.textLabel?.text = address.name
            cell?.detailTextLabel?.text  = address.addressString
        } else if let item = objectAt(indexPath) as? MKMapItem {
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
            cell?.detailTextLabel?.text  = (addressComponents as NSArray).componentsJoined(by: ", ")
        }
        
        return cell!
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: NSIndexPath) {
        if let searchBar = self.searchBar {
            switch searchBar.selectedScopeButtonIndex {
            case 0:
                if let address = objectAt(indexPath) as? Address {
                    mapController?.zoom(toAddress: address)
                }
            case 1:
                if let item = objectAt(indexPath) as? MKMapItem {
                    mapController?.zoom(toAnnotation: item.placemark)
                }
            default:
                break
            }
        }
        dismiss(animated: true, completion: nil)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    // MARK: - UISearchBarDelegate Methods
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        switch searchBar.selectedScopeButtonIndex {
        case 0:
            // Search address points plotted on the map
            if let mapController = self.mapController {
                plottedSearchResults = mapController.searchAddresses(searchString: searchText)
                tableView.reloadData()
            }
        case 1:
            // Search location on the map (not plotted points)
            break
        default:
            break
        }
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        switch searchBar.selectedScopeButtonIndex {
        case 0:
            // Search address points plotted on the map
            break
        case 1:
            // Search location on the map (not plotted points)
            refreshControl?.beginRefreshing()
            let searchRequest = MKLocalSearchRequest()
            searchRequest.naturalLanguageQuery = searchBar.text
            if let mapController = self.mapController, mapView = mapController.mapView {
                searchRequest.region = mapView.region
            }
            let localSearch = MKLocalSearch(request: searchRequest)
            NotificationCenter.default().post(name: NSNotification.Name(rawValue: NetworkRequestDidBeginNotification), object: nil)
            localSearch.start(completionHandler: { (searchResponse, error) in
                if let anError = error {
                    NSLog("Error performing local search: \(anError.localizedDescription)\n\(anError)")
                } else {
                    self.locationSeatchResponse = searchResponse
                }
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
                NotificationCenter.default().post(name: NSNotification.Name(rawValue: NetworkRequestDidCompleteNotification), object: nil)
            })
        default:
            break
        }
    }
    
    public func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if selectedScope == 0 {
            refreshControl?.endRefreshing()
            refreshControl = nil
        } else {
            refreshControl = refreshControlHolder
        }
        tableView.reloadData()
    }
    
}
