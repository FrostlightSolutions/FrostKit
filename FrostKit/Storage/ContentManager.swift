//
//  ContentManager.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit

public class ContentManager: NSObject {
    
    private let contentMetadata = NSMutableDictionary()
    
    private class func maxSavedTimeInSeconds() -> NSTimeInterval {
        return NSDate.weekInSeconds() * 2.0
    }
    
    // MARK: - Singleton
    
    public class var shared: ContentManager {
        struct Singleton {
            static let instance : ContentManager = ContentManager()
        }
        return Singleton.instance
    }
    
    // MARK: - Content Management Methods
    
    public class func saveContentMetadata(#absoluteURL: NSURL) {
        if let absolutePath = absoluteURL.path {
            saveContentMetadata(absolutePath: absolutePath)
        }
    }
    
    public class func saveContentMetadata(#absolutePath: String) {
        shared.contentMetadata.setObject(NSDate().copy(), forKey: absolutePath)
    }
    
    public class func removeContentMetadata(#absoluteURL: NSURL) {
        if let absolutePath = absoluteURL.path {
            removeContentMetadata(absolutePath: absolutePath)
        }
    }
    
    public class func removeContentMetadata(#absolutePath: String) {
        shared.contentMetadata.removeObjectForKey(absolutePath)
    }
    
    public class func checkContentMetadata() {
        
        if shared.contentMetadata.count > 0 {
            
            #if DEBUG
                let start = NSDate.timeIntervalSinceReferenceDate
            #endif
            
            let metadataToRemove = NSMutableArray()
            
            for (key, object) in shared.contentMetadata {
                
                let refDate = object as NSDate
                let refTimeInterval = refDate.timeIntervalSinceReferenceDate
                let timeInterval = NSDate().timeIntervalSinceReferenceDate
                
                if (timeInterval - refTimeInterval) > maxSavedTimeInSeconds() {
                    metadataToRemove.addObject(key)
                }
            }
            
            if metadataToRemove.count > 0 {
                for object in metadataToRemove {
                    if let absoluteURL = object as? NSURL {
                        LocalStorage.remove(absoluteURL: absoluteURL)
                    }
                }
            }
            
            #if DEBUG
                let finish = NSDate.timeIntervalSinceReferenceDate
                println("Check of \(shared.contentMetadata.count) content metadata items complete in \(finish-start) seconds. Removed \(metadataToRemove.count) items.")
            #endif
        }
    }
    
}
