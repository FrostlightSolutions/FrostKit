//
//  UIViewControllerExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 03/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit

extension UIViewController {
    
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
