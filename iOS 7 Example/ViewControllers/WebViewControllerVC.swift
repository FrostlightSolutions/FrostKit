//
//  WebViewControllerVC.swift
//  iOS Example
//
//  Created by James Barrow on 02/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit

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
            let webVC = WebViewController()
            webVC.urlString = "frostlight.se"
            presentViewController(UINavigationController(rootViewController: webVC), animated: true, completion: nil)
        case NSIndexPath(forRow: 1, inSection: 0):
            let webVC = WebViewController(viewType: .UIWebView)
            webVC.urlString = "frostlight.se"
            presentViewController(UINavigationController(rootViewController: webVC), animated: true, completion: nil)
        case NSIndexPath(forRow: 2, inSection: 0):
            let webVC = WebViewController(viewType: .WKWebView)
            webVC.urlString = "frostlight.se"
            presentViewController(UINavigationController(rootViewController: webVC), animated: true, completion: nil)
        default:
            break
        }
    }

}
