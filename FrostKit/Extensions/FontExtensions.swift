//
//  FontExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 02/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

///
/// Extention functions for UIFont
///
extension UIFont {
    
    /**
    Helper method for getting font awesome font of a size.
    
    - parameter size:    The size of the font to return.
    
    - returns: The font object for font awesome.
    */
    public class func fontAwesome(size size: CGFloat) -> UIFont {
        if let font = UIFont(name: "FontAwesome", size: size) {
            return font
        } else {
            NSLog("ERROR: Unable to load FontAwesome font.")
            return UIFont.systemFontOfSize(size)
        }
    }
    
    /**
    Helper method for getting font ionicons of a size.
    
    - parameter size:    The size of the font to return.
    
    - returns: The font object for ionicons.
    */
    public class func ionicons(size size: CGFloat) -> UIFont {
        if let font = UIFont(name: "Ionicons", size: size) {
            return font
        } else {
            NSLog("ERROR: Unable to load Ionicons font.")
            return UIFont.systemFontOfSize(size)
        }
    }
    
}