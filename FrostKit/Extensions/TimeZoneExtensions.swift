//
//  TimeZoneExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright © 2014-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation

///
/// Extention functions for TimeZone
///
extension TimeZone {
    
    /**
    A helper method to get the UTC time zone.
    
    - returns: A UTC time zone object.
    */
    public class func utc() -> TimeZone {
        return TimeZone(name: "UTC")!
    }
    
}
