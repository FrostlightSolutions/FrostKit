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
        if NSClassFromString("WKWebView") != nil {
            return WKWebViewController()
        } else {
            // TODO: - Update with localised warning!
//            println(String(format: "%@: %@", arguments: [NSLocalizedString("WARNING", comment: "Warning"), String(format: NSLocalizedString("CLASS_X_NOT_AVAILABLE_USING_X", comment: "Class XYZ Not Available. Using ABC."), arguments: ["WKWebViewController", "UIWebViewController"])]))
            println("WARNING: WKWebViewController is not available on the running version of iOS. Using UIWebViewController instead.")
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
