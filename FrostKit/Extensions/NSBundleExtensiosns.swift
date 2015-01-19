//
//  NSBundleExtensiosns.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import Foundation

///
/// Extention functions for NSBundle
///
extension NSBundle {
    
    /**
        Returns the bundle version of the app as a string.
    
        :returns: The bundle version of the app.
    */
    public class func appVersion(bundle: NSBundle = NSBundle.mainBundle()) -> String {
        return bundle.objectForInfoDictionaryKey("CFBundleVersion") as String
    }
    
    /**
        Returns the version of the app as a string.
        
        :returns: The version of the app.
    */
    public class func appName(bundle: NSBundle = NSBundle.mainBundle()) -> String {
        return bundle.objectForInfoDictionaryKey("CFBundleName") as String
    }
    
}
