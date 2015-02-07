//
//  MapController.swift
//  FrostKit
//
//  Created by James Barrow on 29/11/2014.
//  Copyright (c) 2014-2015 Frostlight Solutions. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

public class MapController: NSObject, MKMapViewDelegate, UIActionSheetDelegate {
    
    private let minimumZoomArc = 0.007  //approximately 1/2 mile (1 degree of arc ~= 69 miles)
    private let maximumDegreesArc: Double = 360
    private let annotationRegionPadFactor: Double = 1.15
    public let identifier = "FrostKitAnnotation"
    private var hasPlottedInitUsersLocation = false
    @IBOutlet public weak var viewController: UIViewController!
    @IBOutlet public weak var mapView: MKMapView! {
        didSet {
            mapView.userTrackingMode = .Follow
            mapView.showsUserLocation = true
            if autoAssingDelegate == true {
                mapView.delegate = self
            }
            
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
    @IBInspectable var autoAssingDelegate: Bool = true
    public var trackingUser: Bool = false {
        didSet {
            if trackingUser == true {
                mapView.userTrackingMode = .Follow
            } else {
                mapView.userTrackingMode = .None
            }
            
            if let mapViewController = viewController as? MapViewController {
                mapViewController.updateNavigationButtons()
            }
        }
    }
    public var locationManager: CLLocationManager?
    public var addresses = Array<Address>()
    public var annotations = Dictionary<Address, Annotation>()
    
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
    }
    
    // MARK: - Zoom Map Methods
    
    public func zoomToCoordinate(coordinare: CLLocationCoordinate2D) {
        let point = MKMapPointForCoordinate(coordinare)
        zoomToMapPoints([point])
    }
    
    public func zoomToAnnotation(annotation: MKAnnotation) {
        zoomToAnnotations([annotation])
    }
    
    public func zoomToAnnotations(annotations: [MKAnnotation]) {
        let count = annotations.count
        if count > 0 {
            var points = Array<MKMapPoint>()
            for annotation in annotations {
                points.append(MKMapPointForCoordinate(annotation.coordinate))
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
        }
        
        zoomToRegion(region)
    }
    
    public func zoomToRegion(var region: MKCoordinateRegion) {
        region.span = normalizeRegionSpan(region.span)
        mapView.setRegion(region, animated: true)
    }
    
    public func zoomToCurrentLocation() {
        trackingUser = true
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
    
    public func zoomToAddress(address: Address) {
        plotAddress(address)
        
        let annotation = annotations[address] as MKAnnotation
        zoomToAnnotations([annotation])
    }
    
    public func zoomToPolyline(polyline: MKPolyline) {
        zoomToMapPoints(polyline.points(), count: polyline.pointCount)
    }
    
    // MARK: - Polyline and Route Methods
    
    public func removeAllPolylines() {
        if let overlays = mapView.overlays {
            for overlay in overlays {
                if let polyline = overlay as? MKPolyline {
                    mapView.removeOverlay(polyline)
                }
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
        zoomToPolyline(route.polyline)
    }
    
    // MARK: - Helper Methods
    
    public func normalizeRegionSpan(var span: MKCoordinateSpan) -> MKCoordinateSpan {
        span = MKCoordinateSpanMake(span.latitudeDelta * annotationRegionPadFactor, span.longitudeDelta * annotationRegionPadFactor)
        if span.latitudeDelta > maximumDegreesArc {
            span.latitudeDelta = maximumDegreesArc
        } else if span.latitudeDelta < minimumZoomArc {
            span.latitudeDelta = minimumZoomArc
        }
        
        if span.longitudeDelta > maximumDegreesArc {
            span.longitudeDelta = maximumDegreesArc
        } else if span.longitudeDelta < minimumZoomArc {
            span.longitudeDelta = minimumZoomArc
        }
        return span
    }
    
    // MARK: - MKMapViewDelegate Methods
    
    public func mapView(mapView: MKMapView!, viewForAnnotation anno: MKAnnotation!) -> MKAnnotationView! {
        var annotationPinView: MKPinAnnotationView?
        if let annotation = anno as? Annotation {
            if let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                annotationView.annotation = annotation
                annotationPinView = annotationView
            } else {
                let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                pinView.pinColor = .Red
                pinView.animatesDrop = true
                pinView.hidden = false
                pinView.enabled = true
                pinView.canShowCallout = true
                pinView.draggable = false
                pinView.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as UIView
                annotationPinView = pinView
            }
        }
        
        return annotationPinView
    }
    
    public func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if let annotation = view.annotation as? Annotation {
            if NSClassFromString("UIAlertController") == nil {
                // iOS 7
                let title = ([annotation.title, annotation.subtitle] as NSArray).componentsJoinedByString("\n")
                let actionSheet = UIActionSheet(title: title, delegate: self, cancelButtonTitle: FKLocalizedString("CANCEL", comment: "Cancel"), destructiveButtonTitle: nil, otherButtonTitles: FKLocalizedString("ZOOM_TO_", comment: "Zoom to..."), FKLocalizedString("DIRECTIONS", comment: "Directions"), FKLocalizedString("OPEN_IN_MAPS", comment: "Open in Maps"))
                actionSheet.showFromRect(control.frame, inView: view, animated: true)
            } else {
                // iOS 8+
                let alertController = UIAlertController(title: annotation.title, message: annotation.subtitle, preferredStyle: .ActionSheet)
                let zoomToAlertAction = UIAlertAction(title: FKLocalizedString("ZOOM_TO_", comment: "Zoom to..."), style: .Default, handler: { (action) -> Void in
                    self.zoomToAnnotation(annotation)
                })
                alertController.addAction(zoomToAlertAction)
                let directionsAlertAction = UIAlertAction(title: FKLocalizedString("DIRECTIONS", comment: "Directions"), style: .Default, handler: { (action) -> Void in
                    self.directionsToCurrentLocationFrom(coordinate: annotation.coordinate)
                })
                alertController.addAction(directionsAlertAction)
                let openInMapsAlertAction = UIAlertAction(title: FKLocalizedString("OPEN_IN_MAPS", comment: "Open in Maps"), style: .Default, handler: { (action) -> Void in
                    self.directionsToCurrentLocationFrom(coordinate: annotation.coordinate, inApp: false)
                })
                alertController.addAction(openInMapsAlertAction)
                let cancelAlertAction = UIAlertAction(title: FKLocalizedString("CANCEL", comment: "Cancel"), style: .Cancel, handler: { (action) -> Void in
                    alertController.dismissViewControllerAnimated(true, completion: nil)
                })
                alertController.addAction(cancelAlertAction)
                viewController.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    public func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if let polyline = overlay as? MKPolyline {
            let polylineRenderer = MKPolylineRenderer(polyline: polyline)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 4
            polylineRenderer.lineCap = kCGLineCapRound
            polylineRenderer.lineJoin = kCGLineJoinRound
            polylineRenderer.alpha = 0.6
            return polylineRenderer
        }
        return nil
    }
    
    public func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        if hasPlottedInitUsersLocation == false {
            hasPlottedInitUsersLocation = true
            zoomToShowAll()
        }
    }
    
    public func mapView(mapView: MKMapView!, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
        switch mode {
        case .None:
            trackingUser = false
        case .Follow, .FollowWithHeading:
            trackingUser = true
        }
    }
    
    public func mapView(mapView: MKMapView!, didFailToLocateUserWithError error: NSError!) {
        hasPlottedInitUsersLocation = false
        zoomToShowAll()
        
        switch error.code {
        case CLError.LocationUnknown.rawValue:
            break
        case CLError.Denied.rawValue:
            break
        default:
            break
        }
    }
    
    // MARK: - UIActionSheetDelegate Methods
    
    public func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if let annotation = mapView.selectedAnnotations.first as? Annotation {
            switch buttonIndex {
            case 0:
                zoomToAnnotation(annotation)
            case 1:
                directionsToCurrentLocationFrom(coordinate: annotation.coordinate)
            case 2:
                directionsToCurrentLocationFrom(coordinate: annotation.coordinate, inApp: false)
            default:
                break
            }
        }
    }
    
    // MARK: - Search Methods
    
    public func searchAddresses(searchString: String) -> [Address] {
        if let predicate = NSPredicate(format: "name beginswith[cd] %@ || simpleAddress beginswith[cd] %@", searchString, searchString) {
            return (addresses as NSArray).filteredArrayUsingPredicate(predicate) as [Address]
        }
        return Array<Address>()
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
        return "<Latitude: \(latitude) Longitude: \(longitude) Address: \(simpleAddress)>"
    }
    override public var hash: Int {
        return Int(latitude) ^ Int(longitude)
    }
    
    override init() {
        super.init()
    }
    
    public convenience init(dictionary: NSDictionary) {
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
        
        if let name = dictionary["name"] as? String {
            self.name = name
        }
        
        if let simpleAddress = dictionary["simpleAddress"] as? String {
            self.simpleAddress = simpleAddress
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
    
    public lazy var address = Address()
    public var coordinate: CLLocationCoordinate2D {
        return address.coordinate
    }
    public var title: String {
        return address.name
    }
    public var subtitle: String {
        return address.simpleAddress
    }
    
    public override init() {
        super.init()
    }
    
    public convenience init(address: Address) {
        self.init()
        
        self.address = address
    }
    
    public func updateAddress(address: Address) {
        if self.address.isEqualToAddress(address) == false {
            self.address = address
        }
    }
    
}
