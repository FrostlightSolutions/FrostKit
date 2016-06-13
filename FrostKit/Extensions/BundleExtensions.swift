//
//  BundleExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation

///
/// Extention functions for NSBundle
///
extension Bundle {
    
    /**
     Returns the bundle version of the app as a string.
     
     - parameter bundle: The bundle to get the app version from. Defaults to `mainBundle()`.
     
     - returns: The bundle version of the app.
     */
    public class func appVersion(bundle: Bundle = Bundle.main()) -> String {
        return bundle.objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    }
    
    /**
     Returns the build number of the app as a string.
     
     - parameter bundle: The bundle to get the build number from. Defaults to `mainBundle()`.
     
     - returns: The build number of the app.
     */
    public class func appBuildNumber(bundle: Bundle = Bundle.main()) -> String {
        return bundle.objectForInfoDictionaryKey("CFBundleVersion") as! String
    }
    
    /**
     Returns the version of the app as a string.
     
     - parameter bundle: The bundle to get the app name from. Defaults to `mainBundle()`.
     
     - returns: The version of the app.
     */
    public class func appName(bundle: Bundle = Bundle.main()) -> String {
        return bundle.objectForInfoDictionaryKey("CFBundleName") as! String
    }
    
}
