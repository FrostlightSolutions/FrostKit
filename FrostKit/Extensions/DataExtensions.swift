//
//  DataExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation

///
/// Extention functions for NSData
///
extension NSData {
    
    /// Returns a string of the hex data object.
    public var hexString: String {
        
        var string = ""
        var byte: UInt8 = 0
        
        for index in 0 ..< length {
            getBytes(&byte, range: NSRange(location: index, length: 1))
            string += String(format: "%02hhx", byte)
        }
        
        return string
    }
    
    /**
    Creates a formatted string from the `size` passed in in bytes.
    
    - parameter size: The size of the item in bytes.
    
    - returns: A formatted string of the size passed in. E.g. 1024 bytes returns 1MB.
    */
    
    // TODO: Change to using generics rahter than just `Int64`.
    public class func sizeFormattedString(size: Int64) -> String {
        
        let sUnits = ["", "K", "M", "G", "T", "P", "E"]
        let sMaxUnits = sUnits.count - 1
        
        let multiplier = 1024.0
        var exponent = 0
        
        var bytes = Double(size)
        
        while bytes >= multiplier && exponent < sMaxUnits {
            bytes /= multiplier
            exponent += 1
        }
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        let stringSize = numberFormatter.string(from: NSNumber(value: bytes))!
        return "\(stringSize) \(sUnits[exponent])B"
    }
    
    /// Created a formatted string from the objects length value
    public var lengthFormattedString: String {
        return NSData.sizeFormattedString(size: Int64(self.length))
    }
    
}
