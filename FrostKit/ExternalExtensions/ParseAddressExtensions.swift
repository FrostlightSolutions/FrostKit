//
//  AddressExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 07/02/2015.
//  Copyright © 2015-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit
import FrostKit
import Parse

///
/// Extention functions for NSError
/// 
/// This is an external extension. That means it is for a 3rd party framework not included by default in FrostKit.
/// This file is to be included directly into any projec that uses the Parse SDK.
///
extension Address {
    
    /**
    A convenience method that allows creating an address object using PFGeoPoint and PFObject as reference.
    
    - parameter geoPoint:         The PFGeoPoint to get the locational data from.
    - parameter object:           The PFObject to get the main data from.
    - parameter nameKey:          The key for the name string in the PFObject.
    - parameter addressStringKey: The key for the simple address string in the PFObject.
    */
    public convenience init(geoPoint: PFGeoPoint, object: PFObject, nameKey: String? = nil, addressStringKey: String? = nil) {
        self.init()
        
        objectID = object.objectId
        coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude)
        
        if let key = nameKey {
            if let name = object.objectForKey(key) as? String {
                self.name = name
            }
        }
        
        if let key = addressStringKey {
            if let addressString = object.objectForKey(key) as? String {
                self.addressString = addressString
            }
        }
    }
    
}
