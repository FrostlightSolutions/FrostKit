//
//  ScreenExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 06/04/2015.
//  Copyright © 2015 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

extension UIScreen {
    
    /// Returns a half point depnding on the scale of the screen size. If the scale is 2.0 or above then `0.5` is returned. Otherwise `1` is returned.
    public var halfPoint: CGFloat {
        if scale > 1 {
            return 0.5
        }
        return 1
    }
    
}
