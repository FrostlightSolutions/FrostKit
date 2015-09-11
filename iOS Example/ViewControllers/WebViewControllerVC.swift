//
//  WebViewControllerVC.swift
//  iOS Example
//
//  Created by James Barrow on 02/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit
import SafariServices
import FrostKit

class WebViewControllerVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = true
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath {
        case NSIndexPath(forRow: 0, inSection: 0):
            if #available(iOS 9, *) {
                let url = NSURL(string: "http://frostlight.se")!
                let safariVC = SFSafariViewController(URL: url)
                presentViewController(UINavigationController(rootViewController: safariVC), animated: true, completion: nil)
            } else {
                let webVC = WebViewController()
                webVC.urlString = "frostlight.se"
                presentViewController(UINavigationController(rootViewController: webVC), animated: true, completion: nil)
            }
        case NSIndexPath(forRow: 1, inSection: 0):
            let webVC = WebViewController(viewType: .UIWebView)
            webVC.urlString = "frostlight.se"
            webVC.titleOverride = "WKWebViewController"
            presentViewController(UINavigationController(rootViewController: webVC), animated: true, completion: nil)
        case NSIndexPath(forRow: 2, inSection: 0):
            let webVC = WebViewController(viewType: .WKWebView)
            webVC.urlString = "frostlight.se"
            webVC.titleOverride = "UIWebViewController"
            presentViewController(UINavigationController(rootViewController: webVC), animated: true, completion: nil)
        case NSIndexPath(forRow: 0, inSection: 1):
            if #available(iOS 9, *) {
                let url = NSURL(string: "http://frostlight.se")!
                let safariVC = SFSafariViewController(URL: url)
                navigationController?.pushViewController(safariVC, animated: true)
            } else {
                let webVC = WebViewController()
                webVC.urlString = "frostlight.se"
                navigationController?.pushViewController(webVC, animated: true)
            }
        case NSIndexPath(forRow: 1, inSection: 1):
            let webVC = WebViewController(viewType: .UIWebView)
            webVC.urlString = "frostlight.se"
            webVC.titleOverride = "WKWebViewController"
            navigationController?.pushViewController(webVC, animated: true)
        case NSIndexPath(forRow: 2, inSection: 1):
            let webVC = WebViewController(viewType: .WKWebView)
            webVC.urlString = "frostlight.se"
            webVC.titleOverride = "UIWebViewController"
            navigationController?.pushViewController(webVC, animated: true)
        default:
            break
        }
    }

}
