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
    
    /// Present an error in the current view controller.
    /// - Parameter error: The error to be presented.
    /// - Parameter title: The title for the alert controller.
    /// - Parameter shouldPresent: If the alert controller should be automatically presented.
    /// - Parameter actionCompleted: A closure triggered when the default "OK" button is selected.
    @discardableResult
    func present(_ error: Error, title: String, shouldPresent: Bool = true, actionCompleted: (() -> Void)?) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: FKLocalizedString("OK"), style: .default) { (_) in
            alertController.dismiss(animated: true, completion: nil)
            
            actionCompleted?()
        }
        alertController.addAction(okAction)
        
        if shouldPresent {
            present(alertController, animated: true, completion: nil)
        }
        
        return alertController
    }
    
}
