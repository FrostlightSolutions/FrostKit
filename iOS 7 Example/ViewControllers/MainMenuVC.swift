//
//  MainMenuVC.swift
//  iOS Example
//
//  Created by James Barrow on 02/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit

class MainMenuVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = true

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath {
        case NSIndexPath(forRow: 0, inSection: 1):
//            let webVC = WebViewController()
//            webVC.urlString = "frostlight.se"
//            presentViewController(UINavigationController(rootViewController: webVC), animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
}