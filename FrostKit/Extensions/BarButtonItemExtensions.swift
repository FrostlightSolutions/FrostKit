//
//  BarButtonItemExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 03/10/2014.
//  Copyright © 2014-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

///
/// Extention functions for UIBarButtonItem
///
extension UIBarButtonItem {
    
    /**
    A convenience init for creating a bar button item with a title with a specific font.
    
    - parameter title:          The item's title. If `nil` a title is not displayed.
    - parameter font:           The font to use for rendering.
    - parameter verticalOffset: The vertical offset to apply to the `title`.
    - parameter target:         The object that receives the `action` message.
    - parameter action:         The action to send to `target` when this item is selected.
    */
    public convenience init(title: String?, font: UIFont, verticalOffset: CGFloat = 0, target: AnyObject?, action: Selector) {

        let button = UIButton(type: .System)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.titleLabel?.font = font
        button.setTitle(title, forState: .Normal)
        button.titleEdgeInsets.top = verticalOffset
        button.addTarget(target, action: action, forControlEvents: .TouchUpInside)
        self.init(customView: button)
    }
    
}
