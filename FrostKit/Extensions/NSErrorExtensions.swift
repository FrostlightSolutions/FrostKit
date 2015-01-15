//
//  NSErrorExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import Foundation

///
/// Extention functions for NSError
///
extension NSError {
    
    /**
        A helper method for creating error objects from a message string.
    
        :param: message     The string to have as the localized description in the created error object.
    
        :returns: An error object with the message as a localized description.
    */
    public class func errorWithMessage(message: String) -> NSError {
        return NSError(domain: NSBundle.mainBundle().bundleIdentifier!, code: -1, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
