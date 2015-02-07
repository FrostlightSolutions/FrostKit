//
//  NSTimeZoneExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014-2015 Frostlight Solutions. All rights reserved.
//

import Foundation

///
/// Extention functions for NSTimeZone
///
extension NSTimeZone {
    
    /**
        A helper method to get the UTC time zone.
        
        :returns: A UTC time zone object.
    */
    public class func utc() -> NSTimeZone {
        return NSTimeZone(name: "UTC")!
    }
    
}
