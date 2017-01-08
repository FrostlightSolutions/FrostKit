//
//  ViewControllerExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 03/10/2014.
//  Copyright © 2014 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

///
/// Extention functions for UIBarButtonItem
///
extension UIViewController {
    
    /// Retuns if the view controller is the root view controller in a navigation stack.
    public var isRoot: Bool {
        
        if let rootViewController = self.navigationController?.viewControllers[0], self == rootViewController {
            return true
        }
        
        return false
    }
    
    /// Returns if the view controller is currently visable using `isViewLoaded()` and `view.window` references.
    public var isVisible: Bool {
        return isViewLoaded && view.window != nil
    }
    
}
