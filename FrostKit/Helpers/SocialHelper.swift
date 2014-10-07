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

public class SocialHelper: NSObject, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate {
    
    private enum AlertViewTags: Int {
        case EmailPrompt
        case MessagePrompt
    }
    
    private var toRecipients: [String] = []
    private var ccRecipients: [String] = []
    private var bccRecipients: [String] = []
    private var subject: String = ""
    private var messageBody: String = ""
    private var isBodyHTML: Bool = false
    private var emailAttachments: [(data: NSData, mimeType: String, fileName: String)] = []
    private var messgaeAttachments: [(attachmentURL: NSURL, alternateFilename: String)] = []
    private var viewController: UIViewController?
    private var animated: Bool = true
    
    // MARK: - Singleton
    
    // For use with delegate methods only, hence private NOT public
    private class var shared: SocialHelper {
        struct Singleton {
            static let instance : SocialHelper = SocialHelper()
        }
        return Singleton.instance
    }
    
    override init() { }
    
    private func clear() {
        
        toRecipients = []
        ccRecipients = []
        bccRecipients = []
        subject = ""
        messageBody = ""
        isBodyHTML = false
        emailAttachments = []
        messgaeAttachments = []
        viewController = nil
        animated = true
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
        
        let hasPlusPrefix = number.rangeOfString("+")
        
        let characterSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        let componentsArray = number.componentsSeparatedByCharactersInSet(characterSet)
        var parsedNumber = join("", componentsArray)
        
        if hasPlusPrefix != nil {
            parsedNumber = "+".stringByAppendingString(parsedNumber)
        }
        
        let urlString = NSString(format: "telprompt://%@", parsedNumber)
        let url = NSURL(string: urlString)
        UIApplication.sharedApplication().openURL(url)
    }
    
    public class func emailPrompt(#toRecipients: [String], ccRecipients: [String] = [], bccRecipients: [String] = [], subject: String = "", messageBody: String = "", isBodyHTML: Bool = false, attachments: [(data: NSData, mimeType: String, fileName: String)] = [], viewController: UIViewController, animated: Bool = true) {
        
        if MFMailComposeViewController.canSendMail() {
            
            let emailsString = join(", ", toRecipients)
            
            if NSClassFromString("UIAlertController") != nil {
                
                let alertController = UIAlertController(title: emailsString, message: nil, preferredStyle: .Alert)
                alertController.view.tintColor = FrostKit.shared.tintColor
                let cancelAlertAction = UIAlertAction(title: FKLocalizedString("CANCEL"), style: .Cancel) { (action) -> Void in
                    alertController.dismissViewControllerAnimated(true, completion: nil)
                }
                alertController.addAction(cancelAlertAction)
                let openAlertAction = UIAlertAction(title: FKLocalizedString("EMAIL"), style: .Default) { (action) -> Void in
                    
                    SocialHelper.presentMailComposeViewController(toRecipients: toRecipients, ccRecipients: ccRecipients, bccRecipients: bccRecipients, subject: subject, messageBody: messageBody, isBodyHTML: isBodyHTML, attachments: attachments, viewController: viewController, animated: animated)
                }
                
                alertController.addAction(openAlertAction)
                viewController.presentViewController(alertController, animated: true, completion: nil)

            } else {
            
                shared.toRecipients = toRecipients
                shared.ccRecipients = ccRecipients
                shared.bccRecipients = bccRecipients
                shared.subject = subject
                shared.messageBody = messageBody
                shared.isBodyHTML = isBodyHTML
                shared.emailAttachments = attachments
                shared.viewController = viewController
                shared.animated = animated
                
                let alertView = UIAlertView(title: emailsString, message: "", delegate: SocialHelper.shared, cancelButtonTitle: FKLocalizedString("CANCEL"), otherButtonTitles: FKLocalizedString("EMAIL"))
                alertView.tintColor = FrostKit.shared.tintColor
                alertView.tag = AlertViewTags.EmailPrompt.toRaw()
                alertView.show()
                
            }
            
        } else {
            // TODO: Handle eamil service unavailability
            println("Error: Email Service Unavailable!")
        }
    }
    
