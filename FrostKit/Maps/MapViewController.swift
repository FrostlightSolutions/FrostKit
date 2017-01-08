//
//  MapViewController.swift
//  FrostKit
//
//  Created by James Barrow on 06/02/2015.
//  Copyright © 2015 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

///
/// The map view controller is made to contain a map view and map controller and allow them to be presnted as a view controller.
///
/// This class is designed to be subclassed if more specific actions, such a updating the addresses or objects to plot.
///
open class MapViewController: UIViewController {
    
    /// The map controller related to the map view controller.
    @IBOutlet public weak var mapController: MapController!
    /// Dictates if the location button should be shown.
    @IBInspectable public var locationButton: Bool = true
    /// Dictates if the search button should be shown. Note: Search is only available on iOS 8+.
    @IBInspectable public var searchButton: Bool = true
    /// The search controller for using in iOS 8+ projects.
    public var searchController: UISearchController!
    /// Overridden by a subclass to define the icon to use in thenavgation bar button item when the `locationButton` is active. Both this and the `inactiveLocationIcon` need to be overriden for the default icon to be overridden.
    open var activeLocationIcon: UIImage? {
        return nil
    }
    /// Overridden by a subclass to define the icon to use in thenavgation bar button item when the `locationButton` is inactive. Both this and the `activeLocationIcon` need to be overriden for the default icon to be overridden.
    open var inactiveLocationIcon: UIImage? {
        return nil
    }
    private var zoomedToShowAll = false
    /// Ditermines if the map view should zoom to show all on the first view did appear.
    @IBInspectable public var shouldZoomToShowAllOnViewDidAppear: Bool = true
    /// Overridden by a subclass to define actual scope titles for the search bar. If an empty array is returned then the scope selector is not shown. By default this is set to `Markers` and `Locations`.
    open var searchScopeButtonTitles: [String] {
        return [FKLocalizedString("MARKERS", comment: "Markers"), FKLocalizedString("LOCATIONS", comment: "Locations")]
    }
    // Defines if the search scope should show.
    @IBInspectable public var showsSearchScopeBar: Bool = true
    // Defines the search search view controller for the search controller to use. If `nil` is found on setup then a default `MapSearchViewController` is used.
    public var searchTableViewController: MapSearchViewController?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = FKLocalizedString("MAP", comment: "Map")
        updateNavigationButtons(animated: false)
        
        let searchTableViewController: MapSearchViewController
        if let userDefinedSearchTableViewController = self.searchTableViewController {
            searchTableViewController = userDefinedSearchTableViewController
        } else {
            searchTableViewController = MapSearchViewController(style: .plain)
        }
        
        searchTableViewController.mapController = mapController
        searchController = UISearchController(searchResultsController: searchTableViewController)
        searchController.searchBar.sizeToFit()
        searchController.searchBar.scopeButtonTitles = searchScopeButtonTitles
        searchController.searchBar.showsScopeBar = showsSearchScopeBar && searchScopeButtonTitles.count > 0
        searchController.searchBar.delegate = searchTableViewController
        searchController.delegate = searchTableViewController
        searchTableViewController.searchController = searchController
        
        updateAddresses()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldZoomToShowAllOnViewDidAppear == true && zoomedToShowAll == false {
            zoomedToShowAll = true
            mapController.zoomToShowAll()
        }
    }
    
    // MARK: - Update Methods
    
    /**
    Updates the navigation bar buttons.
    
    - parameter animated: If the buttons should animate when they update.
    */
    public func updateNavigationButtons(animated: Bool = true) {
        
        var barButtonItems = [UIBarButtonItem]()
        if locationButton == true {
            
            let locationButton: UIBarButtonItem
            if let activeLocationIcon = self.activeLocationIcon, let inactiveLocationIcon = self.inactiveLocationIcon {
                
                let icon: UIImage
                if mapController.trackingUser == true {
                    icon = activeLocationIcon
                } else {
                    icon = inactiveLocationIcon
                }
                
                locationButton = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(MapViewController.locationButtonPressed(_:)))
                
            } else {
                
                let title: String
                if mapController.trackingUser == true {
                    title = IonIcons.iosNavigate
                } else {
                    title = IonIcons.iosNavigateOutline
                }
                
                locationButton = UIBarButtonItem(title: title, font: .ionicons(ofSize: 24), verticalOffset: -1, target: self, action: #selector(MapViewController.locationButtonPressed(_:)))
            }
            
            barButtonItems.append(locationButton)
        }
        
        // TODO: Reactivate for iOS 7 when UISearchDisplayController is implimented.
        if UIDevice.SystemVersion.majorVersion >= 8 {
            if searchButton == true {
                let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(MapViewController.searchButtonPressed(_:)))
                barButtonItems.append(searchButton)
            }
        }
        navigationItem.setRightBarButtonItems(barButtonItems, animated: animated)
    }
    
    /**
    Update objects to be plotted on the map. This method is to be overriden by a subclass to specify the specific methods to call new objects from the server.
    */
    open func updateAddresses() {
        // Used to be overriden by a subclass depending on the data service model
    }
    
    // MARK: - Action Methods
    
    /**
    Show the options for the map view controller when the location button is pressed.
    
    - parameter sender: The location button pressed.
    */
    @IBAction open func locationButtonPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let currentLocationAlertAction = UIAlertAction(title: FKLocalizedString("CURRENT_LOCATION", comment: "Current Location"), style: .default, handler: { (_) -> Void in
            self.mapController.zoomToCurrentLocation()
            self.updateNavigationButtons()
        })
        alertController.addAction(currentLocationAlertAction)
        let allLocationsAlertAction = UIAlertAction(title: FKLocalizedString("ALL_LOCATIONS", comment: "All Locations"), style: .default, handler: { (_) -> Void in
            self.mapController.zoomToShowAll()
        })
        alertController.addAction(allLocationsAlertAction)
        let clearDirectionsAlertAction = UIAlertAction(title: FKLocalizedString("CLEAR_DIRECTIONS", comment: "Clear Directions"), style: .default, handler: { (_) -> Void in
            self.mapController.removeAllPolylines()
        })
        alertController.addAction(clearDirectionsAlertAction)
        let cancelAlertAction = UIAlertAction(title: FKLocalizedString("CANCEL", comment: "Cancel"), style: .cancel, handler: { (_) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(cancelAlertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    /**
    Shows the map search view controller.
    
    - parameter sender: The search button pressed.
    */
    @IBAction open func searchButtonPressed(_ sender: UIBarButtonItem) {
        if let searchController = self.searchController {
            present(searchController, animated: true, completion: nil)
        }
    }
    
}
