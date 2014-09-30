//
//  SocialHelper.swift
//  FrostKit
//
//  Created by James Barrow on 30/09/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit
import Social
import MessageUI

public class SocialHelper: NSObject, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate {
    
    // MARK: - Singleton
    
    // For use with delegate methods only, hence private NOT public
    private class var shared: SocialHelper {
    struct Singleton {
        static let instance : SocialHelper = SocialHelper()
        }
        return Singleton.instance
    }
    
    // MARK: - Scocial Methods
    
    public class func presentComposeViewController(serviceType: String, initialText: String? = nil, urls: [NSURL]? = nil, images: [UIImage]? = nil, inViewController viewController: UIViewController, animated: Bool = true) {
        
        if SLComposeViewController.isAvailableForServiceType(serviceType) {
            
            let composeViewController = SLComposeViewController(forServiceType: serviceType)
            composeViewController.setInitialText(initialText)
            
            if let urlsArray = urls {
                for url in urlsArray {
                    composeViewController.addURL(url)
                }
            }
            
            if let imagesArray = images {
                for image in imagesArray {
                    composeViewController.addImage(image)
                }
            }
            
            viewController.presentViewController(composeViewController, animated: animated, completion: nil)
            
        } else {
            // TODO: Handle social service unavailability
            println("Error: Social Service Unavailable!")
        }
    }
    
    // MARK: - Prompt Methods
    
    public class func phonePrompt(#number: String) {
        
        let hasPlusPrefix = number.hasPrefix("+")
        
        let characterSet = NSCharacterSet.alphanumericCharacterSet().invertedSet
        let componentsArray = number.componentsSeparatedByCharactersInSet(characterSet)
        var parsedNumber = join("", componentsArray)
        
        if hasPlusPrefix == true {
            parsedNumber = parsedNumber.stringByAppendingString("+")
        }
        
        let urlString = NSString(format: "telprompt://%@", parsedNumber)
        let url = NSURL(string: urlString)
        UIApplication.sharedApplication().openURL(url)
    }
    
    public class func emailPrompt(#toRecipients: [String], ccRecipients: [String]? = nil, bccRecipients: [String]? = nil, subject: String? = nil, messageBody: String? = nil, isBodyHTML: Bool = false, attachments: [(data: NSData, mimeType: String, fileName: String)]? = nil, animated: Bool = true) {
        
        if MFMailComposeViewController.canSendMail() {
            
            if let viewController = UIApplication.sharedApplication().keyWindow.rootViewController {
                
                let emailsString = join(", ", toRecipients)
                let alertController = UIAlertController(title: emailsString, message: nil, preferredStyle: .Alert)
                let cancelAlertAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .Cancel) { (action) -> Void in
                    alertController.dismissViewControllerAnimated(true, completion: nil)
                }
                alertController.addAction(cancelAlertAction)
                let openAlertAction = UIAlertAction(title: NSLocalizedString("EMAIL", comment: "Email"), style: .Default) { (action) -> Void in
                    
                    let mailVC = MFMailComposeViewController()
                    mailVC.delegate = SocialHelper.shared
                    mailVC.setSubject(subject)
                    mailVC.setToRecipients(toRecipients)
                    mailVC.setCcRecipients(ccRecipients)
                    mailVC.setBccRecipients(bccRecipients)
                    mailVC.setMessageBody(messageBody, isHTML: isBodyHTML)
                    
                    if let attachmentsArray = attachments {
                        for (data, mimeType, fileName) in attachmentsArray {
                            mailVC.addAttachmentData(data, mimeType: mimeType, fileName: fileName)
                        }
                    }
                    
                    viewController.presentViewController(mailVC, animated: animated, completion: nil)
                }
                
                alertController.addAction(openAlertAction)
                viewController.presentViewController(alertController, animated: true, completion: nil)
            }
        } else {
            // TODO: Handle eamil service unavailability
            println("Error: Email Service Unavailable!")
        }
    }
    
    // MARK: - MFMailComposeViewControllerDelegate Methods
    
    public func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        
        switch result.value {
        case MFMailComposeResultCancelled.value:
            println("Email cancelled")
        case MFMailComposeResultSaved.value:
            println("Email saved")
        case MFMailComposeResultSent.value:
            println("Email sent")
        case MFMailComposeResultFailed.value:
            println("Email sent failure: \(error.localizedDescription)")
        default:
            break
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
