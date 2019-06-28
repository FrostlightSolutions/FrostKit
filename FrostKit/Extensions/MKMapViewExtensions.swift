//
//  MKMapViewExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 2019-06-28.
//  Copyright © 2019 James Barrow - Frostlight Solutions. All rights reserved.
//

import MapKit

public extension MKMapView {
    
    private static let minimumZoomArc = 0.007  //approximately 1/2 mile (1 degree of arc ~= 69 miles)
    private static let maximumDegreesArc: Double = 360
    private static let annotationRegionPadFactor: Double = 1.15
    
    // MARK: - Zoom Map Methods
    
    /// Zoom the map view to a coordinate.
    /// - Parameter coordinare: The coordinate to zoom to.
    func zoom(toCoordinate coordinare: CLLocationCoordinate2D) {
        
        let point = MKMapPoint(coordinare)
        zoom(toMapPoints: [point])
    }
    
    /// Zoom the map view to an annotation.
    /// - parameter annotation: The annotation to zoom to.
    func zoom(toAnnotation annotation: MKAnnotation) {
        zoom(toAnnotations: [annotation])
    }
    
    /// Zoom the map to show multiple annotations.
    /// - parameter annotations: The annotations to zoom to.
    func zoom(toAnnotations annotations: [MKAnnotation]) {
        
        let count = annotations.count
        if count > 0 {
            var points = [MKMapPoint]()
            for annotation in annotations {
                points.append(MKMapPoint(annotation.coordinate))
            }
            zoom(toMapPoints: points)
        }
    }
    
    /// Zoom the map to show multiple map points.
    /// - Parameter points: Swift array of `MKMapPoints` to zoom to.
    func zoom(toMapPoints points: [MKMapPoint]) {
        
        let count = points.count
        let cPoints = UnsafeMutablePointer<MKMapPoint>.allocate(capacity: count)
        cPoints.initialize(from: points, count: count)
        zoom(toMapPoints: cPoints, count: count)
        cPoints.deinitialize(count: count)
    }
    
    /// Zoom the map to show multiple map points.
    /// - Parameter points: C array array of `MKMapPoints` to zoom to.
    /// - Parameter count: The number of points in the C array.
    func zoom(toMapPoints points: UnsafeMutablePointer<MKMapPoint>, count: Int) {
        
        let mapRect = MKPolygon(points: points, count: count).boundingMapRect
        var region: MKCoordinateRegion = MKCoordinateRegion(mapRect)
        
        if count <= 1 {
            region.span = MKCoordinateSpan(latitudeDelta: MKMapView.minimumZoomArc, longitudeDelta: MKMapView.minimumZoomArc)
        }
        
        zoom(toRegion: region)
    }
    
    /// Zoom the map to show a region.
    /// - Parameter region: The region to zoom the map to.
    func zoom(toRegion region: MKCoordinateRegion) {
        
        var zoomRegion = region
        zoomRegion.span = normalize(regionSpan: region.span)
        setRegion(zoomRegion, animated: true)
    }
    
    /// Zoom the map to show the users current location.
    func zoomToCurrentLocation() {
        zoom(toCoordinate: userLocation.coordinate)
    }
    
    /// Zoom the map to show all points plotted on the map.
    /// - Parameter includingUser: If `true` then the users annotation is also included in the points. If `false` then only plotted points are zoomed to.
    func zoomToShowAll(includingUser: Bool = true) {
        
        if includingUser == false {
            
            let annotations = self.annotations.filter({ ($0 is MKUserLocation) == false })
            zoom(toAnnotations: annotations)
            
        } else {
            zoom(toAnnotations: annotations)
        }
    }
    
    /// Zooms the map to a polyline.
    /// - Parameter polyline: The polyline to zoom to.
    func zoom(toPolyline polyline: MKPolyline) {
        zoom(toMapPoints: polyline.points(), count: polyline.pointCount)
    }
    
    // MARK: - Polyline and Route Methods
    
    /// Removes all the polylines plotted on the map view.
    func removeAllPolylines() {
        
        for overlay in overlays {
            if let polyline = overlay as? MKPolyline {
                removeOverlay(polyline)
            }
        }
    }
    
