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
            if let name = self.name {
                for word in name.components(separatedBy: " ") {
                    initials += ((word as NSString).substring(to: 1) as String).uppercased()
                }
            }
            self.initials = initials
        }
    }
    private var initials: String = "" {
        didSet {
            layer.borderColor = tintColor?.cgColor
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
                initialsLabel.isHidden = false
                layer.borderWidth = borderWidth
            } else {
                initialsLabel.isHidden = true
                layer.borderWidth = 0
            }
        }
    }
    override public var tintColor: UIColor? {
        didSet {
            layer.borderColor = tintColor?.cgColor
            initialsLabel.textColor = tintColor
        }
    }
    @IBOutlet public  weak var initialsLabel: UILabel! {
        didSet {
            initialsLabel.backgroundColor = .clear()
        }
    }
    
}
