//
//  SocialHelper.swift
//  FrostKit
//
//  Created by James Barrow on 30/09/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit
import Social

public class SocialHelper: NSObject {
    public class func presentComposeViewController(serviceType: String, initialText: String? = nil, urls: NSArray? = nil, images: NSArray? = nil, inViewController viewController: UIViewController, animated: Bool = true) {
        
        if SLComposeViewController.isAvailableForServiceType(serviceType) {
            
            let composeViewController = SLComposeViewController(forServiceType: serviceType)
            composeViewController.setInitialText(initialText)
            
            if let urlsArray = urls {
                for object in urlsArray {
                    if let url = object as? NSURL {
                        composeViewController.addURL(url)
                    }
                }
            }
            
            if let imagesArray = images {
                for object in imagesArray {
                    if let image = object as? UIImage {
                        composeViewController.addImage(image)
                    }
                }
            }
            
            viewController.presentViewController(composeViewController, animated: animated, completion: nil)
            
        } else {
            // TODO: Handle service unavailability
            println("Error: Social Service Unavailable!")
        }
    }
}
