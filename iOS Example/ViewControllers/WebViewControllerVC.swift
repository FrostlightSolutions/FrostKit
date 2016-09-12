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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
        case IndexPath(row: 0, section: 0):
            if #available(iOS 9, *) {
                let url = URL(string: "http://frostlight.se")!
                let safariVC = SFSafariViewController(url: url)
                present(UINavigationController(rootViewController: safariVC), animated: true, completion: nil)
            } else {
                let webVC = WebViewController()
                webVC.urlString = "frostlight.se"
                present(UINavigationController(rootViewController: webVC), animated: true, completion: nil)
            }
        case IndexPath(row: 1, section: 0):
            let webVC = WebViewController(viewType: .UIWebView)
            webVC.urlString = "frostlight.se"
            webVC.titleOverride = "WKWebViewController"
            present(UINavigationController(rootViewController: webVC), animated: true, completion: nil)
        case IndexPath(row: 2, section: 0):
            let webVC = WebViewController(viewType: .WKWebView)
            webVC.urlString = "frostlight.se"
            webVC.titleOverride = "UIWebViewController"
            present(UINavigationController(rootViewController: webVC), animated: true, completion: nil)
        case IndexPath(row: 0, section: 1):
            if #available(iOS 9, *) {
                let url = URL(string: "http://frostlight.se")!
                let safariVC = SFSafariViewController(url: url)
                navigationController?.pushViewController(safariVC, animated: true)
            } else {
                let webVC = WebViewController()
                webVC.urlString = "frostlight.se"
                navigationController?.pushViewController(webVC, animated: true)
            }
        case IndexPath(row: 1, section: 1):
            let webVC = WebViewController(viewType: .UIWebView)
            webVC.urlString = "frostlight.se"
            webVC.titleOverride = "WKWebViewController"
            navigationController?.pushViewController(webVC, animated: true)
        case IndexPath(row: 2, section: 1):
            let webVC = WebViewController(viewType: .WKWebView)
            webVC.urlString = "frostlight.se"
            webVC.titleOverride = "UIWebViewController"
            navigationController?.pushViewController(webVC, animated: true)
        default:
            break
        }
    }

}
