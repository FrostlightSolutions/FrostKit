//
//  View.swift
//  FrostKit
//
//  Created by James Barrow on 12/02/2015.
//  Copyright © 2015 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

open class View: UIView {
    
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
        }
    }
    
}
