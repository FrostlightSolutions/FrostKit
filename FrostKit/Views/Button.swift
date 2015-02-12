//
//  Button.swift
//  FrostKit
//
//  Created by James Barrow on 12/02/2015.
//  Copyright (c) 2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

@IBDesignable
public class Button: UIButton {

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
