//
//  AddressExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 07/02/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit
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
    
    :param: geoPoint         The PFGeoPoint to get the locational data from.
    :param: object           The PFObject to get the main data from.
    :param: nameKey          The key for the name string in the PFObject.
    :param: addressStringKey The key for the simple address string in the PFObject.
    */
    public convenience init(geoPoint: PFGeoPoint, object: PFObject, nameKey: String? = nil, addressStringKey: String? = nil) {
        self.init()
        
        objectID = parseObject.objectId
        coordinate = CLLocationCoordinate2DMake(parseGeoPoint.latitude, parseGeoPoint.longitude)
        
        if let key = nameKey {
            if let name = parseObject.objectForKey(key) as? String {
                self.name = name
            }
        }
        
        if let key = addressStringKey {
            if let addressString = parseObject.objectForKey(key) as? String {
                self.addressString = addressString
            }
        }
    }
    
}
