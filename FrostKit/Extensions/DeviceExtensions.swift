//
//  DeviceExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 26/01/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit

///
/// Extention functions for UIDevice
///
extension UIDevice {
    
    /**
    *  Gets the system version in it's major, minor or path parts or in full.
    */
    struct SystemVersion {
        /// The full system version.
        static let version = UIDevice.currentDevice().systemVersion
        private static let versionComponents = version.componentsSeparatedByString(".")
        /// The major system version.
        static var majorVersion: Int {
            return UIDevice.systemVersionAtIndex(.Major, components: versionComponents)
        }
        /// The minor system version.
        static var minorVersion: Int {
            return UIDevice.systemVersionAtIndex(.Minor, components: versionComponents)
        }
        /// The minor path version.
        static var pathVersion: Int {
            return UIDevice.systemVersionAtIndex(.Bug, components: versionComponents)
        }
    }
    
    private enum VersionIndex: Int {
        case Major = 0
        case Minor
        case Bug
    }
    
    private class func systemVersionAtIndex(index: VersionIndex, components: [String]) -> Int {
        if let version = Int(components[index.rawValue]) where components.count > index.rawValue {
            return version
        }
        return NSNotFound
    }
    
}
