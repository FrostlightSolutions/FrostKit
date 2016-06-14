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
@available(iOS, deprecated: 9.0, message: "This is no longer needed as of iOS 9. Use SFSafariViewController instead.")
public class WKWebViewController: BaseWebViewController, WKNavigationDelegate {
    
    /// The URL of the current page.
    public override var url: URL? {
        if let webView = self.webView as? WKWebView {
            return webView.url
        }
        return nil
    }
    /// The title to show in the navigation bar if something other than the loaded page's title is required.
    public override var titleOverride: String? {
        didSet {
            if titleOverride != nil {
                navigationItem.title = titleOverride
            } else if let webView = self.webView as? WKWebView {
                navigationItem.title = webView.title
            }
        }
    }
    /// Returns `true` if the web view is currently loading, `false` if not.
    public override var loading: Bool {
        if let webView = self.webView as? WKWebView {
            return webView.isLoading
        }
        return false
    }
    
    /**
    Stops the web view from being loaded any more.
    */
    public override func stopLoading() {
        (self.webView as? WKWebView)?.stopLoading()
    }
    
    public override func viewDidLoad() {
        
        webView = WKWebView(frame: view.bounds)
        
        if let webView = self.webView as? WKWebView {
            
            webView.allowsBackForwardNavigationGestures = true
            
            webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: [], context: nil)
            webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: [], context: nil)
            webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: [], context: nil)
            webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: [], context: nil)
        }
        
        super.viewDidLoad()
    }
    
    deinit {
        if let webView = self.webView as? WKWebView {
            webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
            webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
            webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
            webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward))
        }
    }
    
    // MARK: - KVO Methods
    
    public override func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutablePointer<Void>?) {
        
        guard let aKeyPath = keyPath else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        switch aKeyPath {
        case #keyPath(WKWebView.estimatedProgress):
            self.progrssView.setProgress(Float(webView!.estimatedProgress), animated: true)
            updateProgrssViewVisability()
            updateActivityViewVisability()
        case #keyPath(WKWebView.title):
            if let webView = self.webView as? WKWebView where titleOverride == nil {
                navigationItem.title = webView.title
            }
        case #keyPath(WKWebView.canGoBack):
            updateBackButton()
        case #keyPath(WKWebView.canGoForward):
            updateForwardButton()
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: - Action Methods
    
    /**
    Refrshes the web view when the refresh button is pressed in the toolbar.
    
    - parameter sender: The bar button item pressed.
    */
    public override func refreshButtonPressed(sender: AnyObject?) {
        
        if let webView = self.webView as? WKWebView {
            
            if webView.isLoading == true {
                webView.stopLoading()
            }
            webView.reload()
        }
    }
    
    /**
    Requests the web view go back a page.
    
    - parameter sender: The bar button item pressed.
    */
    public override func backButtonPressed(sender: AnyObject?) {
        
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
    public override func forwardButtonPressed(sender: AnyObject?) {
        
        if let webView = self.webView as? WKWebView {
            
            if webView.canGoForward == true {
                webView.goForward()
            } else {
                updateBackButton()
            }
        }
    }
    
    // MARK: - WKNavigationDelegate Methods
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        // Alows links in the WKWebView to be tappable
        decisionHandler(.allow)
    }
    
    // MARK: - Load Methods
    
    /**
    Creates a URL string, appending `http://` if the URL string does not already have it as a prefix and then loads the page in the web view.
    
    - returns: The base URL string.
    */
    override func loadBaseURL() -> String {
        
        let urlString = super.loadBaseURL()
        guard let url = URL(string: urlString), webView = self.webView as? WKWebView else {
            return urlString
        }
        
        let request = URLRequest(url: url as URL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
        webView.load(request as URLRequest)
        return urlString
    }
    
}
