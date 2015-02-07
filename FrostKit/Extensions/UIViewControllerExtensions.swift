//
//  UIViewControllerExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 03/10/2014.
//  Copyright (c) 2014-2015 Frostlight Solutions. All rights reserved.
//

import UIKit

///
/// Extention functions for UIBarButtonItem
///
extension UIViewController {
    
    /// Retuns if the view controller is the root view controller in a navigation stack.
    public var isRoot: Bool {
        
        if let navigationController = self.navigationController {
            
            if let viewControllers = navigationController.viewControllers {
                
                if let rootViewController = viewControllers[0] as? UIViewController {
                    
                    if self == rootViewController {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
}
