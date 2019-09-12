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
@available(iOS, deprecated: 13.0, message: "This class will be removed in v2.0.0 of FrostKit.")
public class ContentManager {
    
    /// A dictioary holding the metadata for all managed objects, where the key is an absolute path and the value is the date.
    private lazy var contentMetadata = [String: Date]()
    /// The maximum amount of time an item should be kept in seconds before being removed.
    private static var maxSavedTimeInSeconds: TimeInterval { Date.weekInSeconds * 2 }
    /// A queue that processes each task of saving, removingor checking metadata in a concurrent manner.
    private let queue = DispatchQueue(label: "com.Frostlight.FrostKit.ContentManager.Queue", attributes: .concurrent)
    
    // MARK: - Singleton
    
    /// The shared content manager object.
    public static let shared = ContentManager()
    
    // MARK: - Content Management Methods
    
    /// Checks though all of the managed content metadata. If an item has not been accessed for more than 2 weeks then it is removed from the local storage.
    public class func checkContentMetadata() {
        
        guard shared.contentMetadata.count > 0 else {
#if DEBUG
            DLog("Check of content metadata items not needed, as there are no items managed.")
#endif
            return
        }
        
        shared.queue.sync(flags: .barrier) {
            
#if DEBUG
            let start = NSDate.timeIntervalSinceReferenceDate
#endif
            
            var metadataToRemove = [String]()
            
            let timeInterval = NSDate.timeIntervalSinceReferenceDate
            for (key, refDate) in shared.contentMetadata where (timeInterval - refDate.timeIntervalSinceReferenceDate) > maxSavedTimeInSeconds {
                metadataToRemove.append(key)
            }
            
            if metadataToRemove.count > 0 {
                
                for path in metadataToRemove {
                    
                    let url = URL(fileURLWithPath: path)
                    
                    DispatchQueue.main.async {
                        do {
                            try LocalStorage.remove(absoluteURL: url)
                        } catch let error {
                            DLog("Error: Unable to remove managed item at URL \(url)\nWith error: \(error.localizedDescription)")
                        }
                    }
                }
            }
            
#if DEBUG
            let finish = NSDate.timeIntervalSinceReferenceDate
            DLog("Check of \(shared.contentMetadata.count) content metadata items complete in \(finish - start) seconds. Removed \(metadataToRemove.count) items.")
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
        
        shared.queue.async(flags: .barrier) {
            shared.contentMetadata[path] = Date()
        }
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
        
        shared.queue.async(flags: .barrier) {
            shared.contentMetadata.removeValue(forKey: path)
        }
    }
}
