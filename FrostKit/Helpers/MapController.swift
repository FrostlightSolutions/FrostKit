//
//  MapController.swift
//  FrostKit
//
//  Created by James Barrow on 29/11/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

///
/// The map controller handles basic map options and controls for a `MKMapView`. It provides automatic functions for adding/removing annotations, finding directions, zooming the map view and searching the annotations plotted on the map.
///
/// This class is designed to be subclassed if more specific actions, such a refining the standard search or customising the annotations plotted.
///
public class MapController: NSObject, MKMapViewDelegate, UIActionSheetDelegate {
    
    private let minimumZoomArc = 0.007  //approximately 1/2 mile (1 degree of arc ~= 69 miles)
    private let maximumDegreesArc: Double = 360
    private let annotationRegionPadFactor: Double = 1.15
    /// The reuse identifier for the annotations for the map view. This should be overriden when subclassing.
    public let identifier = "FrostKitAnnotation"
    private var hasPlottedInitUsersLocation = false
    /// The view controller related to the map controller.
    @IBOutlet public weak var viewController: UIViewController!
    /// The map view related to the map controller.
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
    /// Refers to if the map controller should auto assign itself to the map view as a delegate.
    @IBInspectable var autoAssingDelegate: Bool = true {
        didSet {
            if autoAssingDelegate == true {
                mapView?.delegate = self
            }
        }
    }
    /// `true` if the user is currently being tracked in the map view or `false` if not.
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
    /// The location manager automatically created when assigning the map view to the map controller.
    public var locationManager: CLLocationManager?
    /// An array of addresses plotted on the map view.
    public var addresses = Array<Address>()
    /// A dictionary of annotations plotted to the map view with the address object as the key.
    public var annotations = Dictionary<Address, Annotation>()
    
    deinit {
        resetMap()
        purgeMap()
    }
    
    /**
    Resets the map controller, clearing the addresses, annotations and removing all annotations and polylines on the map view.
    */
    public func resetMap() {
        
        addresses.removeAll(keepCapacity: false)
        annotations.removeAll(keepCapacity: false)
        
        removeAllAnnotations()
        removeAllPolylines()
    }
    
    /**
    Attempt to purge the map view to free up some memory.
    */
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
    
    /**
    Plot an array of addresses to the map view.
    
    :param: addresses An array of addresses to plot.
    */
    public func plotAddresses(addresses: [Address]) {
        for address in addresses {
            plotAddress(address)
        }
    }
    
    /**
    Plot an address to the map view.
    
    :param: address An address to plot.
    */
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
    
    /**
    Remove all annotations plotted to the map.
    
    :param: includingCached If `true` then the cached annotations dictionary is also cleared.
    */
    public func removeAllAnnotations(includingCached: Bool = false) {
        let annotations = Array(self.annotations.values)
        mapView.removeAnnotations(annotations)
        
        if includingCached == true {
            self.annotations.removeAll(keepCapacity: false)
        }
    }
    
    /**
    Clears all of the annotations from the map, including caced, and clears the addresses array.
    */
    public func clearData() {
        removeAllAnnotations(includingCached: true)
        addresses.removeAll(keepCapacity: false)
    }
    
    // MARK: - Zoom Map Methods
    
    /**
    Zoom the map view to a coordinate.
    
    :param: coordinare The coordinate to zoom to.
    */
    public func zoomToCoordinate(coordinare: CLLocationCoordinate2D) {
        let point = MKMapPointForCoordinate(coordinare)
        zoomToMapPoints([point])
    }
    
    /**
    Zoom the map view to an annotation.
    
    :param: annotation The annotation to zoom to.
    */
    public func zoomToAnnotation(annotation: MKAnnotation) {
        zoomToAnnotations([annotation])
    }
    
    /**
    Zoom the map to show multiple annotations.
    
    :param: annotations The annotations to zoom to.
    */
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
    
