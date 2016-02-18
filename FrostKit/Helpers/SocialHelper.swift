//
//  SocialHelper.swift
//  FrostKit
//
//  Created by James Barrow on 30/09/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit
import Social
import MessageUI

/// 
/// The social helper class allows quick access to some social aspects, such as presenting an email/message. This class has a private singleton it used for dleegate methods, so that every presenting view controller does not have to impliment them seperately.
///
public class SocialHelper: NSObject, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    private enum AlertViewTags: Int {
        case EmailPrompt
        case MessagePrompt
    }
    
    // MARK: - Singleton
    
    // For use with delegate methods only, hence private NOT public
    private class var shared: SocialHelper {
        struct Singleton {
            static let instance : SocialHelper = SocialHelper()
        }
        return Singleton.instance
    }
    
    override private init() {
        super.init()
    }
    
    // MARK: - Scocial Methods
    
    /**
    Presents a compose view controller with the details passed in.
    
    - parameter serviceType:    The type of service type to present. For a list of possible values, see Service Type Constants.
    - parameter initialText:    The initial text to show in the `SLComposeViewController`.
    - parameter urls:           The URLs to attach to the `SLComposeViewController`.
    - parameter images:         The images to attach to the `SLComposeViewController`.
    - parameter viewController: The view controller to present the `SLComposeViewController` in.
    - parameter animated:       If the presentation should be animated or not.
    
    - returns: Returns `false` if there is an issue or the service is unavailable, otherwise `true`.
    */
    public class func presentComposeViewController(serviceType: String, initialText: String? = nil, urls: [NSURL]? = nil, images: [UIImage]? = nil, inViewController viewController: UIViewController, animated: Bool = true) -> Bool {
        
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
            NSLog("Error: Social Service Unavailable!")
            return false
        }
        
        return true
    }
    
    // MARK: - Prompt Methods
    
    /**
    Returns a NSURL to call with `openURL(_:)` in `UIApplication` parsed from a number string.
    
    Note: `openURL(_:)` can not be called directly within a Framework so that has to be done manually inside the main application.
    
    - parameter number: The number to parse in to create the URL.
    
    - returns: The URL of the parsed phone number, prefixed with `telprompt://`.
    */
    public class func phonePromptFormattedURL(number number: String) -> NSURL? {
        let hasPlusPrefix = number.rangeOfString("+")
        
        let characterSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        let componentsArray = number.componentsSeparatedByCharactersInSet(characterSet)
        var parsedNumber = componentsArray.joinWithSeparator("")
        
        if hasPlusPrefix != nil {
            parsedNumber = "+".stringByAppendingString(parsedNumber)
        }
        
        return NSURL(string: "telprompt://\(parsedNumber)")
    }
    
    /**
    Creates a prompt for an email with the following parameters to pass into the `MFMailComposeViewController`.
    
    - parameter toRecipients:   The email addresses of the recipients of the email.
    - parameter ccRecipients:   The email addresses of the CC recipients of the email.
    - parameter bccRecipients:  The email addresses of the BCC recipients of the email.
    - parameter subject:        The subject of the email.
    - parameter messageBody:    The main body of the email.
    - parameter isBodyHTML:     Tells the `MFMailComposeViewController` if the message body is HTML.
    - parameter attachments:    The attachments to add to the email, passed in as a tuple of data, mime type and the file name.
    - parameter viewController: The view controller to present the `MFMailComposeViewController` in.
    - parameter animated:       If the presentation should be animated or not.
    */
    public class func emailPrompt(toRecipients toRecipients: [String], ccRecipients: [String]? = nil, bccRecipients: [String]? = nil, subject: String = "", messageBody: String = "", isBodyHTML: Bool = false, attachments: [(data: NSData, mimeType: String, fileName: String)]? = nil, viewController: UIViewController, animated: Bool = true) {
        
        if MFMailComposeViewController.canSendMail() {
            
            let emailsString = toRecipients.joinWithSeparator(", ")
            
            let alertController = UIAlertController(title: emailsString, message: nil, preferredStyle: .Alert)
            alertController.view.tintColor = FrostKit.tintColor
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
            // TODO: Handle eamil service unavailability
            NSLog("Error: Email Service Unavailable!")
        }
    }
    
    public class func presentMailComposeViewController(toRecipients toRecipients: [String]? = nil, ccRecipients: [String]? = nil, bccRecipients: [String]? = nil, subject: String = "", messageBody: String = "", isBodyHTML: Bool = false, attachments: [(data: NSData, mimeType: String, fileName: String)]? = nil, viewController: UIViewController, animated: Bool) {
        
        let mailVC = MFMailComposeViewController()
        mailVC.view.tintColor = FrostKit.tintColor
        mailVC.mailComposeDelegate = SocialHelper.shared
        mailVC.setSubject(subject)
        mailVC.setToRecipients(toRecipients)
        mailVC.setCcRecipients(ccRecipients)
        mailVC.setBccRecipients(bccRecipients)
        mailVC.setMessageBody(messageBody, isHTML: isBodyHTML)
        
        if attachments != nil {
            for (data, mimeType, fileName) in attachments! {
                mailVC.addAttachmentData(data, mimeType: mimeType, fileName: fileName)
            }
        }
        
        viewController.presentViewController(mailVC, animated: animated, completion: nil)
    }
    
    /**
    Creates a prompt for a message with the following parameters to pass into the `MFMessageComposeViewController`.
    
    - parameter recipients:     The recipients of the message.
    - parameter subject:        The subject of the message.
    - parameter body:           The main body of the message.
    - parameter attachments:    The attachments to add to the message, passed in as a tuple of attachment URL and alternate filename.
    - parameter viewController: The view controller to present the `MFMailComposeViewController` in.
    - parameter animated:       If the presentation should be animated or not.
    */
    public class func messagePrompt(recipients recipients: [String], subject: String = "", body: String = "", attachments: [(attachmentURL: NSURL, alternateFilename: String)] = [], viewController: UIViewController, animated: Bool = true) {
        
        if MFMessageComposeViewController.canSendText() {
            
            let recipientsString = recipients.joinWithSeparator(", ")
            
            let alertController = UIAlertController(title: recipientsString, message: nil, preferredStyle: .Alert)
            alertController.view.tintColor = FrostKit.tintColor
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
            // TODO: Handle message service unavailability
            NSLog("Error: Message Service Unavailable!")
        }
    }
    
    private class func presentMessageComposeViewController(recipients recipients: [String]? = nil, subject: String? = nil, body: String? = nil, attachments: [(attachmentURL: NSURL, alternateFilename: String)]? = nil, viewController: UIViewController, animated: Bool) {
        
        let messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = SocialHelper.shared
        messageVC.recipients = recipients
        
        if MFMessageComposeViewController.canSendSubject() {
            messageVC.subject = subject
        }
        
        if MFMessageComposeViewController.canSendAttachments() && attachments != nil {
            for (attachmentURL, alternateFilename) in attachments! {
                messageVC.addAttachmentURL(attachmentURL, withAlternateFilename: alternateFilename)
            }
        }
        
        messageVC.body = body
        
        viewController.presentViewController(messageVC, animated: animated, completion: nil)
    }
    
    // MARK: - MFMailComposeViewControllerDelegate Methods
    
    public func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            NSLog("Email cancelled")
        case MFMailComposeResultSaved.rawValue:
            NSLog("Email saved")
        case MFMailComposeResultSent.rawValue:
            NSLog("Email sent")
        case MFMailComposeResultFailed.rawValue:
            if let anError = error {
                NSLog("Email send failed: \(anError.localizedDescription)\n\(error)")
            } else {
                NSLog("Email send failed!")
            }
        default:
            break
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - MFMessageComposeViewControllerDelegate Methods
    
    public func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
        switch result.rawValue {
        case MessageComposeResultCancelled.rawValue:
            NSLog("Message cancelled")
        case MessageComposeResultSent.rawValue:
            NSLog("Message sent")
        case MessageComposeResultFailed.rawValue:
            NSLog("Message failed")
        default:
            break
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
