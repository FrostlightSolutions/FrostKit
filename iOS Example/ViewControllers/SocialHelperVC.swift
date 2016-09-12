//
//  SocialHelperVC.swift
//  iOS Example
//
//  Created by James Barrow on 02/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
        case IndexPath(row: 0, section: 0):
            _ = SocialHelper.presentComposeViewController(serviceType: SLServiceTypeTwitter, inViewController: self)
        case IndexPath(row: 1, section: 0):
            _ = SocialHelper.presentComposeViewController(serviceType: SLServiceTypeFacebook, inViewController: self)
        case IndexPath(row: 0, section: 1):
            if let phoneURL = SocialHelper.phonePrompt("(+46) 70 857 01 80") {
                UIApplication.shared.openURL(phoneURL)
            } else {
                NSLog("Error: Could not create URL to prompt phone.")
            }
        case IndexPath(row: 1, section: 1):
            SocialHelper.emailPrompt(toRecipients: ["info@frostlight.se"], viewController: self)
        case IndexPath(row: 2, section: 1):
            SocialHelper.messagePrompt(recipients: ["(+46) 70 857 01 80"], viewController: self)
        default:
            break
        }
    }

}