    /// Gets a route between a source and destination.
    /// - Parameter source: The coordinate of the source location.
    /// - Parameter destination: The coordinate of the destination location.
    /// - Parameter automobile: The transportation type to create the route.
    /// - Parameter error: Returns an optional route and error.
    func routeBetween(sourceCoordinate source: CLLocationCoordinate2D, destinationCoordinate destination: CLLocationCoordinate2D, transportType: MKDirectionsTransportType = .automobile, complete: @escaping (Result<MKRoute?, Error>) -> Void) {
        
        let sourcePlacemark = MKPlacemark(coordinate: source, addressDictionary: nil)
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationPlacemark = MKPlacemark(coordinate: destination, addressDictionary: nil)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        routeBetween(sourceMapItem: sourceItem, destinationMapItem: destinationItem, transportType: transportType, complete: complete)
    }
    
    /// Gets a route between a source and destination.
    /// - Parameter source: The map item of the source location.
    /// - Parameter destination: The map item of the destination location.
    /// - Parameter automobile: The transportation type to create the route.
    /// - Parameter error: Returns an optional route and error.
    func routeBetween(sourceMapItem source: MKMapItem, destinationMapItem destination: MKMapItem, transportType: MKDirectionsTransportType = .automobile, complete: @escaping (Result<MKRoute?, Error>) -> Void) {
        
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = source
        directionsRequest.destination = destination
        directionsRequest.transportType = transportType
        directionsRequest.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: directionsRequest)
        directions.calculate { (directionsResponse, error) in
            
            if let error = error {
                complete(Result.failure(error))
            } else {
                complete(Result.success(directionsResponse?.routes.first))
            }
        }
    }
    
    /// Gets directions to a coordinate from the users current location.
    /// - Parameter coordinate: The coordinate to get directions to.
    /// - Parameter inApp: If `true` diretions are plotted in-app on the map view. If `false` then the Maps.app is opened with the directions requested.
    func directionsToCurrentLocation(fromCoordinate coordinate: CLLocationCoordinate2D, inApp: Bool = true) {
        
        let currentLocationItem = MKMapItem.forCurrentLocation()
        let destinationPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        if inApp == true {
            routeBetween(sourceMapItem: currentLocationItem, destinationMapItem: destinationItem, complete: { result in
                
                switch result {
                case .failure(let error):
                    DLog("Error getting directions: \(error.localizedDescription)")
                case .success(let route):
                    if let route = route {
                        self.plot(route: route)
                    }
                }
            })
        } else {
#if os(iOS) || os(OSX)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            MKMapItem.openMaps(with: [currentLocationItem, destinationItem], launchOptions: launchOptions)
#endif
        }
    }
    
    /// Plots a route as a polyline after removing all previous reotes, and then zoom to display the new route.
    /// - Parameter route: The route to plot.
    func plot(route: MKRoute) {
        addOverlay(route.polyline, level: .aboveRoads)
    }
    
    // MARK: - Helper Methods
    
    /// Normalizes a regions space with the constants preset.
    /// - Parameter span: The span to normalize.
    func normalize(regionSpan span: MKCoordinateSpan) -> MKCoordinateSpan {
        
        var normalizedSpan = MKCoordinateSpan(latitudeDelta: span.latitudeDelta * MKMapView.annotationRegionPadFactor, longitudeDelta: span.longitudeDelta * MKMapView.annotationRegionPadFactor)
        if normalizedSpan.latitudeDelta > MKMapView.maximumDegreesArc {
            normalizedSpan.latitudeDelta = MKMapView.maximumDegreesArc
        } else if normalizedSpan.latitudeDelta < MKMapView.minimumZoomArc {
            normalizedSpan.latitudeDelta = MKMapView.minimumZoomArc
        }
        
        if normalizedSpan.longitudeDelta > MKMapView.maximumDegreesArc {
            normalizedSpan.longitudeDelta = MKMapView.maximumDegreesArc
        } else if normalizedSpan.longitudeDelta < MKMapView.minimumZoomArc {
            normalizedSpan.longitudeDelta = MKMapView.minimumZoomArc
        }
        return normalizedSpan
    }
    
    /// Deselects any showing annotation view callout on the map.
    func deselectAllAnnotations() {
        
        for selectedAnnotation in selectedAnnotations {
            deselectAnnotation(selectedAnnotation, animated: true)
        }
    }
    
}
