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
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    /// The progress view to show the percent a web view has loaded. This will only be used in a WKWebView based controller.
    let progrssView = UIProgressView(progressViewStyle: .bar)
    /// The back button for the toolbar.
    var backButton: UIBarButtonItem?
    /// The forward button for the toolbar.
    var forwardButton: UIBarButtonItem?
    /// The URL string to set for the page to be loaded.
    public var urlString: String? {
        didSet {
            if webView != nil {
                let _ = self.loadBaseURL()
            }
        }
    }
    /// The URL of the current page.
    public var url: URL? {
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
            
            activityIndicatorView.color = FrostKit.tintColor ?? navigationController?.navigationBar.tintColor
            
            let barSize = navController.navigationBar.bounds.size
            progrssView.frame = CGRect(x: 0, y: barSize.height - progrssView.bounds.size.height, width: barSize.width, height: progrssView.bounds.size.height)
            progrssView.autoresizingMask = .flexibleTopMargin
            navController.navigationBar.addSubview(progrssView)
            updateProgrssViewVisability()
            updateActivityViewVisability()
            
            if self.isRoot == true {
                
                let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(BaseWebViewController.doneButtonPressed(sender:)))
                navigationItem.setLeftBarButton(doneButton, animated: false)
            }
        }
        
        setupToolbar()
        
        if let webView = self.webView as? UIView {
            
            view.addSubview(webView)
            
            webView.translatesAutoresizingMaskIntoConstraints = false
            let viewsDict = ["webView": webView]
            let constraintV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options: [], metrics: nil, views: viewsDict)
            let constraintH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: [], metrics: nil, views: viewsDict)
            view.addConstraints(constraintV)
            view.addConstraints(constraintH)
            
            if loading == false {
                let _ = loadBaseURL()
            }
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        stopLoading()
        
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveEaseIn, .curveEaseOut], animations: { () -> Void in
            
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
    
    - parameter sender: The bar button item pressed.
    */
    public func doneButtonPressed(sender: AnyObject?) {
        dismiss(animated: true, completion: nil)
    }
    
    /**
    Refrshes the web view when the refresh button is pressed in the toolbar.
    
    - parameter sender: The bar button item pressed.
    */
    public func refreshButtonPressed(sender: AnyObject?) {
        // Functionality overriden in subclasses
    }
    
    /**
    Requests the web view go back a page.
    
    - parameter sender: The bar button item pressed.
    */
    public func backButtonPressed(sender: AnyObject?) {
        // Functionality overriden in subclasses
    }
    
    /**
    Requests the web view go forward a page.
    
    - parameter sender: The bar button item pressed.
    */
    public func forwardButtonPressed(sender: AnyObject?) {
        // Functionality overriden in subclasses
    }
    
    /**
    Calls and presents a UIActivityViewController.
    
    - parameter sender: The bar button item pressed.
    */
    public func actionButtonPressed(sender: AnyObject?) {
        var activityItems = [String]()
        if let url = self.url?.absoluteString {
            activityItems.append(url)
        }
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeAirDrop]
        present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - UI Update Methods
    
    /**
    Sets up the toolbar with the required buttons and actions for them.
    */
    func setupToolbar() {
        
        if let navController = navigationController {
            
            let backButton = UIBarButtonItem(title: IonIcons.ios_arrow_left, font: UIFont.ionicons(size: 29), target: self, action: #selector(BaseWebViewController.backButtonPressed(sender:)))
            let forwardButton = UIBarButtonItem(title: IonIcons.ios_arrow_right, font: UIFont.ionicons(size: 29), target: self, action: #selector(BaseWebViewController.forwardButtonPressed(sender:)))
            let refreshButton = UIBarButtonItem(title: IonIcons.ios_refresh_empty, font: UIFont.ionicons(size: 34), target: self, action: #selector(BaseWebViewController.refreshButtonPressed(sender:)))
            let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(BaseWebViewController.actionButtonPressed(sender:)))
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            
            backButton.isEnabled = false
            forwardButton.isEnabled = false
            
            setToolbarItems([backButton, flexibleSpace, forwardButton, flexibleSpace, actionButton, flexibleSpace, refreshButton], animated: false)
            navController.isToolbarHidden = false
            
            self.backButton = backButton
            self.forwardButton = forwardButton
        }
    }
    
    /**
    Updates the progress view with the current loading % of the web view if available, otherwise it hides the progress view.
    */
    func updateProgrssViewVisability() {
        
        if progrssView.progress >= 1.0 || progrssView.progress <= 0.0 {
            
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveEaseIn, .curveEaseOut], animations: { () -> Void in
                
                self.progrssView.alpha = 0
                
                }, completion: { (completed) -> Void in
                    
                    self.progrssView.isHidden = true
                    self.progrssView.progress = 0.0
                    
                    self.updateActivityViewVisability()
            })
            
        } else {
            
            self.progrssView.isHidden = false
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveEaseIn, .curveEaseOut], animations: { () -> Void in
                
                self.progrssView.alpha = 1
                
                }, completion: nil)
            
        }
    }
    
    /**
    Updates the activity indicator view of the web view if available, otherwise it hides the activity indicator view.
    */
    func updateActivityViewVisability() {
        
        if loading == true {
            
            NotificationCenter.default().post(name: NSNotification.Name(rawValue: NetworkRequestDidBeginNotification), object: nil)
            activityIndicatorView.startAnimating()
            
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveEaseIn, .curveEaseOut], animations: { () -> Void in
                
                let loadingView = UIBarButtonItem(customView: self.activityIndicatorView)
                self.navigationItem.setRightBarButton(loadingView, animated: true)
                
                }, completion: nil)
        } else {
            
            NotificationCenter.default().post(name: NSNotification.Name(rawValue: NetworkRequestDidCompleteNotification), object: nil)
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveEaseIn, .curveEaseOut], animations: { () -> Void in
                
                self.navigationItem.setRightBarButton(nil, animated: true)
                
                }, completion: nil)
        }
    }
    
    /**
    Updates the back button in the toolbar depending on if it should be active or not.
    */
    func updateBackButton() {
        
        if let webView: AnyObject = webView {
            backButton?.isEnabled = webView.canGoBack
        }
    }
    
    /**
    Updates the forward button in the toolbar depending on if it should be active or not.
    */
    func updateForwardButton() {
        
        if let webView: AnyObject = webView {
            forwardButton?.isEnabled = webView.canGoForward
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
    
    - returns: The base URL string.
    */
    func loadBaseURL() -> String {
        if var urlString = self.urlString {
            
            if urlString.hasPrefix("http://") == false {
                urlString = "http://".appending(urlString)
            }
            
            return urlString
        }
        
        return ""
    }
    
}
