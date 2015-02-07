//
//  MapViewController.swift
//  FrostKit
//
//  Created by James Barrow on 06/02/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit

public class MapViewController: UIViewController, UIActionSheetDelegate {
    
    @IBOutlet public weak var mapController: MapController!
    @IBInspectable public var locationButton: Bool = true
    @IBInspectable public var searchButton: Bool = true
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = FKLocalizedString("MAP", comment: "Map")
        updateNavigationButtons(animated: false)
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateAddresses()
        mapController.zoomToShowAll()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Update Methods
    
    internal func updateNavigationButtons(animated: Bool = true) {
        var barButtonItems = Array<UIBarButtonItem>()
        if locationButton == true {
            var title = ionicon_ios_navigate_outline
            if mapController.trackingUser == true {
                title = ionicon_ios_navigate
            }
            
            let locationButton = UIBarButtonItem(title: title, font: UIFont.ionicons(size: 24), verticalOffset: -1, target: self, action: "locationButtonPressed:")
            barButtonItems.append(locationButton)
        }
        if searchButton == true {
            let searchButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "searchButtonPressed:")
            barButtonItems.append(searchButton)
        }
        navigationItem.setRightBarButtonItems(barButtonItems, animated: animated)
    }
    
    public func updateAddresses() {
        // Used to be overriden by a subclass depending on the data service model
    }
    
    // MARK: - Action Methods
    
    @IBAction public func locationButtonPressed(sender: UIBarButtonItem) {
        if NSClassFromString("UIAlertController") == nil {
            // iOS 7
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: FKLocalizedString("CANCEL", comment: "Cancel"), destructiveButtonTitle: nil, otherButtonTitles: FKLocalizedString("CURRENT_LOCATION", comment: "Current Location"), FKLocalizedString("ALL_LOCATIONS", comment: "All Locations"), FKLocalizedString("CLEAR_DIRECTIONS", comment: "Clear Directions"))
            actionSheet.showFromBarButtonItem(sender, animated: true)
        } else {
            // iOS 8+
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let currentLocationAlertAction = UIAlertAction(title: FKLocalizedString("CURRENT_LOCATION", comment: "Current Location"), style: .Default, handler: { (action) -> Void in
                self.mapController.zoomToCurrentLocation()
                self.updateNavigationButtons()
            })
            alertController.addAction(currentLocationAlertAction)
            let allLocationsAlertAction = UIAlertAction(title: FKLocalizedString("ALL_LOCATIONS", comment: "All Locations"), style: .Default, handler: { (action) -> Void in
                self.mapController.zoomToShowAll()
            })
            alertController.addAction(allLocationsAlertAction)
            let clearDirectionsAlertAction = UIAlertAction(title: FKLocalizedString("CLEAR_DIRECTIONS", comment: "Clear Directions"), style: .Default, handler: { (action) -> Void in
                self.mapController.removeAllPolylines()
            })
            alertController.addAction(clearDirectionsAlertAction)
            let cancelAlertAction = UIAlertAction(title: FKLocalizedString("CANCEL", comment: "Cancel"), style: .Cancel, handler: { (action) -> Void in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(cancelAlertAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction public func searchButtonPressed(sender: UIBarButtonItem) {
        // TODO: Impliment search
    }
    
    // MARK: - UIActionSheetDelegate Methods
    
    public func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            mapController.zoomToCurrentLocation()
            updateNavigationButtons()
        case 1:
            mapController.zoomToShowAll()
        case 2:
            mapController.removeAllPolylines()
        default:
            break
        }
    }
    
}
