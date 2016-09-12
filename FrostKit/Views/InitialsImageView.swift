//
//  InitialsImageView.swift
//  FrostKit
//
//  Created by James Barrow on 12/02/2015.
//  Copyright © 2015-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

open class InitialsImageView: ImageView {
    
    @IBInspectable public var name: String? = "" {
        didSet {
            var initials = ""
            if let name = self.name {
                for word in name.components(separatedBy: " ") {
                    let index = word.index(word.startIndex, offsetBy: 1)
                    initials += word.substring(to: index).uppercased()
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
    open override var image: UIImage? {
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
    open override var tintColor: UIColor? {
        didSet {
            layer.borderColor = tintColor?.cgColor
            initialsLabel.textColor = tintColor
        }
    }
    @IBOutlet public weak var initialsLabel: UILabel! {
        didSet {
            initialsLabel.backgroundColor = .clear
        }
    }
    
}
