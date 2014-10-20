//
//  UIFontExtensiosns.swift
//  FrostKit
//
//  Created by James Barrow on 02/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit

extension UIFont {
    
    public class func fontAwesome(#size: CGFloat) -> UIFont {
        if let font = UIFont(name: "FontAwesome", size: size) {
            return font
        } else {
            println("ERROR: Unable to load FontAwesome font.")
            return UIFont.systemFontOfSize(size)
        }
    }
    
    public class func ionicons(#size: CGFloat) -> UIFont {
        if let font = UIFont(name: "Ionicons", size: size) {
            return font
        } else {
            println("ERROR: Unable to load Ionicons font.")
            return UIFont.systemFontOfSize(size)
        }
    }
    
}
