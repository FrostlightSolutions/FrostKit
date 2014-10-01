//
//  NSBundleExtensiosns.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import Foundation

extension NSBundle {
    
    public class func appVersion() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as String
    }
    
    public class func appName() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as String
    }
    
}
