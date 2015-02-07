//
//  WKWebViewController.swift
//  FrostKit
//
//  Created by James Barrow on 02/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit
import WebKit

class WKWebViewController: BaseWebViewController, WKNavigationDelegate {
    
    override var URL: NSURL? {
        get {
            if let webView = self.webView as? WKWebView {
                return webView.URL
            }
            return nil
        }
    }
    
    override var titleOverride: String? {
        didSet {
            if titleOverride != nil {
                navigationItem.title = titleOverride
            } else {
                if let webView = self.webView as? WKWebView {
                    navigationItem.title = webView.title
                }
            }
        }
    }
    
    override var loading: Bool {
        get {
            if let webView = self.webView as? WKWebView {
                return webView.loading
            }
            return false
        }
    }
    
    override func stopLoading() {
        if let webView = self.webView as? WKWebView {
            return webView.stopLoading()
        }
    }
    
    override func viewDidLoad() {
        
        webView = WKWebView(frame: view.bounds)
        
        if let webView = self.webView as? WKWebView {
            
            webView.allowsBackForwardNavigationGestures = true
            
            webView.addObserver(self, forKeyPath: "estimatedProgress", options: nil, context: nil)
            webView.addObserver(self, forKeyPath: "title", options: nil, context: nil)
            webView.addObserver(self, forKeyPath: "canGoBack", options: nil, context: nil)
            webView.addObserver(self, forKeyPath: "canGoForward", options: nil, context: nil)
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
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        switch keyPath {
        case "estimatedProgress":
            self.progrssView.setProgress(Float(webView!.estimatedProgress), animated: true)
            updateProgrssViewVisability()
            updateActivityViewVisability()
        case "title":
            if titleOverride == nil {
                if let webView = self.webView as? WKWebView {
                    navigationItem.title = webView.title
                }
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
    
    override func refreshButtonPressed(sender: AnyObject?) {
        
        if let webView = self.webView as? WKWebView {
            
            if webView.loading == true {
                
                webView.stopLoading()
            }
            webView.reload()
        }
    }
    
    override func backButtonPressed(sender: AnyObject?) {
        
        if let webView = self.webView as? WKWebView {
            
            if webView.canGoBack == true {
                webView.goBack()
            } else {
                updateBackButton()
            }
        }
    }
    
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
    
    func webView(webView: WKWebView!, decidePolicyForNavigationAction navigationAction: WKNavigationAction!, decisionHandler: ((WKNavigationActionPolicy) -> Void)!) {
        
        // Alows links in the WKWebView to be tappable
        decisionHandler(.Allow)
    }
    
    // MARK: - Load Methods
    
    override func loadBaseURL() -> String {
        
        var urlString = super.loadBaseURL()
        
        if let webView = self.webView as? WKWebView {
            let request = NSURLRequest(URL: NSURL(string: urlString)!, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 60.0)
            webView.loadRequest(request)
        }
        
        return urlString
    }
    
}
