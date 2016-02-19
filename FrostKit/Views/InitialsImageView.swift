//
//  InitialsImageView.swift
//  FrostKit
//
//  Created by James Barrow on 12/02/2015.
//  Copyright (c) 2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

public class InitialsImageView: ImageView {
    
    @IBInspectable public var name: String? = "" {
        didSet {
            var initials = ""
            if let aName = name {
                for word in aName.componentsSeparatedByString(" ") {
                    initials += ((word as NSString).substringToIndex(1) as String).uppercaseString
                }
            }
            self.initials = initials
        }
    }
    private var initials: String = "" {
        didSet {
            layer.borderColor = tintColor?.CGColor
            initialsLabel.textColor = tintColor
            initialsLabel?.text = initials
        }
    }
    @IBInspectable public var borderWidth: CGFloat = 1 {
        didSet {
            if image == nil {
                layer.borderWidth = borderWidth
            }
        }
    }
    override public var image: UIImage? {
        didSet {
            if image == nil {
                initialsLabel.hidden = false
                layer.borderWidth = borderWidth
            } else {
                initialsLabel.hidden = true
                layer.borderWidth = 0
            }
        }
    }
    override public var tintColor: UIColor! {
        didSet {
            layer.borderColor = tintColor?.CGColor
            initialsLabel.textColor = tintColor
        }
    }
    @IBOutlet public  weak var initialsLabel: UILabel! {
        didSet {
            initialsLabel.backgroundColor = UIColor.clearColor()
        }
    }
    
}
