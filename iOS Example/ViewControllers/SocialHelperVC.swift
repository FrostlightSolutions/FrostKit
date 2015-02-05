//
//  SocialHelperVC.swift
//  iOS Example
//
//  Created by James Barrow on 02/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit
import Social
import FrostKit

class SocialHelperVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = true
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
            if let phoneURL = SocialHelper.phonePromptFormattedURL(number: "(+46) 70 857 01 80") {
                UIApplication.sharedApplication().openURL(phoneURL)
            } else {
                NSLog("Error: Could not create URL to prompt phone.")
            }
        case NSIndexPath(forRow: 1, inSection: 1):
            SocialHelper.emailPrompt(toRecipients: ["info@frostlight.se"], viewController: self)
        case NSIndexPath(forRow: 2, inSection: 1):
            SocialHelper.messagePrompt(recipients: ["(+46) 70 857 01 80"], viewController: self)
        default:
            break
        }
    }

}
