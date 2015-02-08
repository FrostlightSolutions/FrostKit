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
    
    /// The web view. This will either be UIWebView or WKWebView depending on the requested type.
    var webView: AnyObject?
    /// The activity indicator view showing if the web view is loading or not.
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    /// The progress view to show the percent a web view has loaded. This will only be used in a WKWebView based controller.
    let progrssView = UIProgressView(progressViewStyle: .Bar)
    /// The back button for the toolbar.
    var backButton: UIBarButtonItem?
    /// The forward button for the toolbar.
    var forwardButton: UIBarButtonItem?
    /// The URL string to set for the page to be loaded.
    public var urlString: String? {
        didSet {
            if webView != nil {
                self.loadBaseURL()
            }
        }
    }
    /// The URL of the current page.
    public var URL: NSURL? {
        // Functionality overriden in subclasses
        return nil
    }
    /// The title to show in the navigation bar if something other than the loaded page's title is required.
    public var titleOverride: String? {
        didSet {
            navigationItem.title = titleOverride
        }
    }
    /// Returns `true` if the web view is currently loading, `false` if not.
    public var loading: Bool {
        // Functionality overriden in subclasses
        return false
    }
    
    /**
    Stops the web view from being loaded any more.
    */
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
    
    /**
    Dismissed the current view if presented modally.
    
    :param: sender The bar button item pressed.
    */
    func doneButtonPressed(sender: AnyObject?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
    Refrshes the web view when the refresh button is pressed in the toolbar.
    
    :param: sender The bar button item pressed.
    */
    func refreshButtonPressed(sender: AnyObject?) {
        // Functionality overriden in subclasses
    }
    
    /**
    Requests the web view go back a page.
    
    :param: sender The bar button item pressed.
    */
    func backButtonPressed(sender: AnyObject?) {
        // Functionality overriden in subclasses
    }
    
    /**
    Requests the web view go forward a page.
    
    :param: sender The bar button item pressed.
    */
    func forwardButtonPressed(sender: AnyObject?) {
        // Functionality overriden in subclasses
    }
    
    /**
    Calls and presents a UIActivityViewController.
    
    :param: sender The bar button item pressed.
    */
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
    
    /**
    Sets up the toolbar with the required buttons and actions for them.
    */
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
    
    /**
    Updates the progress view with the current loading % of the web view if available, otherwise it hides the progress view.
    */
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
    
    /**
    Updates the activity indicator view of the web view if available, otherwise it hides the activity indicator view.
    */
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
    
    /**
    Updates the back button in the toolbar depending on if it should be active or not.
    */
    func updateBackButton() {
        
        if let webView: AnyObject = webView {
            backButton?.enabled = webView.canGoBack
        }
    }
    
    /**
    Updates the forward button in the toolbar depending on if it should be active or not.
    */
    func updateForwardButton() {
        
        if let webView: AnyObject = webView {
            forwardButton?.enabled = webView.canGoForward
        }
    }
    
    /**
    Updates the back and forwards button in the toolbar depending on if they should be active or not.
    */
    func updateBackForwardButtons() {
        
        updateBackButton()
        updateForwardButton()
    }
    
    // MARK: - Load Methods
    
    /**
    Creates a URL string, appending `http://` if the URL string does not already have it as a prefix.
    
    :returns: The base URL string.
    */
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
