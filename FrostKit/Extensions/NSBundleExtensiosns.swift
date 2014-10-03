//
//  NSBundleExtensiosns.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import Foundation

extension NSBundle {
    
    public class func appVersion(bundle: NSBundle = NSBundle.mainBundle()) -> String {
        return bundle.objectForInfoDictionaryKey("CFBundleVersion") as String
    }
    
    public class func appName(bundle: NSBundle = NSBundle.mainBundle()) -> String {
        return bundle.objectForInfoDictionaryKey("CFBundleName") as String
    }
    
}
