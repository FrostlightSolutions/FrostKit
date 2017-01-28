//
//  ContentManager.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright © 2014 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation

///
/// The Content Manager is a class that checks all content saved into local storage. It tracks when they were added/accessed from LocalStorage or ImageCache.
/// If an item has not been accessed in 2 weeks (by default) they will be automatically deleted on launch.
/// 
/// To activate this class, call `checkContentMetadata()` in `-application:willFinishLaunchingWithOptions:` to check all the managed files.
///
public class ContentManager {
    
    // A dictioary holding the metadata for all managed objects, where the key is an absolute path and the value is the date.
    private lazy var contentMetadata = [String: Date]()
    
    private static var maxSavedTimeInSeconds: TimeInterval {
        return Date.weekInSeconds() * 2
    }
    
    // MARK: - Singleton
    
    /**
    The shared content manager object.
    */
    public static let shared = ContentManager()
    
    // MARK: - Content Management Methods
    
    /**
    Checks though all of the managed content metadata. If an item has not been accessed for more than 2 weeks then it is removed from the local storage.
    */
    public class func checkContentMetadata() {
        
        guard shared.contentMetadata.count > 0 else {
#if DEBUG
            NSLog("Check of content metadata items not needed, as there are no items managed.")
#endif
            return
        }
        
        DispatchQueue.global().async(group: nil, qos: .default, flags: []) {
            
#if DEBUG
            let start = NSDate.timeIntervalSinceReferenceDate
#endif
            
            var metadataToRemove = [String]()
            
            for (key, refDate) in shared.contentMetadata {
                
                let refTimeInterval = refDate.timeIntervalSinceReferenceDate
                let timeInterval = NSDate.timeIntervalSinceReferenceDate
                
                if (timeInterval - refTimeInterval) > maxSavedTimeInSeconds {
                    metadataToRemove.append(key)
                }
            }
            
            if metadataToRemove.count > 0 {
                
                for path in metadataToRemove {
                    
                    let url = URL(fileURLWithPath: path)
                    
                    DispatchQueue.main.async {
                        do {
                            try LocalStorage.remove(absoluteURL: url)
                        } catch let error {
                            NSLog("Error: Unable to remove managed item at URL \(url)\nWith error: \(error.localizedDescription)\n\(error)")
                        }
                    }
                }
            }
            
#if DEBUG
            let finish = NSDate.timeIntervalSinceReferenceDate
            NSLog("Check of \(shared.contentMetadata.count) content metadata items complete in \(finish - start) seconds. Removed \(metadataToRemove.count) items.")
#endif
        }
    }
    
    /**
    Creates or updates metadata for an object at an absolute URL.
     
    - parameter url:    The absolute URL of the item.
    */
    public class func save(url: URL) {
        save(path: url.path)
    }
    
    /**
    Creates or updates metadata for an object at an absolute path.
     
    - parameter path:    The absolute path of the item.
    */
    public class func save(path: String) {
        shared.contentMetadata[path] = Date()
    }
    
    /**
    Removed metadata for an object at an absolute URL.
     
    - parameter url:    The absolute URL of the item.
    */
    public class func remove(url: URL) {
        remove(path: url.path)
    }
    
    /**
    Removed metadata for an object at an absolute path.
     
    - parameter path:    The absolute path of the item.
    */
    public class func remove(path: String) {
        shared.contentMetadata.removeValue(forKey: path)
    }
}
