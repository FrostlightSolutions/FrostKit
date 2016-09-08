//
//  UIImageExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

///
/// Extention functions for UIImage
///
extension UIImage {
    
    /**
    Scales down an image and returns a new image scaled to that max size.
    
    - parameter size:    The maximum size of the scaled image.
    
    - returns: A scaled image.
    */
    public func imageWithMaxSize(size: CGSize) -> UIImage? {
        
        let size = CGSizeApplyAffineTransform(self.size, CGAffineTransformMakeScale(0.5, 0.5))
        let hasAlpha = false
        
        var scaledSize = size
        if size.width > size.height {
            
            // Landscape
            let scale = size.height/size.width
            scaledSize.height *= scale
            
        } else if size.height > size.width {
            
            // Portrait
            let scale = size.width/size.height
            scaledSize.width *= scale
        }
        
        UIGraphicsBeginImageContextWithOptions(scaledSize, !hasAlpha, 0.0)
        self.drawInRect(CGRect(origin: CGPointZero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }

}
