//
//  NSTimeZoneExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import Foundation

extension NSTimeZone {
    
    public class func utc() -> NSTimeZone {
        return NSTimeZone(name: "UTC")!
    }
    
}
