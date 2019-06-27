//
//  Button.swift
//  FrostKit
//
//  Created by James Barrow on 12/02/2015.
//  Copyright © 2015 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

@IBDesignable
open class Button: UIButton {
    
    @IBInspectable public var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
        }
    }
    
    @available(iOSApplicationExtension 13.0, *)
    public var cornerCurve: CALayerCornerCurve {
        get { layer.cornerCurve }
        set { layer.cornerCurve = newValue }
    }
    
}
