//
//  NSCalendarExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit

extension NSCalendar {
    
    public class func gregorianCalendar() -> NSCalendar {
        return NSCalendar(calendarIdentifier: NSGregorianCalendar)
    }
    
}
