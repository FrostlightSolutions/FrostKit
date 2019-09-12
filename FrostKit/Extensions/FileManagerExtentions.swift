//
//  FileManagerExtentions.swift
//  FrostKit
//
//  Created by James Barrow on 2019-06-28.
//  Copyright © 2019 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation

public extension FileManager {
    
    // MARK: - Paths and URL Methods
    
    /// Document directory.
    static let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
    /// Caches Directory.
    static let cachesDirectory = FileManager.SearchPathDirectory.cachesDirectory
    
    /// URL for the documents directory.
    class func documentsURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    /// URL for the caches directory.
    class func cachesURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    /// URL for the shared container if available.
    /// - Parameter groupIdentifier: The group identifier for the shared container.
    class func sharedContainerURL(groupIdentifier: String) -> URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
    }
    
}
