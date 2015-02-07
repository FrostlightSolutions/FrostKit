//
//  UIWebViewController.swift
//  FrostKit
//
//  Created by James Barrow on 02/10/2014.
//  Copyright (c) 2014-2015 Frostlight Solutions. All rights reserved.
//

import UIKit

class UIWebViewController: BaseWebViewController, UIWebViewDelegate {
    
    override var URL: NSURL? {
        get {
            if let urlString = self.urlString {
                return  NSURL(string: urlString)
            }
            return nil
        }
    }
    
    override var loading: Bool {
        get {
            if let webView = self.webView as? UIWebView {
                return webView.loading
            }
            return false
        }
    }
    
    override func stopLoading() {
        if let webView = self.webView as? UIWebView {
            return webView.stopLoading()
        }
    }
    
    override func viewDidLoad() {
        
        webView = UIWebView(frame: view.bounds)
        
        if let webView = self.webView as? UIWebView {
            webView.delegate = self
        }
        
        super.viewDidLoad()
    }
    
    // MARK: - Action Methods
    
    override func refreshButtonPressed(sender: AnyObject?) {
        
        if let webView = self.webView as? UIWebView {
            
            if webView.loading == true {
                
                webView.stopLoading()
            }
            webView.reload()
        }
    }
    
    override func backButtonPressed(sender: AnyObject?) {
        
        if let webView = self.webView as? UIWebView {
            
            if webView.canGoBack == true {
                webView.goBack()
            } else {
                updateBackButton()
            }
        }
    }
    
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
    
    func webViewDidStartLoad(webView: UIWebView) {
        
        updateActivityViewVisability()
        updateBackForwardButtons()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        updateActivityViewVisability()
        updateBackForwardButtons()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        
        updateActivityViewVisability()
        updateBackForwardButtons()
    }
    
    // MARK: - Load Methods
    
    override func loadBaseURL() -> String {
        
        var urlString = super.loadBaseURL()
        
        if let webView = self.webView as? UIWebView {
            let request = NSURLRequest(URL: NSURL(string: urlString)!, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 60.0)
            webView.loadRequest(request)
        }
        
        return urlString
    }
    
}