    /**
    Zoom the map to show multiple map points.
    
    :param: points Swift array of `MKMapPoints` to zoom to.
    */
    public func zoomToMapPoints(points: [MKMapPoint]) {
        let count = points.count
        let cPoints: UnsafeMutablePointer<MKMapPoint> = UnsafeMutablePointer<MKMapPoint>.alloc(count)
        cPoints.initializeFrom(points)
        zoomToMapPoints(cPoints, count: count)
        cPoints.destroy()
    }
    
    /**
    Zoom the map to show multiple map points.
    
    :param: points C array array of `MKMapPoints` to zoom to.
    :param: count  The number of points in the C array.
    */
    public func zoomToMapPoints(points: UnsafeMutablePointer<MKMapPoint>, count: Int) {
        let mapRect = MKPolygon(points: points, count: count).boundingMapRect
        var region: MKCoordinateRegion = MKCoordinateRegionForMapRect(mapRect)
        
        if count <= 1 {
            region.span = MKCoordinateSpanMake(minimumZoomArc, minimumZoomArc)
        }
        
        zoomToRegion(region)
    }
    
    /**
    Zoom the map to show a region.
    
    :param: region The region to zoom the map to.
    */
    public func zoomToRegion(var region: MKCoordinateRegion) {
        region.span = normalizeRegionSpan(region.span)
        mapView.setRegion(region, animated: true)
    }
    
    /**
    Zoom the map to show the users current location.
    */
    public func zoomToCurrentLocation() {
        trackingUser = true
        zoomToCoordinate(mapView.userLocation.coordinate)
    }
    
    /**
    Zoom the map to show all points plotted on the map.
    
    :param: includingUser If `true` then the users annotation is also included in the points. If `false` then only plotted points are zoomed to.
    */
    public func zoomToShowAll(includingUser: Bool = true) {
        if includingUser == true {
            zoomToAnnotations(mapView.annotations as! [MKAnnotation])
        } else {
            let annotations = Array(self.annotations.values)
            zoomToAnnotations(annotations)
        }
    }
    
    /**
    Zooms the map to an address object.
    
    :param: address The address object to zoom to.
    */
    public func zoomToAddress(address: Address) {
        plotAddress(address)
        
        let annotation = annotations[address] as! MKAnnotation
        zoomToAnnotations([annotation])
    }
    
    /**
    Zooms the map to a polyline.
    
    :param: polyline The polyline to zoom to.
    */
    public func zoomToPolyline(polyline: MKPolyline) {
        zoomToMapPoints(polyline.points(), count: polyline.pointCount)
    }
    
    // MARK: - Polyline and Route Methods
    
    /**
    Removes all the polylines plotted on the map view.
    */
    public func removeAllPolylines() {
        if let overlays = mapView.overlays {
            for overlay in overlays {
                if let polyline = overlay as? MKPolyline {
                    mapView.removeOverlay(polyline)
                }
            }
        }
    }
    
