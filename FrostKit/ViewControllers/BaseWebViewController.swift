//
//  BaseWebViewController.swift
//  FrostKit
//
//  Created by James Barrow on 02/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit
import Social

// TODO: Add proper icons for back and forward page buttons
// TODO: Add title String var that will override any currently set UINavigationItem title

public class BaseWebViewController: UIViewController {
    
    public var webView: AnyObject?
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
    
    var URL: NSURL? {
        get {
            // Functionality overriden in subclasses
            return nil
        }
    }
    
    var loading: Bool {
        get {
            // Functionality overriden in subclasses
            return false
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if let navController = navigationController {
            
            let barSize = navController.navigationBar.bounds.size
            progrssView.frame = CGRectMake(0, barSize.height - progrssView.bounds.size.height, barSize.width, progrssView.bounds.size.height)
            progrssView.autoresizingMask = .FlexibleTopMargin
            navController.navigationBar.addSubview(progrssView)
            updateProgrssViewVisability()
            updateActivityViewVisability()
            
            let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonPressed:")
            navigationItem.setLeftBarButtonItem(doneButton, animated: false)
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
    
    override public func didReceiveMemoryWarning() {
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
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let safariAlertAction = UIAlertAction(title: NSLocalizedString("OPEN_IN_SAFARI", comment: "Open in Safari"), style: .Default) { (action) -> Void in
            
            if let webView: AnyObject = self.webView {
                if let url = self.URL {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
        }
        alertController.addAction(safariAlertAction)
        let twitterAlertAction = UIAlertAction(title: NSLocalizedString("SHARE_ON_TWITTER", comment: "Share on Twitter"), style: .Default) { (action) -> Void in
            
            var urlsArray: [NSURL]?
            if let url = self.URL {
                urlsArray = [url]
            }
            SocialHelper.presentComposeViewController(Social.SLServiceTypeTwitter, initialText: "", urls: urlsArray, inViewController: self)
        }
        alertController.addAction(twitterAlertAction)
        let facebookAlertAction = UIAlertAction(title: NSLocalizedString("SHARE_ON_FACEBOOK", comment: "Share on Facebook"), style: .Default) { (action) -> Void in
            
            var urlsArray: [NSURL]?
            if let url = self.URL {
                urlsArray = [url]
            }
            SocialHelper.presentComposeViewController(Social.SLServiceTypeFacebook, initialText: "", urls: urlsArray, inViewController: self)
        }
        alertController.addAction(facebookAlertAction)
        let cancelAlertAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .Cancel) { (action) -> Void in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cancelAlertAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UI Update Methods
    
    func setupToolbar() {
        
        if let navController = navigationController {
            
            let backButton = UIBarButtonItem(barButtonSystemItem: .Undo, target: self, action: "backButtonPressed:")
            let forwardButton = UIBarButtonItem(barButtonSystemItem: .Redo, target: self, action: "forwardButtonPressed:")
            let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshButtonPressed:")
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
    
    func loadBaseURL() {
        if var urlString = self.urlString {
            
            if urlString.hasPrefix("http://") == false {
                urlString = "http://".stringByAppendingString(urlString)
            }
            
            if let webView: AnyObject = self.webView {
                let request = NSURLRequest(URL: NSURL(string: urlString), cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 60.0)
                webView.loadRequest(request)
            }
        }
    }
    
}