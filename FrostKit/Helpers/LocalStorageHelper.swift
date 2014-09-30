//
//  LocalStorageHelper.swift
//  FrostKit
//
//  Created by James Barrow on 30/09/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit

//  File Structure
//  --------------
//
//  Documents
//  - Data
//  - Images
//  - User.data
//  Library
//  - Caches
//  - - Images
//  - - Data

public class LocalStorageHelper: NSObject {
    
    // MARK: - Paths and URL Methods
    
    public class func imagesReletivePath() -> String {
        return "Images/"
    }
    
    public class func dataReletivePath() -> String {
        return "Data/"
    }
    
    private class func userDataFilename() -> String {
        return "User.data"
    }
    
    private class func documentsURL() -> NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
    }
    
    private class func cachesURL() -> NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0] as NSURL
    }
    
    // MARK: - Directory Creation Methods
    
    private class func createDirectory(#url: NSURL) -> Bool {
        
        var error: NSError?
        let success = NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil, error: &error)
        if let anError = error {
            println(anError.localizedDescription)
        } else {
            println("Error: Folder not able to be creaed at URL \(url)")
        }
        
        return success
    }
    
    // MARK: - Save Methods
    
    private class func save(#data: AnyObject, baseURL: NSURL, reletivePath: String, fileName: String) -> Bool {
        
        var url = baseURL.URLByAppendingPathComponent(reletivePath)
        createDirectory(url: url)
        url = baseURL.URLByAppendingPathComponent(fileName)
        
        if let path = url.path {
            
            let success = NSKeyedArchiver.archiveRootObject(data, toFile: path)
            
            if success == false {
                println("Error: Can't save object to file at path: \(path)")
            }
            
            return success
        }
        
        return false
    }
    
    public class func saveToDocuments(#data: AnyObject, reletivePath: String, fileName: String) -> Bool {
        return save(data: data, baseURL: documentsURL(), reletivePath: reletivePath, fileName: fileName)
    }
    
    public class func saveToCaches(#data: AnyObject, reletivePath: String, fileName: String) -> Bool {
        return save(data: data, baseURL: cachesURL(), reletivePath: reletivePath, fileName: fileName)
    }
    
    public class func saveUserData(data: AnyObject) -> Bool {
        return save(data: data, baseURL: documentsURL(), reletivePath: "", fileName: userDataFilename())
    }
    
    // MARK: - Move Methods
    
    private class func move(#fromBaseURL: NSURL, toBaseURL: NSURL, reletivePath: String, fileName: String) -> Bool {
        
        let fromURL = fromBaseURL.URLByAppendingPathComponent(reletivePath).URLByAppendingPathComponent(fileName)
        let toURL = toBaseURL.URLByAppendingPathComponent(reletivePath).URLByAppendingPathComponent(fileName)
        
        var error: NSError?
        let success = NSFileManager.defaultManager().moveItemAtURL(fromURL, toURL: toURL, error: &error)
        if let anError = error {
            println(anError.localizedDescription)
        } else {
            println("Error: Can't move item from \(fromURL) to \(toURL)")
        }
        
        return success
    }
    
    public class func moveFromCachesToDocuments(#reletivePath: String, fileName: String) -> Bool {
        return move(fromBaseURL: cachesURL(), toBaseURL: documentsURL(), reletivePath: reletivePath, fileName: fileName)
    }
    
    public class func moveFromDocumentsToCaches(#reletivePath: String, fileName: String) -> Bool {
        return move(fromBaseURL: documentsURL(), toBaseURL: cachesURL(), reletivePath: reletivePath, fileName: fileName)
    }
    
    // MARK: - Load Methods
    
    private class func load(baseURL: NSURL, reletivePath: String, fileName: String) -> AnyObject? {
        
        let url = baseURL.URLByAppendingPathComponent(reletivePath).URLByAppendingPathComponent(fileName)
        
        if let path = url.path {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(path)
        }
        
        return nil
    }
    
    public class func loadFromDocuments(#reletivePath: String, fileName: String) -> AnyObject? {
        return load(documentsURL(), reletivePath: reletivePath, fileName: fileName)
    }
    
    public class func loadFromCaches(#reletivePath: String, fileName: String) -> AnyObject? {
        return load(cachesURL(), reletivePath: reletivePath, fileName: fileName)
    }
    
    public class func loadUserData() -> AnyObject? {
        return load(documentsURL(), reletivePath: "", fileName: userDataFilename())
    }
    
}
