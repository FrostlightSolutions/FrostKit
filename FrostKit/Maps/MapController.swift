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
public class MapController: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
    
    private let minimumZoomArc = 0.007  //approximately 1/2 mile (1 degree of arc ~= 69 miles)
    private let maximumDegreesArc: Double = 360
    private let annotationRegionPadFactor: Double = 1.15
    /// The reuse identifier for the annotations for the map view. This should be overriden when subclassing.
    public var identifier: String {
        return "FrostKitAnnotation"
    }
    private var hasPlottedInitUsersLocation = false
    /// The view controller related to the map controller.
    @IBOutlet public weak var viewController: UIViewController!
    /// The map view related to the map controller.
    @IBOutlet public weak var mapView: MKMapView? {
        didSet {
            mapView?.userTrackingMode = .Follow
            mapView?.showsUserLocation = true
            if autoAssingDelegate == true {
                mapView?.delegate = self
            }
            
            if shouldRequestLocationServices {
                
                if locationManager == nil {
                    locationManager = CLLocationManager()
                    locationManager?.delegate = self
                }
                
                MapController.requestAccessToLocationServices(locationManager!)
            }
        }
    }
    /// Used for plotting all annotations to ditermine annotation clustering.
    public let offscreenMapView = MKMapView(frame: CGRect())
    /**
     This value controls the number of off screen annotations displayed.
     
     A bigger number means more annotations, less change of seeing annotation views pop in, but decreaced performance.
     
     A smaller number means fewer annotations, more chance of seeing annotation views pop in, but better performance.
    */
    public var marginFactor: Double {
        return 2
    }
    /**
     Adjust this based on the deimensions of your annotation views.
     
     Bigger number more aggressively coalesce annotations (fewer annotations displayed, but better performance).
     
     Numbers too small result in overlapping annotation views and too many annotations on screen.
    */
    public var bucketSize: Double {
        return 60
    }
    private var currentlyUpdatingVisableAnnotations = false
    private var shouldTryToUpdateVisableAnnotationsWhenFinished = false
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
                mapView?.userTrackingMode = .Follow
            } else {
                mapView?.userTrackingMode = .None
            }
            
            if let mapViewController = viewController as? MapViewController {
                mapViewController.updateNavigationButtons()
            }
        }
    }
    /// Determins if the location manager should request access to location services on setup. By default this is set to `false`.
    @IBInspectable public var shouldRequestLocationServices: Bool = false
    /// The location manager automatically created when assigning the map view to the map controller. It's only use if for getting the user's access to location services.
    private var locationManager: CLLocationManager?
    /// An array of addresses plotted on the map view.
    public var addresses = [Address]()
    /// A dictionary of annotations plotted to the map view with the address object as the key.
    public var annotations = [NSObject: MKAnnotation]()
    /// When the map automatically zooms to show all, if this value is set to true, then the users annoation is automatically included in that.
    public var zoomToShowAllIncludesUser: Bool {
        return true
    }
    
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
        
        mapView?.userTrackingMode = .None
        mapView?.showsUserLocation = true
        mapView?.mapType = .Standard
        mapView?.delegate = nil
    }
    
    // MARK: - Location Services
    
    public class func requestAccessToLocationServices(locationManager: CLLocationManager) {
        
        if let infoDictionary = NSBundle.mainBundle().infoDictionary {
            
            if infoDictionary["NSLocationAlwaysUsageDescription"] != nil {
                locationManager.requestAlwaysAuthorization()
            } else if infoDictionary["NSLocationWhenInUseUsageDescription"] != nil {
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    // MARK: - Plot/Remove Annotations Methods
    
    /**
    Plot an array of addresses to the map view.
    
    - parameter addresses: An array of addresses to plot.
    */
    public func plotAddresses(addresses: [Address]) {
        for address in addresses {
            plotAddress(address, plottingAsBulk: true)
        }
        updateVisableAnnotations()
    }
    
    /**
     Plot an address to the map view.
     
     - parameter address:        An address to plot.
     - parameter plottingAsBulk: Tells the controller if this is part of a bulk command. Leave to `false` for better performance.
     */
    public func plotAddress(address: Address, plottingAsBulk: Bool = false) {
        if address.isValid == false {
            return
        }
        
        if let index = addresses.indexOf(address) {
            addresses[index] = address
        } else {
            addresses.append(address)
        }
        
        var annotation: Annotation?
        if let currentAnnotation = annotations[address] as? Annotation {
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
            offscreenMapView.addAnnotation(currentAnnotation)
            
            if plottingAsBulk == false {
                updateVisableAnnotations()
            }
        }
    }
    
    /**
    Remove all annotations plotted to the map.
    
    - parameter includingCached: If `true` then the cached annotations dictionary is also cleared.
    */
    public func removeAllAnnotations(includingCached: Bool = false) {
        let annotations = Array(self.annotations.values)
        offscreenMapView.removeAnnotations(annotations)
        
        if includingCached == true {
            self.annotations.removeAll(keepCapacity: false)
        }
        
        updateVisableAnnotations()
    }
    
    /**
    Clears all of the annotations from the map, including caced, and clears the addresses array.
    */
    public func clearData() {
        removeAllAnnotations(true)
        addresses.removeAll(keepCapacity: false)
    }
    
    // MARK: - Annotation Clustering
    
    /**
     This function is automatically called when an address is added or the map region changes.
     
     If you have customised plotting of map points, this should be called, but should not be overriden.
     */
    public final func updateVisableAnnotations() {
        
        if currentlyUpdatingVisableAnnotations == true {
            shouldTryToUpdateVisableAnnotationsWhenFinished = true
            return
        }
        
        currentlyUpdatingVisableAnnotations = true
        shouldTryToUpdateVisableAnnotationsWhenFinished = false
        
        guard let mapView = self.mapView else {
            return
        }
        
        let marginFactor = self.marginFactor
        let bucketSize = self.bucketSize
        
        // Fill all the annotations in the viaable area + a wide margin to avoid poppoing annotation views ina dn out while panning the map.
        let visableMapRect = mapView.visibleMapRect
        let adjustedVisableMapRect = MKMapRectInset(visableMapRect, -marginFactor * visableMapRect.size.width, -marginFactor * visableMapRect.size.height)
        
        // Determine how wide each bucket will be, as a MKMapRect square
        let leftCoordinate = mapView.convertPoint(CGPoint(), toCoordinateFromView: viewController.view)
        let rightCoordinate = mapView.convertPoint(CGPoint(x: bucketSize, y: 0), toCoordinateFromView: viewController.view)
        let gridSize = MKMapPointForCoordinate(rightCoordinate).x - MKMapPointForCoordinate(leftCoordinate).x
        var gridMapRect = MKMapRect(origin: MKMapPoint(x: 0, y: 0), size: MKMapSize(width: gridSize, height: gridSize))
        
        // Condense annotations. with a padding of two squares, around the viableMapRect
        let startX = floor(MKMapRectGetMinX(adjustedVisableMapRect) / gridSize) * gridSize
        let startY = floor(MKMapRectGetMinY(adjustedVisableMapRect) / gridSize) * gridSize
        let endX = floor(MKMapRectGetMaxX(adjustedVisableMapRect) / gridSize) * gridSize
        let endY = floor(MKMapRectGetMaxY(adjustedVisableMapRect) / gridSize) * gridSize
        
        // For each square in the grid, pick one annotation to show
        gridMapRect.origin.y = startY
        while MKMapRectGetMinY(gridMapRect) <= endY {
            
            gridMapRect.origin.x = startX
            while MKMapRectGetMinX(gridMapRect) <= endX {
                
                guard let visableAnnotationsInBucket = mapView.annotationsInMapRect(gridMapRect) as? Set<Annotation> else {
                    continue
                }
                
                // Limited to only the use Annotation classes or subclasses
                let allAnnotationsInBucket = offscreenMapView.annotationsInMapRect(gridMapRect)
                guard var filteredAllAnnotationsInBucket = (allAnnotationsInBucket as NSSet).objectsPassingTest({ (object, stop) -> Bool in
                    return object.isKindOfClass(Annotation)
                }) as? Set<Annotation> else {
                    continue
                }
                
                if filteredAllAnnotationsInBucket.count > 0 {
                    
                    guard let annotationForGrid = calculatedAnnotationInGrid(mapView, gridMapRect: gridMapRect, allAnnotations: filteredAllAnnotationsInBucket, visableAnnotations: visableAnnotationsInBucket) else {
                        continue
                    }
                    
                    filteredAllAnnotationsInBucket.remove(annotationForGrid)
                    
                    // Give the annotationForGrid a reference to all the annotations it will represent
                    annotationForGrid.containdedAnnotations = (filteredAllAnnotationsInBucket as NSSet).allObjects as? [Annotation]
                    
                    mapView.addAnnotation(annotationForGrid)
                    
                    // Cleanup other annotations that might be being viewed
                    for annotation in filteredAllAnnotationsInBucket {
                        
                        // Give all the other annotations a reference to the one which is representing then.
                        annotation.clusterAnnotation = annotationForGrid
                        
                        if visableAnnotationsInBucket.contains(annotation) {
                            mapView.removeAnnotation(annotation)
                        }
                    }
                }
                
                gridMapRect.origin.x += gridSize
            }
            
            gridMapRect.origin.y += gridSize
        }
        
        currentlyUpdatingVisableAnnotations = false
        NSLog("Completed \(#function).")
        if shouldTryToUpdateVisableAnnotationsWhenFinished == true {
            NSLog("Re-trying to update visable annotations...")
            updateVisableAnnotations()
        }
    }
    
    private func calculatedAnnotationInGrid(mapView: MKMapView, gridMapRect: MKMapRect, allAnnotations: Set<Annotation>, visableAnnotations: Set<Annotation>) -> Annotation? {
        
        // First, see if one of the annotations we were already showing is in this mapRect
        let annotationsForGridSet = (visableAnnotations as NSSet).objectsPassingTest({ (object, stop) -> Bool in
            
            let returnValue = visableAnnotations.contains(object as! Annotation)
            if returnValue {
                stop.memory = true
            }
            return returnValue
            
        }) as? Set<Annotation>
        
        if let annotations = annotationsForGridSet where annotations.count != 0 {
            return annotations.first
        }
        
        // Otherwise, sort the annotations based on their  distance from the center of the grid square,
        // then choose the one closest to the center to show.
        let centerMapPoint = MKMapPoint(x: MKMapRectGetMidX(gridMapRect), y: MKMapRectGetMidY(gridMapRect))
        let sortedAnnotations = allAnnotations.sort { (object1, object2) -> Bool in
            
            let mapPoint1 = MKMapPointForCoordinate(object1.coordinate)
            let mapPoint2 = MKMapPointForCoordinate(object2.coordinate)
            
            let distance1 = MKMetersBetweenMapPoints(mapPoint1, centerMapPoint)
            let distance2 = MKMetersBetweenMapPoints(mapPoint2, centerMapPoint)
            
            return distance1 < distance2
        }
        
        return sortedAnnotations.first
    }
    
    // MARK: - Zoom Map Methods
    
    /**
    Zoom the map view to a coordinate.
    
    - parameter coordinare: The coordinate to zoom to.
    */
    public func zoomToCoordinate(coordinare: CLLocationCoordinate2D) {
        let point = MKMapPointForCoordinate(coordinare)
        zoomToMapPoints([point])
    }
    
    /**
    Zoom the map view to an annotation.
    
    - parameter annotation: The annotation to zoom to.
    */
    public func zoomToAnnotation(annotation: MKAnnotation) {
        zoomToAnnotations([annotation])
    }
    
    /**
    Zoom the map to show multiple annotations.
    
    - parameter annotations: The annotations to zoom to.
    */
    public func zoomToAnnotations(annotations: [MKAnnotation]) {
        let count = annotations.count
        if count > 0 {
            var points = [MKMapPoint]()
            for annotation in annotations {
                points.append(MKMapPointForCoordinate(annotation.coordinate))
            }
            zoomToMapPoints(points)
        }
    }
    
    /**
    Zoom the map to show multiple map points.
    
    - parameter points: Swift array of `MKMapPoints` to zoom to.
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
    
    - parameter points: C array array of `MKMapPoints` to zoom to.
    - parameter count:  The number of points in the C array.
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
    
    - parameter region: The region to zoom the map to.
    */
    public func zoomToRegion(region: MKCoordinateRegion) {
        
        var zoomRegion = region
        zoomRegion.span = normalizeRegionSpan(region.span)
        mapView?.setRegion(zoomRegion, animated: true)
    }
    
    /**
    Zoom the map to show the users current location.
    */
    public func zoomToCurrentLocation() {
        trackingUser = true
        if let mapView = self.mapView {
            zoomToCoordinate(mapView.userLocation.coordinate)
        }
    }
    
    /**
    Zoom the map to show all points plotted on the map.
    
    - parameter includingUser: If `true` then the users annotation is also included in the points. If `false` then only plotted points are zoomed to.
    */
    public func zoomToShowAll(includingUser: Bool = true) {
        
        if includingUser == false || zoomToShowAllIncludesUser == false {
            let annotations = Array(self.annotations.values)
            zoomToAnnotations(annotations)
        } else {
            zoomToAnnotations(offscreenMapView.annotations as [MKAnnotation])
        }
    }
    
    /**
    Zooms the map to an address object.
    
    - parameter address: The address object to zoom to.
    */
    public func zoomToAddress(address: Address) {
        plotAddress(address)
        
        if let annotation = annotations[address] {
            zoomToAnnotations([annotation])
        }
    }
    
    /**
    Zooms the map to a polyline.
    
    - parameter polyline: The polyline to zoom to.
    */
    public func zoomToPolyline(polyline: MKPolyline) {
        zoomToMapPoints(polyline.points(), count: polyline.pointCount)
    }
    
    // MARK: - Polyline and Route Methods
    
    /**
    Removes all the polylines plotted on the map view.
    */
    public func removeAllPolylines() {
        
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
    public func routeBetweenCoordinates(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, transportType: MKDirectionsTransportType = .Automobile, complete: (route: MKRoute?, error: NSError?) -> Void) {
        
        let sourcePlacemark = MKPlacemark(coordinate: source, addressDictionary: nil)
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationPlacemark = MKPlacemark(coordinate: destination, addressDictionary: nil)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        routeBetweenMapItems(sourceItem, destination: destinationItem, transportType: transportType, complete: complete)
    }
    
    /**
     Gets a route between a source and destination.
     
     - parameter source:        The map item of the source location.
     - parameter destination:   The map item of the destination location.
     - parameter transportType: The transportation type to create the route.
     - parameter complete:      Returns an optional route and error.
     */
    public func routeBetweenMapItems(source: MKMapItem, destination: MKMapItem, transportType: MKDirectionsTransportType = .Automobile, complete: (route: MKRoute?, error: NSError?) -> Void) {
        
        let directionsRequest = MKDirectionsRequest()
        directionsRequest.source = source
        directionsRequest.destination = destination
        directionsRequest.transportType = transportType
        directionsRequest.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: directionsRequest)
        NSNotificationCenter.defaultCenter().postNotificationName(NetworkRequestDidBeginNotification, object: nil)
        directions.calculateDirectionsWithCompletionHandler { (directionsResponse, error) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(NetworkRequestDidCompleteNotification, object: nil)
            complete(route: directionsResponse?.routes.first, error: error)
        }
    }
    
    /**
    Gets directions to a coordinate from the users current location.
    
    - parameter coordinate: The coordinate to get directions to.
    - parameter inApp:      If `true` diretions are plotted in-app on the map view. If `false` then the Maps.app is opened with the directions requested.
    */
    public func directionsToCurrentLocationFrom(coordinate coordinate: CLLocationCoordinate2D, inApp: Bool = true) {
        
        let currentLocationItem = MKMapItem.mapItemForCurrentLocation()
        let destinationPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        if inApp == true {
            routeBetweenMapItems(currentLocationItem, destination: destinationItem, complete: { (route, error) -> Void in
                if let anError = error {
                    NSLog("Error getting directions: \(anError.localizedDescription)\n\(anError)")
                } else if let aRoute = route {
                    self.plotRoute(aRoute)
                }
            })
        } else {
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            MKMapItem.openMapsWithItems([currentLocationItem, destinationItem], launchOptions: launchOptions)
        }
    }
    
    /**
    Plots a route as a polyline after removing all previous reotes, and then zoom to display the new route.
    
    - parameter route: The route to plot.
    */
    public func plotRoute(route: MKRoute) {
        mapView?.addOverlay(route.polyline, level: .AboveRoads)
    }
    
    // MARK: - Helper Methods
    
    /**
    Normalizes a regions space with the constants preset.
    
    - parameter span: The span to normalize.
    
    - returns: The normalized span.
    */
    public func normalizeRegionSpan(span: MKCoordinateSpan) -> MKCoordinateSpan {
        
        var normalizedSpan = MKCoordinateSpanMake(span.latitudeDelta * annotationRegionPadFactor, span.longitudeDelta * annotationRegionPadFactor)
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
    
    // MARK: - MKMapViewDelegate Methods
    
    final public func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        return configureAnnotationView(mapView, viewForAnnotation: annotation)
    }
    
    /**
     Called by `mapView:viewForAnnotation:` in the map controller.
     
     - note: Subclass this method to override the default behaviour.
     
     - parameter mapView:    The map view that requested the annotation view.
     - parameter annotation: The object representing the annotation that is about to be displayed. In addition to your custom annotations, this object could be an `MKUserLocation` object representing the user’s current location.
     
     - returns: The annotation view to display for the specified annotation or nil if you want to display a standard annotation view.
     */
    public func configureAnnotationView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationPinView: MKPinAnnotationView?
        if let myAnnotation = annotation as? Annotation {
            if let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                annotationView.annotation = myAnnotation
                annotationPinView = annotationView
            } else {
                let pinView = MKPinAnnotationView(annotation: myAnnotation, reuseIdentifier: identifier)
                if #available(iOSApplicationExtension 9.0, *) {
                    pinView.pinTintColor = MKPinAnnotationView.redPinColor()
                } else {
                    pinView.pinColor = .Red
                }
                pinView.animatesDrop = false
                pinView.hidden = false
                pinView.enabled = true
                pinView.canShowCallout = true
                pinView.draggable = false
                pinView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
                annotationPinView = pinView
            }
        }
        
        return annotationPinView
    }
    
    final public func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        return calloutAccessoryControlTapped(mapView, annotationView: view, controlTapped: control)
    }
    
    /**
     Called by `mapView:annotationView:calloutAccessoryControlTapped:` in the map controller.
     
     - note: Subclass this method to override the default behaviour.
     
     - parameter mapView: The map view containing the specified annotation view.
     - parameter view:    The annotation view whose button was tapped.
     - parameter control: The control that was tapped.
     */
    public func calloutAccessoryControlTapped(mapView: MKMapView, annotationView view: MKAnnotationView, controlTapped control: UIControl) {
        if let annotation = view.annotation as? Annotation {
            
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
    
    final public func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        return configureOverlayRenderer(mapView, overlay: overlay)
    }
    
    /**
     Called by `mapView:rendererForOverlay:` in the map controller.
     
     - note: Subclass this method to override the default behaviour.
     
     - parameter mapView: The map view that requested the renderer object.
     - parameter overlay: The overlay object that is about to be displayed.
     
     - returns: The renderer to use when presenting the specified overlay on the map. If you return `nil`, no content is drawn for the specified overlay object.
     */
    public func configureOverlayRenderer(mapView: MKMapView, overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let polylineRenderer = MKPolylineRenderer(polyline: polyline)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 4
            polylineRenderer.lineCap = .Round
            polylineRenderer.lineJoin = .Round
            polylineRenderer.alpha = 0.6
            return polylineRenderer
        }
        return MKOverlayRenderer()
    }
    
    public func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateVisableAnnotations()
    }
    
    public func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if hasPlottedInitUsersLocation == false {
            hasPlottedInitUsersLocation = true
            zoomToShowAll()
        }
    }
    
    public func mapView(mapView: MKMapView, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
        switch mode {
        case .None:
            trackingUser = false
        case .Follow, .FollowWithHeading:
            trackingUser = true
        }
    }
    
    public func mapView(mapView: MKMapView, didFailToLocateUserWithError error: NSError) {
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
    
    // MARL: - CLLocationManagerDelegate Methods
    
    public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        // Set the location manager to nil if not `NotDetermined`. If `NotDetermined` then it is possible the delegate was called before the user has answered.
        if status != .NotDetermined {
            self.locationManager = nil
        }
    }
    
    // MARK: - Search Methods
    
    /**
    Performs a predicate search on the addresses dictionary that begins with the search string.
    
    - parameter searchString: The string to search the addresses by name or simple address.
    
    - returns: An array of addresses that meet the predicate search criteria.
    */
    public func searchAddresses(searchString: String) -> [Address] {
        let predicate = NSPredicate(format: "name beginswith[cd] %@ || addressString beginswith[cd] %@", searchString, searchString)
        return (addresses as NSArray).filteredArrayUsingPredicate(predicate) as! [Address]
    }
    
}
