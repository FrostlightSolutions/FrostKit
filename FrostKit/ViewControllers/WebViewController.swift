//
//  WebViewController.swift
//  FrostKit
//
//  Created by James Barrow on 29/09/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit
import WebKit
import Social

public class WebViewController: UIViewController, WKNavigationDelegate {
    
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
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if let navController = navigationController {
            
            let barSize = navController.navigationBar.bounds.size
            progrssView.frame = CGRectMake(0, barSize.height - progrssView.bounds.size.height, barSize.width, progrssView.bounds.size.height)
            progrssView.autoresizingMask = .FlexibleTopMargin
            navController.navigationBar.addSubview(progrssView)
            updateProgrssViewVisability()
            
            let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonPressed:")
            navigationItem.setLeftBarButtonItem(doneButton, animated: false)
        }
        
        setupToolbar()
        
        let webView = WKWebView(frame: view.bounds)
        view.addSubview(webView)
        
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let viewsDict = ["webView": webView]
        let constraintV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[webView]|", options: nil, metrics: nil, views: viewsDict)
        let constraintH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[webView]|", options: nil, metrics: nil, views: viewsDict)
        view.addConstraints(constraintV)
        view.addConstraints(constraintH)
        
        self.webView = webView
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: nil, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: nil, context: nil)
        webView.addObserver(self, forKeyPath: "canGoBack", options: nil, context: nil)
        webView.addObserver(self, forKeyPath: "canGoForward", options: nil, context: nil)
        
        if webView.loading == false {
            loadBaseURL()
        }
    }
    
    deinit {
        webView?.removeObserver(self, forKeyPath: "estimatedProgress")
        webView?.removeObserver(self, forKeyPath: "title")
        webView?.removeObserver(self, forKeyPath: "canGoBack")
        webView?.removeObserver(self, forKeyPath: "canGoForward")
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - KVO Methods
    
    override public func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
        
        switch keyPath {
        case "estimatedProgress":
            progrssView.progress = Float(webView!.estimatedProgress)
            updateProgrssViewVisability()
        case "title":
            navigationItem.title = webView?.title
        case "canGoBack":
            if let canGoBack = webView?.canGoBack {
                backButton?.enabled = canGoBack
            }
        case "canGoForward":
            if let canGoForward = webView?.canGoForward {
                forwardButton?.enabled = canGoForward
            }
        default:
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    // MARK: - Action Methods
    
    func doneButtonPressed(sender: AnyObject?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func backButtonPressed(sender: AnyObject?) {
        webView?.goBack()
    }
    
    func forwardButtonPressed(sender: AnyObject?) {
        webView?.goForward()
    }
    
    func refreshButtonPressed(sender: AnyObject?) {
        if let webView = self.webView as? WKWebView {
            
            if webView.loading == true {
                
                webView.stopLoading()
            }
            webView.reload()
        }
    }
    
    func actionButtonPressed(sender: AnyObject?) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let safariAlertAction = UIAlertAction(title: NSLocalizedString("OPEN_IN_SAFARI", comment: "Open in Safari"), style: .Default) { (action) -> Void in
            
            if let webView = self.webView as? WKWebView {
                UIApplication.sharedApplication().openURL(webView.URL)
            }
        }
        alertController.addAction(safariAlertAction)
        let twitterAlertAction = UIAlertAction(title: NSLocalizedString("SHARE_ON_TWITTER", comment: "Share on Twitter"), style: .Default) { (action) -> Void in
            
            var urlsArray: [NSURL]?
            if let webView = self.webView as? WKWebView {
                urlsArray = []
                urlsArray?.append(webView.URL)
            }
            SocialHelper.presentComposeViewController(Social.SLServiceTypeTwitter, initialText: "", urls: urlsArray, inViewController: self)
        }
        alertController.addAction(twitterAlertAction)
        let facebookAlertAction = UIAlertAction(title: NSLocalizedString("SHARE_ON_FACEBOOK", comment: "Share on Facebook"), style: .Default) { (action) -> Void in
            
            var urlsArray: [NSURL]?
            if let webView = self.webView as? WKWebView {
                urlsArray = []
                urlsArray?.append(webView.URL)
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
                
                self.navigationItem.setRightBarButtonItem(nil, animated: true)
                self.progrssView.alpha = 0
                
            }, completion: { (completed) -> Void in
                
                self.progrssView.hidden = true
                self.progrssView.progress = 0.0
            })
            
        } else {
            
            activityIndicatorView.startAnimating()
            
            self.progrssView.hidden = false
            UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                
                let loadingView = UIBarButtonItem(customView: self.activityIndicatorView)
                self.navigationItem.setRightBarButtonItem(loadingView, animated: true)
                
                self.progrssView.alpha = 1
                
            }, completion: nil)
            
        }
    }
    
    // MARK: - Load Methods
    
    func loadBaseURL() {
        if var urlString = self.urlString {
            
            if urlString.hasPrefix("http://") == false {
                urlString = "http://".stringByAppendingString(urlString)
            }
            
            if let webView = self.webView as? WKWebView {
                let request = NSURLRequest(URL: NSURL(string: urlString), cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 60.0)
                webView.loadRequest(request)
            }
        }
    }
    
    // MARK: - WKNavigationDelegate Methods
    
    public func webView(webView: WKWebView!, decidePolicyForNavigationAction navigationAction: WKNavigationAction!, decisionHandler: ((WKNavigationActionPolicy) -> Void)!) {
        
        // Alows links in the WKWebView to be tappable
        decisionHandler(.Allow)
    }
    
}
