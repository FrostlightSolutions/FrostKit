//
//  NSErrorExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import Foundation

extension NSError {
    
    public class func errorWithMessage(message: String) -> NSError {
        return NSError.errorWithDomain(NSBundle.mainBundle().bundleIdentifier!, code: -1, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
