//
//  WebViewController.swift
//  FrostKit
//
//  Created by James Barrow on 29/09/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit

public enum WebViewType {
    case Automatic
    case UIWebView
    case WKWebView
}

public func WebViewController(viewType: WebViewType = .Automatic) -> BaseWebViewController {
    
    switch viewType {
    case .UIWebView:
        return UIWebViewController()
    case .WKWebView:
        return WKWebViewController()
    default:
        break
    }
    
    if NSClassFromString("WKWebView") != nil {
        return WKWebViewController()
    }
    
    return UIWebViewController()
}
