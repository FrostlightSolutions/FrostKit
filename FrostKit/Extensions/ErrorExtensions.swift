//
//  ErrorExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright © 2014 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation

///
/// Extention functions for Error
///
extension Error {
    
    /**
     A helper method for creating error objects from a message string.
     
     - parameter message: The string to have as the localized description in the created error object.
     
     - returns: An error object with the message as a localized description.
     */
    public static func error(withMessage message: String) -> Error {
        return NSError(domain: Bundle.main.bundleIdentifier ?? "", code: -1, userInfo: [NSLocalizedDescriptionKey: message]) as Error
    }
}
