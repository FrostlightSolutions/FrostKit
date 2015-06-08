//
//  WebViewController.swift
//  FrostKit
//
//  Created by James Barrow on 29/09/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

/// Descrbes the type of web view.
public enum WebViewType {
    /// Automatically selects the relevent web view.
    case Automatic
    /// UIWebView.
    case UIWebView
    /// WKWebView.
    case WKWebView
}

/**
Returns a WebViewController dependant on the variable or automatically

- parameter viewType:    The type of view to use in the controller. By default this is done automatically.

- returns: A base web view controller with the designated web view.
*/
public func WebViewController(viewType: WebViewType = .Automatic) -> BaseWebViewController {
    
    switch viewType {
    case .UIWebView:
        return UIWebViewController()
    case .WKWebView:
        if NSClassFromString("WKWebView") != nil {
            return WKWebViewController()
        } else {
            NSLog("Warning: WKWebViewController is not available on the running version of iOS. Using UIWebViewController instead.")
            return UIWebViewController()
        }
    default:
        break
    }
    
    if NSClassFromString("WKWebView") != nil {
        return WKWebViewController()
    }
    
    return UIWebViewController()
}
