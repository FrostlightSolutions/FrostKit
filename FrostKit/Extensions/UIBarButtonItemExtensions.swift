//
//  UIBarButtonItemExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 03/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

///
/// Extention functions for UIBarButtonItem
///
extension UIBarButtonItem {
    
    /**
        A convenience init for creating a bar button item with a title with a specific font.
    
        :param: title               The item’s title. If `nil` a title is not displayed.
        :param: font                The font to use for rendering.
        :param: verticalOffset      The vertical offset to apply to the `title`.
        :param: target              The object that receives the `action` message.
        :param: action              The action to send to `target` when this item is selected.
    
        :returns: Newly initialized item with the specified properties..
    */
    public convenience init(title: String?, font: UIFont, verticalOffset: CGFloat = 0, target: AnyObject?, action: Selector) {

        let button = UIButton.buttonWithType(.System) as UIButton
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.titleLabel?.font = font
        button.setTitle(title, forState: .Normal)
        button.titleEdgeInsets.top = verticalOffset
        button.addTarget(target, action: action, forControlEvents: .TouchUpInside)
        self.init(customView: button)
    }
    
}