    /**
    Gets directions to a coordinate from the users current location.
    
    :param: coordinate The coordinate to get directions to.
    :param: inApp      If `true` diretions are plotted in-app on the map view. If `false` then the Maps.app is opened with the directions requested.
    */
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
            NSNotificationCenter.defaultCenter().postNotificationName(NetworkRequestDidBeginNotification, object: nil)
            directions.calculateDirectionsWithCompletionHandler({ (directionsResponse, error) -> Void in
                if let anError = error {
                    NSLog("Error getting directions: \(error.localizedDescription)")
                } else {
                    if let route = directionsResponse.routes.first as? MKRoute {
                        self.plotRoute(route)
                    }
                }
                NSNotificationCenter.defaultCenter().postNotificationName(NetworkRequestDidCompleteNotification, object: nil)
            })
        } else {
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            MKMapItem.openMapsWithItems([currentLocationItem, destinationItem], launchOptions: launchOptions)
        }
    }
    
    /**
    Plots a route as a polyline after removing all previous reotes, and then zoom to display the new route.
    
    :param: route The route to plot.
    */
    public func plotRoute(route: MKRoute) {
        removeAllPolylines()
        mapView.addOverlay(route.polyline, level: .AboveRoads)
        zoomToPolyline(route.polyline)
    }
    
    // MARK: - Helper Methods
    
    /**
    Normalizes a regions space with the constants preset.
    
    :param: span The span to normalize.
    
    :returns: The normalized span.
    */
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
                pinView.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
                annotationPinView = pinView
            }
        }
        
        return annotationPinView
    }
    
    public func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if let annotation = view.annotation as? Annotation {
            if NSClassFromString("UIAlertController") == nil {
                // iOS 7
                let title = [annotation.title, annotation.subtitle].componentsJoinedByString("\n")
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
    
    /**
    Performs a predicate search on the addresses dictionary that begins with the search string.
    
    :param: searchString The string to search the addresses by name or simple address.
    
    :returns: An array of addresses that meet the predicate search criteria.
    */
    public func searchAddresses(searchString: String) -> [Address] {
        let predicate = NSPredicate(format: "name beginswith[cd] %@ || addressString beginswith[cd] %@", searchString, searchString)
        return (addresses as NSArray).filteredArrayUsingPredicate(predicate) as! [Address]
    }
    
}

// MARK: - Address Object

///
/// An object that contains details on a address to the plot on the map view, along with other data such as name and addressString.
///
public class Address: NSObject {
    
    /// The ID of the addres object.
    public var objectID: String?
    /// The coordinate of the address.
    public var coordinate = CLLocationCoordinate2DMake(0.0, 0.0)
    /// The latitude of the address.
    public var latitude: CLLocationDegrees {
        return coordinate.latitude
    }
    /// The longitude of the address.
    public var longitude: CLLocationDegrees {
        return coordinate.longitude
    }
    /// If the address is valid then `true`, otherwise return `false`.
    public var isValid: Bool {
        if latitude == 0 && longitude == 0 {
            return false
        } else {
            return true
        }
    }
    /// The name of the address object.
    public var name = ""
    /// The address string of the object.
    public var addressString = ""
    /// Returns a string that represents the contents of the receiving class.
    override public var description: String {
        return "<Latitude: \(latitude) Longitude: \(longitude) Address: \(addressString)>"
    }
    override public var hash: Int {
        return Int(latitude) ^ Int(longitude)
    }
    
    public override init() {
        super.init()
    }
    
    /**
    A convenience initialiser for creating an address object from a dictionary returned from a FUS based system.
    
    :param: dictionary The dictionary to parse the information from.
    */
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
        
        if let addressString = dictionary["addressString"] as? String {
            self.addressString = addressString
        }
    }
    
    /**
    A helper method for creating an array of address objects from an array of dictionaryies.
    
    :param: array An array of dictionaries returned by a FUS like system.
    
    :returns: An array of address objects.
    */
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
            let haveEqualAddressString = self.addressString == address.addressString
            
            return haveEqualLatitude && haveEqualLongitude && haveEqualName && haveEqualAddressString
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

///
/// An annotation object that is to be used with an address object.
///
public class Annotation: NSObject, MKAnnotation {
    
    /// The address object for the annotation.
    public lazy var address = Address()
    /// The coordinate of the address.
    public var coordinate: CLLocationCoordinate2D {
        return address.coordinate
    }
    /// The name of the address.
    public var title: String {
        return address.name
    }
    /// The address string of the address.
    public var subtitle: String {
        return address.addressString
    }
    
    public override init() {
        super.init()
    }
    
    /**
    A convenience method for making an annotation object from an address object.
    
    :param: address The address object to base the annotation off of.
    */
    public convenience init(address: Address) {
        self.init()
        
        self.address = address
    }
    
    /**
    Updates the annotation with an address.
    
    :param: address The address to update the annotation with.
    */
    public func updateAddress(address: Address) {
        if self.address.isEqualToAddress(address) == false {
            self.address = address
        }
    }
    
}
