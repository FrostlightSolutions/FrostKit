//
//  SocialHelperVC.swift
//  iOS Example
//
//  Created by James Barrow on 02/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit
import Social

class SocialHelperVC: UITableViewController {

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

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath {
        case NSIndexPath(forRow: 0, inSection: 0):
            SocialHelper.presentComposeViewController(SLServiceTypeTwitter, inViewController: self)
        case NSIndexPath(forRow: 1, inSection: 0):
            SocialHelper.presentComposeViewController(SLServiceTypeFacebook, inViewController: self)
        case NSIndexPath(forRow: 0, inSection: 1):
            SocialHelper.phonePrompt(number: "(+46) 70 857 01 80")
        case NSIndexPath(forRow: 1, inSection: 1):
            SocialHelper.emailPrompt(toRecipients: ["info@frostlight.se"], viewController: self)
        default:
            break
        }
    }

}
