//
//  WKWebViewController.swift
//  FrostKit
//
//  Created by James Barrow on 02/10/2014.
//  Copyright © 2014 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
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
    
    private lazy var observers = [NSKeyValueObservation]()
    
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
            
            let progressObserver = webView.observe(\.estimatedProgress, changeHandler: { (webView, _) in
                
                self.progrssView.setProgress(Float(webView.estimatedProgress), animated: true)
                self.updateProgrssViewVisability()
                self.updateActivityViewVisability()
            })
            observers.append(progressObserver)
            
            let titleObserver = webView.observe(\.title, changeHandler: { (webView, _) in
                
                if self.titleOverride == nil {
                    self.navigationItem.title = webView.title
                }
            })
            observers.append(titleObserver)
            
            let canGoBackObserver = webView.observe(\.canGoBack, changeHandler: { (_, _) in
                self.updateBackButton()
            })
            observers.append(canGoBackObserver)
            
            let canGoForwardObserver = webView.observe(\.canGoForward, changeHandler: { (_, _) in
                self.updateForwardButton()
            })
            observers.append(canGoForwardObserver)
        }
        
        super.viewDidLoad()
    }
    
    deinit {
        
        for observer in observers {
            webView?.removeObserver(observer)
        }
    }
    
    // MARK: - Action Methods
    
    /**
    Refrshes the web view when the refresh button is pressed in the toolbar.
     
    - parameter sender: The bar button item pressed.
    */
    public override func refreshButtonPressed(_ sender: AnyObject?) {
        
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
    public override func backButtonPressed(_ sender: AnyObject?) {
        
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
    public override func forwardButtonPressed(_ sender: AnyObject?) {
        
        if let webView = self.webView as? WKWebView {
            
            if webView.canGoForward == true {
                webView.goForward()
            } else {
                updateBackButton()
            }
        }
    }
    
    // MARK: - WKNavigationDelegate Methods
    
    @nonobjc public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
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
        guard let url = NSURL(string: urlString), let webView = self.webView as? WKWebView else {
            return urlString
        }
        
        let request = URLRequest(url: url as URL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
        webView.load(request)
        return urlString
    }
}
