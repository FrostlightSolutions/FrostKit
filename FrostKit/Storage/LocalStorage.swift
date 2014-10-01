//
//  LocalStorage.swift
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
//  - Images        Perminant Images
//  - Data          Perminant Documents and Data
//  - User.data     User object (NSObject conforming to NSCoding)
//  Library
//  - Caches
//  - - Images      Store Temporary Images
//  - - Data        Store Temporary Documents and Data
//
//  NOTE:   Anything stored in Caches has the ability to be deleted when the app is not active (never during),
//          so make sure only data that can be re-downloaded get stored here.
//

public enum Location: UInt {
    case UserData
    static let DocumentDirectory = NSSearchPathDirectory.DocumentDirectory
    static let CachesDirectory = NSSearchPathDirectory.CachesDirectory
}

public class LocalStorage: NSObject {
    
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
    
    internal class func baseURL(#directory: NSSearchPathDirectory) -> NSURL? {
        switch directory {
        case .DocumentDirectory:
            return documentsURL()
        case .CachesDirectory:
            return cachesURL()
        default:
            println("Error: Directory \"\(directory)\" requested is not supported!")
            return nil
        }
    }
    
    internal class func absoluteURL(#baseURL: NSURL, reletivePath: String, fileName: String? = nil) -> NSURL {
        
        var url = baseURL.URLByAppendingPathComponent(reletivePath)
        if let name = fileName {
            url = url.URLByAppendingPathComponent(name)
        }
        return url
    }
    
    // MARK: - Directory Creation Methods
    
    private class func createDirectory(#url: NSURL) -> Bool {
        
        var error: NSError?
        let success = NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil, error: &error)
        if success == false {
            if let anError = error {
                println(anError.localizedDescription)
            } else {
                println("Error: Directory not able to be created at URL \(url)")
            }
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
        
        let fromURL = absoluteURL(baseURL: fromBaseURL, reletivePath: reletivePath, fileName: fileName)
        let toURL = absoluteURL(baseURL: toBaseURL, reletivePath: reletivePath, fileName: fileName)
        
        var error: NSError?
        let success = NSFileManager.defaultManager().moveItemAtURL(fromURL, toURL: toURL, error: &error)
        if success == false {
            if let anError = error {
                println(anError.localizedDescription)
            } else {
                println("Error: Can't move item from \(fromURL) to \(toURL)")
            }
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
    
    private class func load(#baseURL: NSURL, reletivePath: String, fileName: String) -> AnyObject? {
        
        let url = absoluteURL(baseURL: baseURL, reletivePath: reletivePath, fileName: fileName)
        
        if let path = url.path {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(path)
        }
        
        return nil
    }
    
    public class func loadFromDocuments(#reletivePath: String, fileName: String) -> AnyObject? {
        return load(baseURL: documentsURL(), reletivePath: reletivePath, fileName: fileName)
    }
    
    public class func loadFromCaches(#reletivePath: String, fileName: String) -> AnyObject? {
        return load(baseURL: cachesURL(), reletivePath: reletivePath, fileName: fileName)
    }
    
    public class func loadImageFromDocuments(#reletivePath: String, fileName: String) -> UIImage? {
        return loadFromDocuments(reletivePath: reletivePath, fileName: fileName) as? UIImage
    }
    
    public class func loadImageFromCaches(#reletivePath: String, fileName: String) -> UIImage? {
        return loadFromCaches(reletivePath: reletivePath, fileName: fileName) as? UIImage
    }
    
    public class func loadUserData() -> AnyObject? {
        return load(baseURL: documentsURL(), reletivePath: "", fileName: userDataFilename())
    }
    
    // MARK: - Delete Methods
    
    private class func remove(#baseURL: NSURL, reletivePath: String, fileName: String? = nil) -> Bool {
        
        let url = absoluteURL(baseURL: baseURL, reletivePath: reletivePath, fileName: fileName)
        
        var error: NSError?
        let success = NSFileManager.defaultManager().removeItemAtURL(url, error: &error)
        if success == false {
            if let anError = error {
                println(anError.localizedDescription)
            } else {
                println("Error: Directory or data not able to be deleted at URL \(url)")
            }
        } else {
            println("Error: Directory or data not able to be deleted at URL \(url)")
        }
        
        return success
    }
    
    public class func removeDocumentsImagesDirectory() -> Bool {
        return remove(baseURL: documentsURL(), reletivePath: imagesReletivePath())
    }
    
    public class func removeDocumentsDataDirectory() -> Bool {
        return remove(baseURL: documentsURL(), reletivePath: dataReletivePath())
    }
    
    public class func removeCachesImagesDirectory() -> Bool {
        return remove(baseURL: cachesURL(), reletivePath: imagesReletivePath())
    }
    
    public class func removeCachesDataDirectory() -> Bool {
        return remove(baseURL: cachesURL(), reletivePath: dataReletivePath())
    }
    
    public class func removeDocumentsObject(#reletivePath: String, fileName: String) -> Bool {
        return remove(baseURL: documentsURL(), reletivePath: reletivePath, fileName: fileName)
    }
    
    public class func removeCachesObject(#reletivePath: String, fileName: String) -> Bool {
        return remove(baseURL: cachesURL(), reletivePath: reletivePath, fileName: fileName)
    }
    
}
