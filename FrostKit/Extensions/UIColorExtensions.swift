//
//  UIColorExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit

extension UIColor {
    
    public class func colorWithHex(hexString: String) -> UIColor {
        
        var scanLocation = 0
        if hexString.hasPrefix("#") {
            scanLocation = 1
        }
        
        var rgbValue: CUnsignedInt = 0
        let scanner = NSScanner(string: hexString)
        scanner.scanLocation = scanLocation
        scanner.scanHexInt(&rgbValue)
        if countElements(hexString) - scanLocation == 3 {
            // Normalize
            rgbValue = (rgbValue << 8) & 0x0F0000 | (rgbValue << 4) & 0x000F00 | rgbValue & 0x00000F
            // Copy every element and move it 4 bits left
            rgbValue = rgbValue | (rgbValue << 4)
        }
        return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgbValue & 0x00FF00) >> 8)  / 255.0, blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: 1.0)
    }
}
