//
//  MapSearchViewController.swift
//  FrostKit
//
//  Created by James Barrow on 07/02/2015.
//  Copyright © 2015-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit
import MapKit

///
/// The map search view controller is used with the search control in a map view controller. It allows searching of points plotted on the map view as well a locations.
///
open class MapSearchViewController: UITableViewController, UISearchControllerDelegate, UISearchBarDelegate {
    
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
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = false
    }
    
    // MARK: - Custom Getter / Setter Methods
    
    /**
    The object at an index path of the selected array (plotted if segment 0 or location if segment 1).
    
    - parameter indexPath: The index path of the object.
    
    - returns: The object at the index path.
    */
    open func objectAt(_ indexPath: IndexPath) -> Any? {
        if let searchBar = self.searchBar {
            switch searchBar.selectedScopeButtonIndex {
            case 0:
                if let searchResults = self.plottedSearchResults, indexPath.row < searchResults.count {
                    return searchResults[indexPath.row]
                }
            case 1:
                if let searchResults = self.locationSearchResults, indexPath.row < searchResults.count {
                    return searchResults[indexPath.row]
                }
            default:
                break
            }
        }
        return nil
    }
    
    // MARK: - Table view data source
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        }
        
        if let address = objectAt(indexPath) as? Address {
            cell?.textLabel?.text = address.name
            cell?.detailTextLabel?.text  = address.addressString
        } else if let item = objectAt(indexPath) as? MKMapItem {
            cell?.textLabel?.text = item.name
            
            var addressComponents = [String]()
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
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - UISearchBarDelegate Methods
    
    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
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
    
    open func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        switch searchBar.selectedScopeButtonIndex {
        case 0:
            // Search address points plotted on the map
            break
        case 1:
            // Search location on the map (not plotted points)
            refreshControl?.beginRefreshing()
            let searchRequest = MKLocalSearchRequest()
            searchRequest.naturalLanguageQuery = searchBar.text
            if let mapController = self.mapController, let mapView = mapController.mapView {
                searchRequest.region = mapView.region
            }
            let localSearch = MKLocalSearch(request: searchRequest)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NetworkRequestDidBeginNotification), object: nil)
            localSearch.start(completionHandler: { (searchResponse, error) in
                if let anError = error {
                    NSLog("Error performing local search: \(anError.localizedDescription)\n\(anError)")
                } else {
                    self.locationSeatchResponse = searchResponse
                }
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NetworkRequestDidCompleteNotification), object: nil)
            })
        default:
            break
        }
    }
    
    open func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if selectedScope == 0 {
            refreshControl?.endRefreshing()
            refreshControl = nil
        } else {
            refreshControl = refreshControlHolder
        }
        tableView.reloadData()
    }
    
}
