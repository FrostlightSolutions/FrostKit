//
//  DataExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright © 2014 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation

///
/// Extention functions for NSData
///
extension Data {
    
    /// Returns a string of the hex data object.
    public var hexString: String {
        
        var string = ""
        
        for byte in enumerated() {
            string += String(format: "%02hhx", byte.element)
        }
        
        return string
    }
    
}
