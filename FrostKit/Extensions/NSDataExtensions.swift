//
//  NSDataExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import Foundation

extension NSData {
    
    func hexString() -> NSString {
        var string = NSMutableString(capacity: self.length)
        let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer(self.bytes), count:self.length)
        for byte in bytes {
            string.appendFormat("%02hhx", byte)
        }
        return string
    }
    
}
