//
//  UIDeviceExtensions.swift
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
            return UIDevice.systemVersionAtIndex(0, components: versionComponents)
        }
        /// The minor system version.
        static var minorVersion: Int {
            return UIDevice.systemVersionAtIndex(1, components: versionComponents)
        }
        /// The minor path version.
        static var pathVersion: Int {
            return UIDevice.systemVersionAtIndex(2, components: versionComponents)
        }
    }
    
    private class func systemVersionAtIndex(index: Int, components: [String]) -> Int {
        if let version = components[index].toInt() where components.count > index {
            return version
        }
        return NSNotFound
    }
    
}
