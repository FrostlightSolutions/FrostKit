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
    
    struct SystemVersion {
        static let version = UIDevice.currentDevice().systemVersion
        private static let versionComponents = version.componentsSeparatedByString(".")
        static var majorVersion: Int {
            return UIDevice.systemVersionAtIndex(0, components: versionComponents)
        }
        static var minorVersion: Int {
            return UIDevice.systemVersionAtIndex(1, components: versionComponents)
        }
        static var pathVersion: Int {
            return UIDevice.systemVersionAtIndex(2, components: versionComponents)
        }
    }
    
    private class func systemVersionAtIndex(index: Int, components: [String]) -> Int {
        if components.count > index {
            if let version = components[index].toInt() {
                return version
            }
        }
        return NSNotFound
    }
    
}
