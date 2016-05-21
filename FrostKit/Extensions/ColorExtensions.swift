//
//  ColorExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

#if os(OSX)
import AppKit
#else
import UIKit
#endif

///
/// Extention functions for UIColor & NSColor
///
extension Color {
    
#if os(iOS) || os(watchOS) || os(tvOS)
    /**
    A convenience init for creating a color object from a hex string.
    
    - parameter hexString:  A hex string to turn into a color object.
    - parameter alpha:      The alpha value of the color.
    */
    public convenience init(hexString: String, alpha: CGFloat = 1) {
        let color = Color.color(withHexString: hexString, alpha: alpha)
        self.init(cgColor: color.cgColor)
    }
#endif
    
    /**
    Creates a color object from a hex string.
    
    - parameter hexString:  A hex string to turn into a color object.
    - parameter alpha:      The alpha value of the color.
    
    - returns: A color object from the hex string.
    */
    public class func color(withHexString hexString: String, alpha: CGFloat = 1) -> Color {
        
        var scanLocation = 0
        if hexString.hasPrefix("#") {
            scanLocation = 1
        }
        
        var rgbValue: UInt32 = 0
        let scanner = NSScanner(string: hexString)
        scanner.scanLocation = scanLocation
        scanner.scanHexInt32(&rgbValue)
        
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
            return Color.clear()
        }
        
        return Color(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgbValue & 0x00FF00) >> 8)  / 255.0, blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: alpha)
    }
    
    /**
     Created a new UIColor/NSColor object from the object called from with a new alpha value.
     
     - parameter alpha: The alpha value of the new UIColor/NSColor object created.
     
     - returns: The new UIColor/NSColor object created with the passed in alpha value.
     */
    public func color(withAlpha alpha: CGFloat) -> Color {
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        return Color(red: red, green: green, blue: blue, alpha: alpha)
    }
}
