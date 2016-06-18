//
//  Annotation.swift
//  FrostKit
//
//  Created by James Barrow on 13/04/2016.
//  Copyright © 2016-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit
import MapKit

///
/// An annotation object that is to be used with an address object.
///
public class Annotation: NSObject, MKAnnotation {
    
    /// The address object for the annotation.
    public var address: Address?
    /// The coordinate of the address.
    public var coordinate: CLLocationCoordinate2D {
        return address?.coordinate ?? CLLocationCoordinate2D()
    }
    /// The name of the address.
    public var title: String? {
        if let containdedAnnotations = self.containdedAnnotations where containdedAnnotations.count > 0 {
            let tense: String
            if containdedAnnotations.count == 1 {
                tense = FKLocalizedString(key: "ITEM", comment: "Item")
            } else {
                tense = FKLocalizedString(key: "ITEMS", comment: "Items")
            }
            return "\(containdedAnnotations.count) \(tense)"
        }
        return address?.name
    }
    /// The address string of the address.
    public var subtitle: String? {
        if let containdedAnnotations = self.containdedAnnotations where containdedAnnotations.count > 0 {
            return ""
        }
        return address?.addressString
    }
    // If the annotation is a clustered annotation, this value holds all the annotations it represents.
    public var containdedAnnotations: [Annotation]? {
        didSet {
            if containdedAnnotations != nil {
                clusterAnnotation = nil
            }
        }
    }
    // If the annotation is part of a clustered annotation, this represent the visable annotation.
    public var clusterAnnotation: Annotation? {
        didSet {
            if clusterAnnotation != nil {
                containdedAnnotations = nil
            }
        }
    }
    
    public override init() {
        super.init()
    }
    
    /**
     A convenience method for making an annotation object from an address object.
     
     - parameter address: The address object to base the annotation off of.
     */
    public convenience init(address: Address) {
        self.init()
        
        self.address = address
    }
    
    /**
     Updates the annotation with an address.
     
     - parameter address: The address to update the annotation with.
     */
    public func update(address: Address) {
        if self.address != address {
            self.address = address
        }
    }
    
}
