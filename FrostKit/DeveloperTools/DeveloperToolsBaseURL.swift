//
//  DeveloperToolsBaseURL.swift
//  FrostKit
//
//  Created by James Barrow on 13/01/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit

class DeveloperToolsBaseURL: UITableViewController, UITextFieldDelegate {
    
    var customURLTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let urlIndex = NSUserDefaults.standardUserDefaults().integerForKey("DeveloperToolsURLIndex")
        let indexPath = NSIndexPath(forRow: urlIndex, inSection: 0)
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        tableView(tableView, didSelectRowAtIndexPath: indexPath)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source and delegate methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DeveloperTools.shared.numberOfBaseURLs
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell?
        if indexPath.row == tableView.numberOfRowsInSection(0) - 1 {
            
            cell = tableView.dequeueReusableCellWithIdentifier("DeveloperToolsBaseURLCustomCell", forIndexPath: indexPath) as? UITableViewCell
            if let textField = cell?.viewWithTag(852) as? UITextField {
                textField.text = DeveloperTools.shared.baseURLFromIndex(indexPath.row)
                customURLTextField = textField
            }
            
        } else {
            
            cell = tableView.dequeueReusableCellWithIdentifier("DeveloperToolsBaseURLStandardCell", forIndexPath: indexPath) as? UITableViewCell
            cell?.textLabel?.text = DeveloperTools.shared.baseURLFromIndex(indexPath.row)
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            cell.accessoryType = .Checkmark
        }
        
        if indexPath.row == 2 {
            if customURLTextField?.isFirstResponder() == false {
                customURLTextField?.becomeFirstResponder()
            }
        } else {
            customURLTextField?.resignFirstResponder()
        }
        
        DeveloperTools.shared.setBaseURLIndex(indexPath.row)
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            cell.accessoryType = .None
        }
    }
    
    // MARK: - UITextField Delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        var section = 0
        if let currentIndexPath = tableView.indexPathForSelectedRow() {
            section = currentIndexPath.section
            tableView.deselectRowAtIndexPath(currentIndexPath, animated: true)
            tableView(tableView, didDeselectRowAtIndexPath: currentIndexPath)
        }
        
        let indexPath = NSIndexPath(forRow: 2, inSection: section)
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        tableView(tableView, didSelectRowAtIndexPath: indexPath)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        DeveloperTools.shared.setCustomURL(textField.text)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

}
