//
//  UIViewExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

///
/// Extention functions for UIView
///
extension UIView {
    
    /**
        Returns a screen shot of the view.
    
        :returns: A screen shot of the view.
    */
    public func screenshot() -> UIImage {
        
        var scale: CGFloat = 2.0
        if let window = self.window {
            scale = window.screen.scale
        } else {
            scale = UIScreen.mainScreen().scale
        }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
        drawViewHierarchyInRect(bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image
    }
    
}
