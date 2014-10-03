//
//  UIBarButtonItemExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 03/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    public convenience init(title: String?, font: UIFont = UIFont.fontAwesome(size: 40), verticalOffset: CGFloat = -2, target: AnyObject?, action: Selector) {

        let button = UIButton.buttonWithType(.System) as UIButton
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 20)
        button.titleLabel?.font = UIFont.fontAwesome(size: 40)
        button.setTitle(title, forState: .Normal)
        button.titleEdgeInsets.top = verticalOffset
        button.addTarget(target, action: action, forControlEvents: .TouchUpInside)
        self.init(customView: button)
    }
    
}
