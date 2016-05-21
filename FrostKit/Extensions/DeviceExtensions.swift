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
        static let version = UIDevice.current().systemVersion
        private static let versionComponents = version.components(separatedBy: ".")
        /// The major system version.
        static var majorVersion: Int {
            return UIDevice.systemVersion(atIndex: .major, components: versionComponents)
        }
        /// The minor system version.
        static var minorVersion: Int {
            return UIDevice.systemVersion(atIndex: .minor, components: versionComponents)
        }
        /// The minor path version.
        static var bugFixVersion: Int {
            return UIDevice.systemVersion(atIndex: .bugFix, components: versionComponents)
        }
    }
    
    private enum VersionIndex: Int {
        case major = 0
        case minor
        case bugFix
    }
    
    private class func systemVersion(atIndex index: VersionIndex, components: [String]) -> Int {
        if let version = Int(components[index.rawValue]) where components.count > index.rawValue {
            return version
        }
        return NSNotFound
    }
    
}
