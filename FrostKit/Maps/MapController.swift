//
//  MapController.swift
//  FrostKit
//
//  Created by James Barrow on 29/11/2014.
//  Copyright © 2014 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

///
/// The map controller handles basic map options and controls for a `MKMapView`. It provides automatic functions for adding/removing annotations, finding directions, zooming the map view and searching the annotations plotted on the map.
///
/// This class is designed to be subclassed if more specific actions, such a refining the standard search or customising the annotations plotted.
///
open class MapController: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
    
    private let minimumZoomArc = 0.007  //approximately 1/2 mile (1 degree of arc ~= 69 miles)
    private let maximumDegreesArc: Double = 360
    private let annotationRegionPadFactor: Double = 1.15
    /// The reuse identifier for the annotations for the map view. This should be overriden when subclassing.
    open var identifier: String {
        return "FrostKitAnnotation"
    }
    
    /// Dictates if the users location has been initially plotted.
    public var hasPlottedInitUsersLocation = false
    /// Dictates if the users location was not able to be plotted, due permissions issues, etc.
    public var failedToPlotUsersLocation = false
    /// The view controller related to the map controller.
    @IBOutlet open weak var viewController: UIViewController!
    /// The map view related to the map controller.
    @IBOutlet open weak var mapView: MKMapView? {
        didSet {
            mapView?.userTrackingMode = .follow
            mapView?.showsUserLocation = true
            if autoAssingDelegate == true {
                mapView?.delegate = self
            }
            
            if shouldRequestLocationServices {
                requestAccessToLocationServices()
            }
        }
    }
    
    private var currentlyUpdatingVisableAnnotations = false
    private var shouldTryToUpdateVisableAnnotationsAgain = false
    /// Refers to if the map controller should auto assign itself to the map view as a delegate.
    @IBInspectable open var autoAssingDelegate: Bool = true {
        didSet {
            if autoAssingDelegate == true {
                mapView?.delegate = self
            }
        }
    }
    
    /// `true` if the user is currently being tracked in the map view or `false` if not.
    open var trackingUser: Bool = false {
        didSet {
            if trackingUser == true {
                mapView?.userTrackingMode = .follow
            } else {
                mapView?.userTrackingMode = .none
            }
            
            if let mapViewController = viewController as? MapViewController {
                mapViewController.updateNavigationButtons()
            }
        }
    }
    
    /// Determins if the location manager should request access to location services on setup. By default this is set to `false`.
    @IBInspectable open var shouldRequestLocationServices: Bool = false
    /// The location manager automatically created when assigning the map view to the map controller. It's only use if for getting the user's access to location services.
    private var locationManager: CLLocationManager?
    /// An array of addresses plotted on the map view.
    open var addresses: [Address] {
        return [Address](addressesDict.values)
    }
    
    private var addressesDict = [AnyHashable: Address]()
    
    /// A dictionary of annotations plotted to the map view with the address object as the key.
    open var annotations = [AnyHashable: Any]()
    /// When the map automatically zooms to show all, if this value is set to true, then the users annoation is automatically included in that.
    @IBInspectable open var zoomToShowAllIncludesUser: Bool = true
    private var regionSpanBeforeChange: MKCoordinateSpan?
    
    deinit {
        resetMap()
        purgeMap()
    }
    
    /**
    Resets the map controller, clearing the addresses, annotations and removing all annotations and polylines on the map view.
    */
    open func resetMap() {
        
        addressesDict.removeAll(keepingCapacity: false)
        annotations.removeAll(keepingCapacity: false)
        
        removeAllAnnotations()
        removeAllPolylines()
    }
    
    /**
    Attempt to purge the map view to free up some memory.
    */
    private func purgeMap() {
        
        mapView?.userTrackingMode = .none
        mapView?.showsUserLocation = true
        mapView?.mapType = .standard
        mapView?.delegate = nil
    }
    
    // MARK: - Location Services
    
    open class func requestAccessToLocationServices(_ locationManager: CLLocationManager) {
        
        if let infoDictionary = Bundle.main.infoDictionary {
            
            if infoDictionary["NSLocationAlwaysUsageDescription"] != nil {
                locationManager.requestAlwaysAuthorization()
            } else if infoDictionary["NSLocationWhenInUseUsageDescription"] != nil {
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    open func requestAccessToLocationServices() {
        
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
        }
        
        MapController.requestAccessToLocationServices(locationManager!)
    }
    
    // MARK: - Plot/Remove Annotations Methods
    
    /**
    Plot an array of addresses to the map view.
     
    - parameter addresses: An array of addresses to plot.
    */
    open func plot(addresses: [Address]) {
        for address in addresses {
            plot(address: address, asBulk: true)
        }
        updateVisableAnnotations()
    }
    
    /**
     Plot an address to the map view.
     
     - parameter address:        An address to plot.
     - parameter asBulk: Tells the controller if this is part of a bulk command. Leave to `false` for better performance.
     */
    open func plot(address: Address, asBulk: Bool = false) {
        if address.isValid == false {
            return
        }
        
        // Update or add the address
        addressesDict[address.key] = address
        
        let annotation: Annotation
        if let currentAnnotation = annotations[address.key] as? Annotation {
            // Annotation already exists, update the address
            currentAnnotation.update(address: address)
            annotation = currentAnnotation
        } else {
            // No previous annotation for this addres, create one
            let newAnnotation = Annotation(address: address)
            annotation = newAnnotation
        }
        
        // Update annotation in cache
        annotations[address.key] = annotation
        
        mapView?.addAnnotation(annotation)
        
        if asBulk == false {
            updateVisableAnnotations()
        }
    }
    
    /**
    Remove all annotations plotted to the map.
     
    - parameter includingCached: If `true` then the cached annotations dictionary is also cleared.
    */
    open func removeAllAnnotations(includingCached: Bool = false) {
        
        guard let annotations = Array(self.annotations.values) as? [MKAnnotation] else {
            return
        }
        mapView?.removeAnnotations(annotations)
        
        if includingCached == true {
            self.annotations.removeAll(keepingCapacity: false)
        }
        
        updateVisableAnnotations()
    }
    
    /**
    Clears all of the annotations from the map, including caced, and clears the addresses array.
    */
    open func clearData() {
        removeAllAnnotations(includingCached: true)
        addressesDict.removeAll(keepingCapacity: false)
    }
    
    // MARK: - Annotation Clustering
    
    /**
     This function is automatically called when an address is added or the map region changes.
     
     If you have customised plotting of map points, this should be called, but should not be overriden.
     */
    public final func updateVisableAnnotations() {
        
        if currentlyUpdatingVisableAnnotations == true {
            shouldTryToUpdateVisableAnnotationsAgain = true
            return
        }
        
        currentlyUpdatingVisableAnnotations = true
        shouldTryToUpdateVisableAnnotationsAgain = false
        
        currentlyUpdatingVisableAnnotations = false
        if shouldTryToUpdateVisableAnnotationsAgain == true {
            updateVisableAnnotations()
        }
    }
    
    // MARK: - Zoom Map Methods
    
    /**
     Zoom the map view to a coordinate.
     
     - parameter coordinare: The coordinate to zoom to.
     */
    open func zoom(toCoordinate coordinare: CLLocationCoordinate2D) {
        let point = MKMapPoint(coordinare)
        zoom(toMapPoints: [point])
    }
    
    /**
     Zoom the map view to an annotation.
     
     - parameter annotation: The annotation to zoom to.
     */
    open func zoom(toAnnotation annotation: MKAnnotation) {
        zoom(toAnnotations: [annotation])
    }
    
    /**
     Zoom the map to show multiple annotations.
     
     - parameter annotations: The annotations to zoom to.
     */
    open func zoom(toAnnotations annotations: [MKAnnotation]) {
        let count = annotations.count
        if count > 0 {
            var points = [MKMapPoint]()
            for annotation in annotations {
                points.append(MKMapPoint(annotation.coordinate))
            }
            zoom(toMapPoints: points)
        }
    }
    
    /**
     Zoom the map to show multiple map points.
     
     - parameter points: Swift array of `MKMapPoints` to zoom to.
     */
    open func zoom(toMapPoints points: [MKMapPoint]) {
        let count = points.count
        let cPoints = UnsafeMutablePointer<MKMapPoint>.allocate(capacity: count)
        cPoints.initialize(from: points, count: count)
        zoom(toMapPoints: cPoints, count: count)
        cPoints.deinitialize(count: count)
    }
    
    /**
     Zoom the map to show multiple map points.
     
     - parameter points: C array array of `MKMapPoints` to zoom to.
     - parameter count:  The number of points in the C array.
     */
    open func zoom(toMapPoints points: UnsafeMutablePointer<MKMapPoint>, count: Int) {
        let mapRect = MKPolygon(points: points, count: count).boundingMapRect
        var region: MKCoordinateRegion = MKCoordinateRegion(mapRect)
        
        if count <= 1 {
            region.span = MKCoordinateSpan(latitudeDelta: minimumZoomArc, longitudeDelta: minimumZoomArc)
        }
        
        zoom(toRegion: region)
    }
    
    /**
     Zoom the map to show a region.
     
     - parameter region: The region to zoom the map to.
     */
    open func zoom(toRegion region: MKCoordinateRegion) {
        
        var zoomRegion = region
        zoomRegion.span = normalize(regionSpan: region.span)
        mapView?.setRegion(zoomRegion, animated: true)
    }
    
    /**
     Zoom the map to show the users current location.
     */
    open func zoomToCurrentLocation() {
        trackingUser = true
        if let mapView = self.mapView {
            zoom(toCoordinate: mapView.userLocation.coordinate)
        }
    }
    
    /**
     Zoom the map to show all points plotted on the map.
     
     - parameter includingUser: If `true` then the users annotation is also included in the points. If `false` then only plotted points are zoomed to.
     */
    open func zoomToShowAll(includingUser: Bool = true) {
        
        if includingUser == false || zoomToShowAllIncludesUser == false, let annotations = Array(self.annotations.values) as? [MKAnnotation] {
            zoom(toAnnotations: annotations)
        } else if let mapView = self.mapView {
            zoom(toAnnotations: mapView.annotations)
        }
    }
    
    /// Zooms the map to an array of address objects.
    ///
    /// - Parameter addresses: The address objects to zoom to.
    open func zoom(toAddresses addresses: [Address]) {
        
        let count = addresses.count
        if count > 0 {
            var points = [MKMapPoint]()
            for address in addresses {
                points.append(MKMapPoint(address.coordinate))
            }
            zoom(toMapPoints: points)
        }
    }
    
    /**
     Zooms the map to an address object.
     
     - parameter address: The address object to zoom to.
     */
    open func zoom(toAddress address: Address) {
        
        if #available(iOS 9.0, *) {
            let camera = MKMapCamera(lookingAtCenter: address.coordinate, fromDistance: 200, pitch: 0, heading: 0)
            mapView?.setCamera(camera, animated: true)
        } else {
            let camera = MKMapCamera(lookingAtCenter: address.coordinate, fromEyeCoordinate: address.coordinate, eyeAltitude: 200)
            mapView?.setCamera(camera, animated: true)
        }
    }
    
    /**
     Zooms the map to a polyline.
     
     - parameter polyline: The polyline to zoom to.
     */
    open func zoom(toPolyline polyline: MKPolyline) {
        zoom(toMapPoints: polyline.points(), count: polyline.pointCount)
    }
    
    // MARK: - Polyline and Route Methods
    
    /**
     Removes all the polylines plotted on the map view.
     */
    open func removeAllPolylines() {
        
        guard let mapView = self.mapView else {
            return
        }
        
        for overlay in mapView.overlays {
            if let polyline = overlay as? MKPolyline {
                mapView.removeOverlay(polyline)
            }
        }
    }
    
    /**
     Gets a route between a source and destination.
     
     - parameter source:        The coordinate of the source location.
     - parameter destination:   The coordinate of the destination location.
     - parameter transportType: The transportation type to create the route.
     - parameter complete:      Returns an optional route and error.
     */
    open func routeBetween(sourceCoordinate source: CLLocationCoordinate2D, destinationCoordinate destination: CLLocationCoordinate2D, transportType: MKDirectionsTransportType = .automobile, complete: @escaping (_ route: MKRoute?, _ error: Error?) -> Void) {
        
        let sourcePlacemark = MKPlacemark(coordinate: source, addressDictionary: nil)
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationPlacemark = MKPlacemark(coordinate: destination, addressDictionary: nil)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        routeBetween(sourceMapItem: sourceItem, destinationMapItem: destinationItem, transportType: transportType, complete: complete)
    }
    
    /**
     Gets a route between a source and destination.
     
     - parameter source:        The map item of the source location.
     - parameter destination:   The map item of the destination location.
     - parameter transportType: The transportation type to create the route.
     - parameter complete:      Returns an optional route and error.
     */
    open func routeBetween(sourceMapItem source: MKMapItem, destinationMapItem destination: MKMapItem, transportType: MKDirectionsTransportType = .automobile, complete: @escaping (_ route: MKRoute?, _ error: Error?) -> Void) {
        
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = source
        directionsRequest.destination = destination
        directionsRequest.transportType = transportType
        directionsRequest.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: directionsRequest)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NetworkRequestDidBeginNotification), object: nil)
        directions.calculate { (directionsResponse, error) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NetworkRequestDidCompleteNotification), object: nil)
            complete(directionsResponse?.routes.first, error)
        }
    }
    
    /**
     Gets directions to a coordinate from the users current location.
     
     - parameter coordinate: The coordinate to get directions to.
     - parameter inApp:      If `true` diretions are plotted in-app on the map view. If `false` then the Maps.app is opened with the directions requested.
     */
    open func directionsToCurrentLocation(fromCoordinate coordinate: CLLocationCoordinate2D, inApp: Bool = true) {
        
        let currentLocationItem = MKMapItem.forCurrentLocation()
        let destinationPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        if inApp == true {
            routeBetween(sourceMapItem: currentLocationItem, destinationMapItem: destinationItem, complete: { (route, error) in
                if let anError = error {
                    DLog("Error getting directions: \(anError.localizedDescription)")
                } else if let aRoute = route {
                    self.plot(route: aRoute)
                }
            })
        } else {
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            MKMapItem.openMaps(with: [currentLocationItem, destinationItem], launchOptions: launchOptions)
        }
    }
    
    /**
     Plots a route as a polyline after removing all previous reotes, and then zoom to display the new route.
     
     - parameter route: The route to plot.
     */
    open func plot(route: MKRoute) {
        mapView?.addOverlay(route.polyline, level: .aboveRoads)
    }
    
    // MARK: - Helper Methods
    
    /**
     Normalizes a regions space with the constants preset.
     
     - parameter span: The span to normalize.
     
     - returns: The normalized span.
     */
    open func normalize(regionSpan span: MKCoordinateSpan) -> MKCoordinateSpan {
        
        var normalizedSpan = MKCoordinateSpan(latitudeDelta: span.latitudeDelta * annotationRegionPadFactor, longitudeDelta: span.longitudeDelta * annotationRegionPadFactor)
        if normalizedSpan.latitudeDelta > maximumDegreesArc {
            normalizedSpan.latitudeDelta = maximumDegreesArc
        } else if normalizedSpan.latitudeDelta < minimumZoomArc {
            normalizedSpan.latitudeDelta = minimumZoomArc
        }
        
        if normalizedSpan.longitudeDelta > maximumDegreesArc {
            normalizedSpan.longitudeDelta = maximumDegreesArc
        } else if normalizedSpan.longitudeDelta < minimumZoomArc {
            normalizedSpan.longitudeDelta = minimumZoomArc
        }
        return normalizedSpan
    }
    
    /**
     Deselects any showing annotation view callout on the map.
     */
    open func deselectAllAnnotations() {
        
        guard let mapView = self.mapView else {
            return
        }
        
        let selectedAnnotations = mapView.selectedAnnotations
        for selectedAnnotation in selectedAnnotations {
            mapView.deselectAnnotation(selectedAnnotation, animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate Methods
    
    open func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let myAnnotation = annotation as? Annotation else {
            return nil
        }
        
        let annotationPinView: MKPinAnnotationView
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            
            annotationView.annotation = myAnnotation
            annotationPinView = annotationView
            
        } else {
            
            let pinView = MKPinAnnotationView(annotation: myAnnotation, reuseIdentifier: identifier)
            if #available(iOSApplicationExtension 9.0, *) {
                pinView.pinTintColor = MKPinAnnotationView.redPinColor()
            } else {
                pinView.pinColor = .red
            }
            pinView.animatesDrop = false
            pinView.isHidden = false
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.isDraggable = false
            
            if let anno = annotation as? Annotation, let containdedAnnotations = anno.containdedAnnotations {
                if anno.containdedAnnotations == nil || containdedAnnotations.count <= 0 {
                    pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                }
            }
            
            annotationPinView = pinView
        }
        
        return annotationPinView
    }
    
    open func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        guard let annotation = view.annotation as? Annotation else {
            return
        }
        
        let alertController = UIAlertController(title: annotation.title, message: annotation.subtitle, preferredStyle: .actionSheet)
        let zoomToAlertAction = UIAlertAction(title: FKLocalizedString("ZOOM_TO_", comment: "Zoom to..."), style: .default, handler: { (_) in
            self.zoom(toAnnotation: annotation)
        })
        alertController.addAction(zoomToAlertAction)
        
        let directionsAlertAction = UIAlertAction(title: FKLocalizedString("DIRECTIONS", comment: "Directions"), style: .default, handler: { (_) in
            self.directionsToCurrentLocation(fromCoordinate: annotation.coordinate)
        })
        alertController.addAction(directionsAlertAction)
        
        let openInMapsAlertAction = UIAlertAction(title: FKLocalizedString("OPEN_IN_MAPS", comment: "Open in Maps"), style: .default, handler: { (_) in
            self.directionsToCurrentLocation(fromCoordinate: annotation.coordinate, inApp: false)
        })
        alertController.addAction(openInMapsAlertAction)
        
        let cancelAlertAction = UIAlertAction(title: FKLocalizedString("CANCEL", comment: "Cancel"), style: .cancel, handler: { (_) in
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(cancelAlertAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    open func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }
        
        let polylineRenderer = MKPolylineRenderer(polyline: polyline)
        polylineRenderer.strokeColor = UIColor.blue
        polylineRenderer.lineWidth = 4
        polylineRenderer.lineCap = .round
        polylineRenderer.lineJoin = .round
        polylineRenderer.alpha = 0.6
        return polylineRenderer
    }
    
    open func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        regionSpanBeforeChange = mapView.region.span
    }
    
    open func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if let regionSpanBeforeChange = self.regionSpanBeforeChange {
            
            let hasZoomed = !(fabs(mapView.region.span.longitudeDelta - regionSpanBeforeChange.longitudeDelta) < 1.19209290e-7)
            if hasZoomed {
                deselectAllAnnotations()
            }
        }
        
        updateVisableAnnotations()
    }
    
    open func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if hasPlottedInitUsersLocation == false {
            hasPlottedInitUsersLocation = true
            failedToPlotUsersLocation = false
            zoomToShowAll()
        }
    }
    
    open func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        
        switch mode {
        case .none:
            trackingUser = false
        case .follow, .followWithHeading:
            trackingUser = true
        @unknown default:
            break
        }
    }
    
    open func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        
        hasPlottedInitUsersLocation = false
        failedToPlotUsersLocation = true
        zoomToShowAll()
    }
    
    // MARL: - CLLocationManagerDelegate Methods
    
    open func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // Set the location manager to nil if not `NotDetermined`. If `NotDetermined` then it is possible the delegate was called before the user has answered.
        if status != .notDetermined {
            self.locationManager = nil
        }
    }
    
    // MARK: - Search Methods
    
    /**
     Performs a predicate search on the addresses dictionary that begins with the search string.
     
     - parameter searchString: The string to search the addresses by name or simple address.
     
     - returns: An array of addresses that meet the predicate search criteria.
     */
    open func searchAddresses(_ searchString: String) -> [Address] {
        return addresses.filter { (address) -> Bool in
            
            let options: NSString.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
            
            let nameRange = address.name.range(of: searchString, options: options)
            let addressStringRange = address.addressString.range(of: searchString, options: options)
            
            return nameRange != nil || addressStringRange != nil
        }
    }
}
