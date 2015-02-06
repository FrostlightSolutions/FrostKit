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
    
    // MARK: - Plot/Remove Annotations Methods
    
    public func plotAddresses(addresses: [Address]) {
        
        for address in addresses {
            plotAddress(address)
        }
    }
    
    public func plotAddress(address: Address) {
        
        if address.isValid == false {
            return
        }
        
        if let index = find(addresses, address) {
            addresses[index] = address
        } else {
            addresses.append(address)
        }
        
        var annotation: Annotation?
        if let currentAnnotation = annotations[address] {
            // Annotation already exists, update the address
            currentAnnotation.updateAddress(address)
            annotation = currentAnnotation
        } else {
            // No previous annotation for this addres, create one
            let newAnnotation = Annotation(address: address)
            annotations[address] = newAnnotation
            annotation = newAnnotation
        }
        
        if let currentAnnotation = annotation {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.mapView.addAnnotation(annotation)
            })
        }
        
        zoomToSpecificLocation = false
    }
    
    public func removeAllAnnotations(includingCached: Bool = false) {
        let annotations = Array(self.annotations.values)
        mapView.removeAnnotations(annotations)
        
        if includingCached == true {
            self.annotations.removeAll(keepCapacity: false)
        }
    }
    
    public func clearData() {
        removeAllAnnotations(includingCached: true)
        addresses.removeAll(keepCapacity: false)
        zoomToSpecificLocation = false
    }
    
    // MARK: - Zoom Map Methods
    
    public func zoomToCoordinate(coordinare: CLLocationCoordinate2D) {
        let point = MKMapPointForCoordinate(coordinare)
        zoomToMapPoints([point])
    }
    
    public func zoomToAnnotations(annotations: [MKAnnotation]) {
        let count = annotations.count
        if count > 0 {
            var points = Array<MKMapPoint>()
            for index in 0..<count {
                let annotation = annotations[index]
                points[index] = MKMapPointForCoordinate(annotation.coordinate)
            }
            zoomToMapPoints(points)
        }
    }
    
    public func zoomToMapPoints(points: [MKMapPoint]) {
        let count = points.count
        let cPoints: UnsafeMutablePointer<MKMapPoint> = UnsafeMutablePointer<MKMapPoint>.alloc(count)
        cPoints.initializeFrom(points)
        zoomToMapPoints(cPoints, count: count)
        cPoints.destroy()
    }
    
    public func zoomToMapPoints(points: UnsafeMutablePointer<MKMapPoint>, count: Int) {
        let mapRect = MKPolygon(points: points, count: count).boundingMapRect
        var region: MKCoordinateRegion = MKCoordinateRegionForMapRect(mapRect)
        
        if count <= 1 {
            region.span = MKCoordinateSpanMake(minimumZoomArc, minimumZoomArc)
        } else {
            region.span = MKCoordinateSpanMake(region.span.latitudeDelta * annotationRegionPadFactor, region.span.longitudeDelta * annotationRegionPadFactor)
            
            if region.span.latitudeDelta > maximumDegreesArc {
                region.span.latitudeDelta = maximumDegreesArc
            } else if region.span.latitudeDelta < minimumZoomArc {
                region.span.latitudeDelta = minimumZoomArc
            }
            
            if region.span.longitudeDelta > maximumDegreesArc {
                region.span.longitudeDelta = maximumDegreesArc
            } else if region.span.longitudeDelta < minimumZoomArc {
                region.span.longitudeDelta = minimumZoomArc
            }
        }
        
        mapView.setRegion(region, animated: true)
    }
    
    public func zoomToCurrentLocation() {
        zoomToCoordinate(mapView.userLocation.coordinate)
    }
    
    public func zoomToShowAll(includingUser: Bool = true) {
        if includingUser == true {
            zoomToAnnotations(mapView.annotations as [MKAnnotation])
        } else {
            let annotations = Array(self.annotations.values)
            zoomToAnnotations(annotations)
        }
    }
    
    public func zoomMapToAddress(address: Address) {
        plotAddress(address)
        
        let annotation = annotations[address] as MKAnnotation
        zoomToAnnotations([annotation])
    }
    
    public func zoomToPolyline(polyline: MKPolyline) {
        zoomToMapPoints(polyline.points(), count: polyline.pointCount)
    }
    
    // MARK: - Polyline and Route Methods
    
    public func removeAllPolylines() {
        for overlay in mapView.overlays {
            if let polyline = overlay as? MKPolyline {
                mapView.removeOverlay(polyline)
            }
        }
    }
    
    public func directionsToCurrentLocationFrom(#coordinate: CLLocationCoordinate2D, inApp: Bool = true) {
        let currentLocationItem = MKMapItem.mapItemForCurrentLocation()
        
        let destinationPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        if inApp == true {
            let directionsRequest = MKDirectionsRequest()
            directionsRequest.setSource(currentLocationItem)
            directionsRequest.setDestination(destinationItem)
            directionsRequest.transportType = .Automobile
            directionsRequest.requestsAlternateRoutes = false
            
            let directions = MKDirections(request: directionsRequest)
            directions.calculateDirectionsWithCompletionHandler({ (directionsResponse, error) -> Void in
                if let anError = error {
                    NSLog("Error getting directions: \(error.localizedDescription)")
                } else {
                    if let route = directionsResponse.routes.first as? MKRoute {
                        self.plotRoute(route)
                    }
                }
            })
        } else {
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            MKMapItem.openMapsWithItems([currentLocationItem, destinationItem], launchOptions: launchOptions)
        }
    }
    
    public func plotRoute(route: MKRoute) {
        removeAllPolylines()
        mapView.addOverlay(route.polyline, level: .AboveRoads)
    }
    
}

