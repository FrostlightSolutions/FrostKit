//
//  UIWebViewController.swift
//  FrostKit
//
//  Created by James Barrow on 02/10/2014.
//  Copyright © 2014-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

/// 
/// A subclass of BaseWebViewController that wraps a UIWebView in a view controller.
///
@available(iOS, deprecated=9.0, message="This is no longer needed as of iOS 9. Use SFSafariViewController instead.")
public class UIWebViewController: BaseWebViewController, UIWebViewDelegate {
    
    /// The URL of the current page.
    public override var URL: NSURL? {
        if let urlString = self.urlString {
            return  NSURL(string: urlString)
        }
        return nil
    }
    /// Returns `true` if the web view is currently loading, `false` if not.
    public override var loading: Bool {
        if let webView = self.webView as? UIWebView {
            return webView.loading
        }
        return false
    }
    
    /**
    Stops the web view from being loaded any more.
    */
    public override func stopLoading() {
        (self.webView as? UIWebView)?.stopLoading()
    }
    
    public override func viewDidLoad() {
        
        webView = UIWebView(frame: view.bounds)
        (self.webView as? UIWebView)?.delegate = self
        
        super.viewDidLoad()
    }
    
    // MARK: - Action Methods
    
    /**
    Refrshes the web view when the refresh button is pressed in the toolbar.
    
    - parameter sender: The bar button item pressed.
    */
    override func refreshButtonPressed(sender: AnyObject?) {
        
        if let webView = self.webView as? UIWebView {
            
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
        
        if let webView = self.webView as? UIWebView {
            
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
        
        if let webView = self.webView as? UIWebView {
            
            if webView.canGoForward == true {
                webView.goForward()
            } else {
                updateBackButton()
            }
        }
    }
    
    // MARK: - UIWebViewDelegate Methods
    
    public func webViewDidStartLoad(webView: UIWebView) {
        
        updateActivityViewVisability()
        updateBackForwardButtons()
    }
    
    public func webViewDidFinishLoad(webView: UIWebView) {
        
        updateActivityViewVisability()
        updateBackForwardButtons()
    }
    
    public func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        
        updateActivityViewVisability()
        updateBackForwardButtons()
    }
    
    // MARK: - Load Methods
    
    /**
    Creates a URL string, appending `http://` if the URL string does not already have it as a prefix and then loads the page in the web view.
    
    - returns: The base URL string.
    */
    override func loadBaseURL() -> String {
        
        let urlString = super.loadBaseURL()
        
        if let webView = self.webView as? UIWebView {
            let request = NSURLRequest(URL: NSURL(string: urlString)!, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 60.0)
            webView.loadRequest(request)
        }
        
        return urlString
    }
    
}
