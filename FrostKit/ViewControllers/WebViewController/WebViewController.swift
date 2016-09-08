//
//  WebViewController.swift
//  FrostKit
//
//  Created by James Barrow on 29/09/2014.
//  Copyright © 2014-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

/// Descrbes the type of web view.
public enum WebViewType {
    /// Automatically selects the relevent web view.
    case automatic
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
@available(iOS, deprecated: 9.0, message: "This is no longer needed as of iOS 9. Use SFSafariViewController instead.")
public func WebViewController(viewType: WebViewType = .automatic) -> BaseWebViewController {
    
    switch viewType {
    case .UIWebView:
        return UIWebViewController()
    case .WKWebView:
        return WKWebViewController()
    default:
        return WKWebViewController()
    }
}
