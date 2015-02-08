//
//  ContentManager.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

///
/// The Content Manager is a class that checks all content saved into local storage. It tracks when they were added/accessed from LocalStorage or ImageCache.
/// If an item has not been accessed in 2 weeks (by default) they will be automatically deleted on launch.
/// 
/// To activate this class, call `checkContentMetadata()` in `-application:willFinishLaunchingWithOptions:` to check all the managed files.
///
public class ContentManager: NSObject {
    
    // A dictioary holding the metadata for all managed objects, where the key is an absolute path and the value is the date.
    private let contentMetadata = NSMutableDictionary()
    
    private class func maxSavedTimeInSeconds() -> NSTimeInterval {
        return NSDate.weekInSeconds() * 2.0
    }
    
    // MARK: - Singleton
    
    /**
    Returns the shared content manager object.
    
    :returns: The shared content manager object.
    */
    public class var shared: ContentManager {
        struct Singleton {
            static let instance : ContentManager = ContentManager()
        }
        return Singleton.instance
    }
    
    // MARK: - Content Management Methods
    
    /**
    Checks though all of the managed content metadata. If an item has not been accessed for more than 2 weeks then it is removed from the local storage.
    */
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
                NSLog("Check of \(shared.contentMetadata.count) content metadata items complete in \(finish()-start()) seconds. Removed \(metadataToRemove.count) items.")
            #endif
        }
    }
    
    /**
    Creates or updates metadata for an object at an absolute URL.
    
    :param: absoluteURL    The absolute URL of the item.
    */
    public class func saveContentMetadata(#absoluteURL: NSURL) {
        if let absolutePath = absoluteURL.path {
            saveContentMetadata(absolutePath: absolutePath)
        }
    }
    
    /**
    Creates or updates metadata for an object at an absolute path.
    
    :param: absolutePath    The absolute path of the item.
    */
    public class func saveContentMetadata(#absolutePath: String) {
        shared.contentMetadata.setObject(NSDate().copy(), forKey: absolutePath)
    }
    
    /**
    Removed metadata for an object at an absolute URL.
    
    :param: absoluteURL    The absolute URL of the item.
    */
    public class func removeContentMetadata(#absoluteURL: NSURL) {
        if let absolutePath = absoluteURL.path {
            removeContentMetadata(absolutePath: absolutePath)
        }
    }
    
    /**
    Removed metadata for an object at an absolute path.
    
    :param: absolutePath    The absolute path of the item.
    */
    public class func removeContentMetadata(#absolutePath: String) {
        shared.contentMetadata.removeObjectForKey(absolutePath)
    }
    
}
