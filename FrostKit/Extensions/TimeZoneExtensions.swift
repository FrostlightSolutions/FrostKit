//
//  TimeZoneExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright © 2014 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation

///
/// Extention functions for TimeZone
///
extension TimeZone {
    
    /// A`TimeZone` using the `UTC` identifier.
    public static let utc: TimeZone = TimeZone(identifier: "UTC")!
}