    private class func presentMailComposeViewController(#toRecipients: [String], ccRecipients: [String], bccRecipients: [String], subject: String, messageBody: String, isBodyHTML: Bool, attachments: [(data: NSData, mimeType: String, fileName: String)], viewController: UIViewController, animated: Bool) {
        
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = SocialHelper.shared
        mailVC.setSubject(subject)
        mailVC.setToRecipients(toRecipients)
        mailVC.setCcRecipients(ccRecipients)
        mailVC.setBccRecipients(bccRecipients)
        mailVC.setMessageBody(messageBody, isHTML: isBodyHTML)
        
        for (data, mimeType, fileName) in attachments {
            mailVC.addAttachmentData(data, mimeType: mimeType, fileName: fileName)
        }
        
        viewController.presentViewController(mailVC, animated: animated, completion: nil)
    }
    
    public class func messagePrompt(#recipients: [String], subject: String = "", body: String = "", attachments: [(attachmentURL: NSURL, alternateFilename: String)] = [], viewController: UIViewController, animated: Bool = true) {
        
        if MFMessageComposeViewController.canSendText() {
            
            let recipientsString = join(", ", recipients)
            
            if NSClassFromString("UIAlertController") != nil {
                
                let alertController = UIAlertController(title: recipientsString, message: nil, preferredStyle: .Alert)
                alertController.view.tintColor = FrostKit.shared.tintColor
                let cancelAlertAction = UIAlertAction(title: FKLocalizedString("CANCEL"), style: .Cancel) { (action) -> Void in
                    alertController.dismissViewControllerAnimated(true, completion: nil)
                }
                alertController.addAction(cancelAlertAction)
                let openAlertAction = UIAlertAction(title: FKLocalizedString("MESSAGE"), style: .Default) { (action) -> Void in
                    
                    SocialHelper.presentMessageComposeViewController(recipients: recipients, subject: subject, body: body, attachments: attachments, viewController: viewController, animated: animated)
                }
                
                alertController.addAction(openAlertAction)
                viewController.presentViewController(alertController, animated: true, completion: nil)
                
            } else {
                
                shared.toRecipients = recipients
                shared.subject = subject
                shared.messageBody = body
                shared.messgaeAttachments = attachments
                shared.viewController = viewController
                shared.animated = animated
                
                let alertView = UIAlertView(title: recipientsString, message: "", delegate: SocialHelper.shared, cancelButtonTitle: FKLocalizedString("CANCEL"), otherButtonTitles: FKLocalizedString("MESSAGE"))
                alertView.tintColor = FrostKit.shared.tintColor
                alertView.tag = AlertViewTags.EmailPrompt.toRaw()
                alertView.show()
                
            }
            
        } else {
            // TODO: Handle message service unavailability
            println("Error: Message Service Unavailable!")
        }
    }
    
    private class func presentMessageComposeViewController(#recipients: [String], subject: String, body: String, attachments: [(attachmentURL: NSURL, alternateFilename: String)], viewController: UIViewController, animated: Bool) {
        
        let messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = SocialHelper.shared
        messageVC.recipients = recipients
        
        if MFMessageComposeViewController.canSendSubject() {
            messageVC.subject = subject
        }
        
        if MFMessageComposeViewController.canSendAttachments() {
            for (attachmentURL, alternateFilename) in attachments {
                messageVC.addAttachmentURL(attachmentURL, withAlternateFilename: alternateFilename)
            }
        }
        
        messageVC.body = body
        
        viewController.presentViewController(messageVC, animated: animated, completion: nil)
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
        
        clear()
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - MFMessageComposeViewControllerDelegate Methods
    
    public func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        
        switch result.value {
        case MessageComposeResultCancelled.value:
            println("Message cancelled")
        case MessageComposeResultSent.value:
            println("Message sent")
        case MessageComposeResultFailed.value:
            println("Message failed")
        default:
            break
        }
        
        clear()
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UIAlerViewDelegate Methods
    
    public func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        switch (alertView.tag, buttonIndex) {
        case (AlertViewTags.EmailPrompt.toRaw(), 1):
            SocialHelper.presentMailComposeViewController(toRecipients: toRecipients, ccRecipients: ccRecipients, bccRecipients: bccRecipients, subject: subject, messageBody: messageBody, isBodyHTML: isBodyHTML, attachments: emailAttachments, viewController: viewController!, animated: animated)
        case (AlertViewTags.MessagePrompt.toRaw(), 1):
            SocialHelper.presentMessageComposeViewController(recipients: toRecipients, subject: subject, body: messageBody, attachments: messgaeAttachments, viewController: viewController!, animated: animated)
        default:
            break
        }
    }
    
}