// MARK: - Address Object

public class Address: NSObject {
    
    public var objectID: String?
    public var coordinate = CLLocationCoordinate2DMake(0.0, 0.0)
    public var latitude: CLLocationDegrees {
        return coordinate.latitude
    }
    public var longitude: CLLocationDegrees {
        return coordinate.longitude
    }
    public var isValid: Bool {
        if latitude == 0 && longitude == 0 {
            return false
        } else {
            return true
        }
    }
    public var name = ""
    public var simpleAddress = ""
    override public var description: String {
        return "\(self) Latitude: \(latitude) Longitude: \(longitude) Address: \(simpleAddress)"
    }
    override public var hash: Int {
        return Int(latitude) ^ Int(longitude)
    }
    
    convenience public init(dictionary: NSDictionary) {
        self.init()
        
        objectID = dictionary["id"] as? String
        
        if let latitude = dictionary["latitude"] as? Double {
            coordinate.latitude = latitude
        } else if let latitude = dictionary["latitude"] as? Float {
            coordinate.latitude = Double(latitude)
        } else if let latitude = dictionary["latitude"] as? Int {
            coordinate.latitude = Double(latitude)
        }
        
        if let longitude = dictionary["longitude"] as? Double {
            coordinate.longitude = longitude
        } else if let longitude = dictionary["longitude"] as? Float {
            coordinate.latitude = Double(longitude)
        } else if let longitude = dictionary["longitude"] as? Int {
            coordinate.latitude = Double(longitude)
        }
    }
    
    public class func addressesFromArrayOfDictionaries(array: [NSDictionary]) -> [Address] {
        var adresses = Array<Address>()
        for dictionary in array {
            adresses.append(Address(dictionary: dictionary))
        }
        return adresses
    }
    
    // MARK: - Comparison Methods
    
    public func isEqualToAddress(object: Address?) -> Bool {
        if let address = object {
            
            let haveEqualLatitude = self.latitude == address.latitude
            let haveEqualLongitude = self.longitude == address.longitude
            let haveEqualName = self.name == address.name
            let haveEqualSimpleAddress = self.simpleAddress == address.simpleAddress
            
            return haveEqualLatitude && haveEqualLongitude && haveEqualName && haveEqualSimpleAddress
        }
        return false
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        if let address = object as? Address {
            return self.isEqualToAddress(address)
        }
        return false
    }
}

// MARK: - Annotation Object

public class Annotation: NSObject, MKAnnotation {
    
    public var address: Address
    public var coordinate: CLLocationCoordinate2D {
        return address.coordinate
    }
    public var title: String {
        return address.name
    }
    public var subtitle: String {
        return address.simpleAddress
    }
    
    public init(address: Address) {
        self.address = address
        
        super.init()
    }
    
    public func updateAddress(address: Address) {
        if self.address.isEqualToAddress(address) == false {
            self.address = address
        }
    }
    
}
