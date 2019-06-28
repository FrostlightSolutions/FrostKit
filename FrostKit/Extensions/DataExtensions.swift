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
    
    /**
    Creates a formatted string from the `size` passed in in bytes.
     
    - parameter size: The size of the item in bytes.
     
    - returns: A formatted string of the size passed in. E.g. 1024 bytes returns 1MB.
    */
    @available(iOS, deprecated: 6.0, message: "Use ByteCountFormatter instead. This class will be removed in v2.0.0 of FrostKit.")
    public static func sizeFormattedString(_ size: Int64) -> String {
        
        let sUnits = ["", "K", "M", "G", "T", "P", "E"]
        let sMaxUnits = sUnits.count - 1
        
        let multiplier = 1024.0
        var exponent = 0
        
        var bytes = Double(size)
        
        while bytes >= multiplier && exponent < sMaxUnits {
            bytes /= multiplier
            exponent += 1
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        let stringSize = numberFormatter.string(from: NSNumber(value: bytes))!
        return "\(stringSize) \(sUnits[exponent])B"
    }
    
    /// Created a formatted string from the objects length value
    @available(iOS, deprecated: 6.0, message: "Use ByteCountFormatter instead. This class will be removed in v2.0.0 of FrostKit.")
    public var lengthFormattedString: String {
        return Data.sizeFormattedString(Int64(count))
    }
}
