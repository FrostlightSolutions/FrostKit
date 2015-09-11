//
//  UIColorExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

///
/// Extention functions for UIColor
///
extension UIColor {
    
    /**
    A convenience init for creating a color object from a hex string.
    
    - parameter hexString:   A hex string to turn into a color object.
    
    - returns: A color object from the hex string.
    */
    public convenience init?(hexString: String, alpha: CGFloat = 1) {
        let color = UIColor.colorWithHex(hexString, alpha: alpha)
        self.init(CGColor: color.CGColor)
    }
    
    /**
    Creates a color object from a hex string.
    
    - parameter hexString:   A hex string to turn into a color object.
    
    - returns: A color object from the hex string.
    */
    public class func colorWithHex(hexString: String, alpha: CGFloat = 1) -> UIColor {
        
        var scanLocation = 0
        if hexString.hasPrefix("#") {
            scanLocation = 1
        }
        
        var rgbValue: CUnsignedInt = 0
        let scanner = NSScanner(string: hexString)
        scanner.scanLocation = scanLocation
        scanner.scanHexInt(&rgbValue)
        
        switch hexString.characters.count - scanLocation {
        case 3:
            // Normalize
            rgbValue = (rgbValue << 8) & 0x0F0000 | (rgbValue << 4) & 0x000F00 | rgbValue & 0x00000F
            // Copy every element and move it 4 bits left
            rgbValue = rgbValue | (rgbValue << 4)
        case 6:
            // Default parsed value
            break
        default:
            NSLog("Error: Can't parse color with hex: \(hexString)")
            return UIColor.clearColor()
        }
        
        return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgbValue & 0x00FF00) >> 8)  / 255.0, blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: alpha)
    }
}
