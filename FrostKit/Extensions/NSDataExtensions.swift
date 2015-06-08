//
//  NSDataExtensions.swift
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
    
    /**
    Returns a string of the hex data object.
    
    - returns: Hex string of the data.
    */
    public func hexString() -> NSString {
        let string = NSMutableString(capacity: self.length)
        let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer(self.bytes), count:self.length)
        for byte in bytes {
            string.appendFormat("%02hhx", byte)
        }
        return string
    }
    
    /**
    Creates a formatted string from the `size` passed in in bytes.
    
    - parameter size: The size of the item in bytes.
    
    - returns: A formatted string of the size passed in. E.g. 1024 bytes returns 1MB.
    */
    public class func sizeFormattedString(size: Int) -> String {
        
        let sUnits = ["\0", "K", "M", "G", "T", "P", "E", "Z", "Y"]
        let sMaxUnits = sUnits.count - 1
        
        let multiplier = 1024.0
        var exponent = 0
        
        var bytes = Double(size)
        
        while bytes >= multiplier && exponent < sMaxUnits {
            bytes /= multiplier
            exponent++
        }
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        
        if let stringSize = numberFormatter.stringFromNumber(NSNumber(double: bytes)) {
            return NSString(format: "%@ %@B", stringSize, sUnits[exponent]) as String
        } else {
            return "Unknown"
        }
    }
    
    /// Created a formatted string from the objects length value
    public var lengthFormattedString: String {
        return NSData.sizeFormattedString(self.length)
    }
    
}
