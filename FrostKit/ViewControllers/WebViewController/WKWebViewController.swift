//
//  WKWebViewController.swift
//  FrostKit
//
//  Created by James Barrow on 02/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit
import WebKit

///
/// A subclass of BaseWebViewController that wraps a WKWebView in a view controller.
///
class WKWebViewController: BaseWebViewController, WKNavigationDelegate {
    
    /// The URL of the current page.
    override var URL: NSURL? {
        if let webView = self.webView as? WKWebView {
            return webView.URL
        }
        return nil
    }
    /// The title to show in the navigation bar if something other than the loaded page's title is required.
    override var titleOverride: String? {
        didSet {
            if titleOverride != nil {
                navigationItem.title = titleOverride
            } else if let webView = self.webView as? WKWebView {
                navigationItem.title = webView.title
            }
        }
    }
    /// Returns `true` if the web view is currently loading, `false` if not.
    override var loading: Bool {
        if let webView = self.webView as? WKWebView {
            return webView.loading
        }
        return false
    }
    
    /**
    Stops the web view from being loaded any more.
    */
    override func stopLoading() {
        (self.webView as? WKWebView)?.stopLoading()
    }
    
    override func viewDidLoad() {
        
        webView = WKWebView(frame: view.bounds)
        
        if let webView = self.webView as? WKWebView {
            
            webView.allowsBackForwardNavigationGestures = true
            
            webView.addObserver(self, forKeyPath: "estimatedProgress", options: [], context: nil)
            webView.addObserver(self, forKeyPath: "title", options: [], context: nil)
            webView.addObserver(self, forKeyPath: "canGoBack", options: [], context: nil)
            webView.addObserver(self, forKeyPath: "canGoForward", options: [], context: nil)
        }
        
        super.viewDidLoad()
    }
    
    deinit {
        if let webView = self.webView as? WKWebView {
            webView.removeObserver(self, forKeyPath: "estimatedProgress")
            webView.removeObserver(self, forKeyPath: "title")
            webView.removeObserver(self, forKeyPath: "canGoBack")
            webView.removeObserver(self, forKeyPath: "canGoForward")
        }
    }
    
    // MARK: - KVO Methods
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [NSObject : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        switch keyPath {
        case "estimatedProgress":
            self.progrssView.setProgress(Float(webView!.estimatedProgress), animated: true)
            updateProgrssViewVisability()
            updateActivityViewVisability()
        case "title":
            if let webView = self.webView as? WKWebView where titleOverride == nil {
                navigationItem.title = webView.title
            }
        case "canGoBack":
            updateBackButton()
        case "canGoForward":
            updateForwardButton()
        default:
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    // MARK: - Action Methods
    
    /**
    Refrshes the web view when the refresh button is pressed in the toolbar.
    
    - parameter sender: The bar button item pressed.
    */
    override func refreshButtonPressed(sender: AnyObject?) {
        
        if let webView = self.webView as? WKWebView {
            
            if webView.loading == true {
                
                webView.stopLoading()
            }
            webView.reload()
        }
    }
    
    /**
    Requests the web view go back a page.
    
    - parameter sender: The bar button item pressed.
    */
    override func backButtonPressed(sender: AnyObject?) {
        
        if let webView = self.webView as? WKWebView {
            
            if webView.canGoBack == true {
                webView.goBack()
            } else {
                updateBackButton()
            }
        }
    }
    
    /**
    Requests the web view go forward a page.
    
    - parameter sender: The bar button item pressed.
    */
    override func forwardButtonPressed(sender: AnyObject?) {
        
        if let webView = self.webView as? WKWebView {
            
            if webView.canGoForward == true {
                webView.goForward()
            } else {
                updateBackButton()
            }
        }
    }
    
    // MARK: - WKNavigationDelegate Methods
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
        
        // Alows links in the WKWebView to be tappable
        decisionHandler(.Allow)
    }
    
    // MARK: - Load Methods
    
    /**
    Creates a URL string, appending `http://` if the URL string does not already have it as a prefix and then loads the page in the web view.
    
    - returns: The base URL string.
    */
    override func loadBaseURL() -> String {
        
        let urlString = super.loadBaseURL()
        
        if let webView = self.webView as? WKWebView {
            let request = NSURLRequest(URL: NSURL(string: urlString)!, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 60.0)
            webView.loadRequest(request)
        }
        
        return urlString
    }
    
}
