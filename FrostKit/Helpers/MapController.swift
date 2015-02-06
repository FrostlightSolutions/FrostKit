//
//  MapController.swift
//  FrostKit
//
//  Created by James Barrow on 29/11/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

public class MapController: NSObject {
    
    private let minimumZoomArc = 0.007  //approximately 1/2 mile (1 degree of arc ~= 69 miles)
    private let maximumDegreesArc: Double = 360
    private let annotationRegionPadFactor: Double = 1.15
    
    private var hasPlottedInitUsersLocation = false
    private var zoomToSpecificLocation = false
    
    public var mapVC: UIViewController?
    @IBOutlet public weak var mapView: MKMapView! {
        didSet {
            
            mapView.userTrackingMode = .Follow
            mapView.showsUserLocation = true
            
            if locationManager == nil {
                locationManager = CLLocationManager()
            }
            
            if let locationManager = self.locationManager {
                
                if locationManager.respondsToSelector("requestWhenInUseAuthorization") {
                    locationManager.requestWhenInUseAuthorization()
                }
                
                locationManager.startUpdatingLocation()
            }
        }
    }
    var locationManager: CLLocationManager?
    var addresses = Array<Address>()
    var annotations = Dictionary<Address, Annotation>()
    
    deinit {
        
        resetMap()
        purgeMap()
    }
    
    public func resetMap() {
        
        addresses.removeAll(keepCapacity: false)
        annotations.removeAll(keepCapacity: false)
        
        removeAllAnnotations()
        removeAllPolylines()
    }
    
    private func purgeMap() {
        
        if let locationManager = self.locationManager {
            
            locationManager.stopUpdatingLocation()
            self.locationManager = nil
        }
        
        mapView.userTrackingMode = .None
        mapView.showsUserLocation = true
        mapView.mapType = .Standard
        mapView.delegate = nil
//        mapView.removeFromSuperview()
//        mapView = nil
    }
    
}
