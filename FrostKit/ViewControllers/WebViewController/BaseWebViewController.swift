//
//  BaseWebViewController.swift
//  FrostKit
//
//  Created by James Barrow on 02/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

///
/// This class acts as a base view controller class for `UIWebViewController` and `WKWebViewController`. It defines the base values and functions used in subclesses of it. This class should not be used on it's own, always use it as a subclass such as though `UIWebViewController` or `WKWebViewController`.
///
public class BaseWebViewController: UIViewController {
    
    var webView: AnyObject?
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    let progrssView = UIProgressView(progressViewStyle: .Bar)
    
    var backButton: UIBarButtonItem?
    var forwardButton: UIBarButtonItem?
    
    public var urlString: String? {
        didSet {
            if webView != nil {
                self.loadBaseURL()
            }
        }
    }
    
    public var URL: NSURL? {
        get {
            // Functionality overriden in subclasses
            return nil
        }
    }
    
    public var titleOverride: String? {
        didSet {
            navigationItem.title = titleOverride
        }
    }
    
    public var loading: Bool {
        get {
            // Functionality overriden in subclasses
            return false
        }
    }
    
    public func stopLoading() {
        // Functionality overriden in subclasses
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navController = navigationController {
            
            let barSize = navController.navigationBar.bounds.size
            progrssView.frame = CGRectMake(0, barSize.height - progrssView.bounds.size.height, barSize.width, progrssView.bounds.size.height)
            progrssView.autoresizingMask = .FlexibleTopMargin
            navController.navigationBar.addSubview(progrssView)
            updateProgrssViewVisability()
            updateActivityViewVisability()
            
            if self.isRoot == true {
                let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonPressed:")
                navigationItem.setLeftBarButtonItem(doneButton, animated: false)
            }
        }
        
        setupToolbar()
        
        if let webView = self.webView as? UIView {
            
            view.addSubview(webView)
            
            webView.setTranslatesAutoresizingMaskIntoConstraints(false)
            let viewsDict = ["webView": webView]
            let constraintV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[webView]|", options: nil, metrics: nil, views: viewsDict)
            let constraintH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[webView]|", options: nil, metrics: nil, views: viewsDict)
            view.addConstraints(constraintV)
            view.addConstraints(constraintH)
            
            if loading == false {
                loadBaseURL()
            }
        }
    }
    
    public override func viewWillDisappear(animated: Bool) {
        stopLoading()
        
        if let navController = navigationController {
            navController.setToolbarHidden(true, animated: true)
        }
    }
    
    public override func viewDidDisappear(animated: Bool) {
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            
            self.progrssView.alpha = 0.5
            
            }, completion: { (completed) -> Void in
                
                self.progrssView.removeFromSuperview()
        })
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Action Methods
    
    func doneButtonPressed(sender: AnyObject?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func backButtonPressed(sender: AnyObject?) {
        // Functionality overriden in subclasses
    }
    
    func forwardButtonPressed(sender: AnyObject?) {
        // Functionality overriden in subclasses
    }
    
    func refreshButtonPressed(sender: AnyObject?) {
        // Functionality overriden in subclasses
    }
    
    func actionButtonPressed(sender: AnyObject?) {
        var urlString = ""
        if let url = URL?.absoluteString {
            urlString = url
        }
        
        let activityViewController = UIActivityViewController(activityItems: [urlString], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeAirDrop]
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - UI Update Methods
    
    func setupToolbar() {
        
        if let navController = navigationController {
            
            let backButton = UIBarButtonItem(title: ionicon_ios_arrow_left, font: UIFont.ionicons(size: 29), target: self, action: "backButtonPressed:")
            let forwardButton = UIBarButtonItem(title: ionicon_ios_arrow_right, font: UIFont.ionicons(size: 29), target: self, action: "forwardButtonPressed:")
            let refreshButton = UIBarButtonItem(title: ionicon_ios_refresh_empty, font: UIFont.ionicons(size: 34), target: self, action: "refreshButtonPressed:")
            let actionButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "actionButtonPressed:")
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
            
            backButton.enabled = false
            forwardButton.enabled = false
            
            setToolbarItems([backButton, flexibleSpace, forwardButton, flexibleSpace, actionButton, flexibleSpace, refreshButton], animated: false)
            navController.toolbarHidden = false
            
            self.backButton = backButton
            self.forwardButton = forwardButton
        }
    }
    
    func updateProgrssViewVisability() {
        
        if progrssView.progress >= 1.0 || progrssView.progress <= 0.0 {
            
            UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                
                self.progrssView.alpha = 0
                
                }, completion: { (completed) -> Void in
                    
                    self.progrssView.hidden = true
                    self.progrssView.progress = 0.0
                    
                    self.updateActivityViewVisability()
            })
            
        } else {
            
            self.progrssView.hidden = false
            UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                
                self.progrssView.alpha = 1
                
                }, completion: nil)
            
        }
    }
    
    func updateActivityViewVisability() {
        
        if loading == true {
            
            activityIndicatorView.startAnimating()
            
            UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                
                let loadingView = UIBarButtonItem(customView: self.activityIndicatorView)
                self.navigationItem.setRightBarButtonItem(loadingView, animated: true)
                
                }, completion: nil)
        } else {
            
            UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                
                self.navigationItem.setRightBarButtonItem(nil, animated: true)
                
                }, completion: nil)
        }
    }
    
    func updateBackButton() {
        
        if let webView: AnyObject = webView {
            backButton?.enabled = webView.canGoBack
        }
    }
    
    func updateForwardButton() {
        
        if let webView: AnyObject = webView {
            forwardButton?.enabled = webView.canGoForward
        }
    }
    
    func updateBackForwardButtons() {
        
        updateBackButton()
        updateForwardButton()
    }
    
    // MARK: - Load Methods
    
    func loadBaseURL() -> String {
        if var urlString = self.urlString {
            
            if urlString.hasPrefix("http://") == false {
                urlString = "http://".stringByAppendingString(urlString)
            }
            
            return urlString
        }
        
        return ""
    }
    
}
