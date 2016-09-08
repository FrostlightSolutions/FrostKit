//
//  LocalStorage.swift
//  FrostKit
//
//  Created by James Barrow on 30/09/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

/// Describes the location of the directory for saving files.
public enum DirectoryLocation: UInt {
    /// User Data directory.
    case UserData
    /// Document directory.
    static let DocumentDirectory = NSSearchPathDirectory.DocumentDirectory
    /// Caches Directory.
    static let CachesDirectory = NSSearchPathDirectory.CachesDirectory
}

///
/// Local Storage provides the moethds for dealing with local files and direcotries. This includes creation, moving , saving, loading and removing of these items.
///
/// :File Structure:
///
/// :Documents:
/// : : ― Images        Perminant Images
/// : : ― Data          Perminant Documents and Data:
/// : : ― User.data     User object (NSObject conforming to NSCoding)
/// :Library:
/// : : ― Caches
/// : : ― ― Images      Store Temporary Images
/// : : ― ― Data        Store Temporary Documents and Data
///
/// NOTE: Anything stored in Caches has the ability to be deleted when the app is not active (never during),
/// so make sure only data that can be re-downloaded get stored here.
///
public class LocalStorage: NSObject {
    
    // MARK: - Paths and URL Methods
    
    /**
    Reletive path for images.
    
    - returns: "Images/" string.
    */
    public class func imagesReletivePath() -> String {
        return "Images/"
    }
    
    /**
    Reletive path for data.
    
    - returns: "Data/" string.
    */
    public class func dataReletivePath() -> String {
        return "Data/"
    }
    
    /**
    User data filename.
    
    - returns: "User.data" string filename.
    */
    private class func userDataFilename() -> String {
        return "User.data"
    }
    
    /**
    URL for the documents directory.
    
    - returns: Documents directory URL.
    */
    private class func documentsURL() -> NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
    }
    
    /**
    URL for the caches directory.
    
    - returns: Caches directory URL.
    */
    private class func cachesURL() -> NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0] as NSURL
    }
    
    /**
    Returns the URL the correct directory passed in. Only the Document and Caches directorys are parsed. Any other value will return `nil` and print an error warning to the console.
    
    - parameter directory:   The search path directory to use.
    
    - returns: The correct URL for the seatch path directory.
    */
    class func baseURL(directory directory: NSSearchPathDirectory) -> NSURL? {
        
        switch directory {
        case .DocumentDirectory:
            return documentsURL()
        case .CachesDirectory:
            return cachesURL()
        default:
            NSLog("Error: Base URL for directory \"\(directory)\" requested is not supported!")
            return nil
        }
    }
    
    /**
    Returns the absolute URL for a specific seatch path directory, reletive path and file name.
    
    - parameter directory:      The search path directory to use.
    - parameter reletivePath:   The reletive path to of the file or directory.
    - parameter fileName:       The name of the file with a default of `nil` if a directory is being requested.
    - parameter fileExtension:  The name of the file extension.
    
    - returns: A URL comprised of the passed in parameters
    */
    class func absoluteURL(directory directory: NSSearchPathDirectory, reletivePath: String, fileName: String? = nil, fileExtension: String? = nil) -> NSURL? {
        
        if let baseURL = baseURL(directory: directory) {
            return absoluteURL(baseURL: baseURL, reletivePath: reletivePath, fileName: fileName, fileExtension: fileExtension)
        }
        return nil
    }
    
    /**
    A private class for the public class function.
    
    - parameter baseURL:        The base URL of the absolute to be created.
    - parameter reletivePath:   The reletive path to of the file or directory.
    - parameter fileName:       The name of the file with a default of `nil` if a directory is being requested.
    - parameter fileExtension:  The name of the file extension.
    
    - returns: A non-optional version of the public class function.
    */
    private class func absoluteURL(baseURL baseURL: NSURL, reletivePath: String, fileName: String? = nil, fileExtension: String? = nil) -> NSURL? {
        
        guard let name = fileName, ext = fileExtension else {
            return nil
        }
        
        return baseURL.URLByAppendingPathComponent(reletivePath)?.URLByAppendingPathComponent(name)?.URLByAppendingPathExtension(ext)
    }
    
    // MARK: - Directory Creation Methods
    
    /**
    Creates a directory at a paticular URL.
    
    - parameter url:            The url of the directory to be created.
    
    - returns: `true` if the directory is created. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    internal class func createDirectory(url url: NSURL) {
        
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            NSLog("Error: Directory not able to be created at URL \(url)\nWith error: \(error.localizedDescription)\n\(error)")
        }
    }
    
    // MARK: - Save Methods
    
    /**
    Saved data to the base URL, reletive path and filename.
    
    - parameter data:           The data to be saved.
    - parameter baseURL:        The search path directory to use.
    - parameter reletivePath:   The reletive path to of the file or directory.
    - parameter fileName:       The name of the file.
    - parameter fileExtension:  The name of the file extension.
    
    - returns: `true` if the data saves correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func save(data data: AnyObject, baseURL: NSURL, reletivePath: String, fileName: String? = nil, fileExtension: String? = nil) -> Bool {
        
        guard let dirURL = baseURL.URLByAppendingPathComponent(reletivePath) else {
            return false
        }
        
        createDirectory(url: dirURL)
        
        guard let name = fileName, ext = fileExtension,
            url = dirURL.URLByAppendingPathComponent(name)?.URLByAppendingPathExtension(ext) else {
                return false
        }
        
        if let path = url.path {
            
            let success = NSKeyedArchiver.archiveRootObject(data, toFile: path)
            
            if success == false {
                NSLog("Error: Can't save object to file at path: \(path)")
            }
            
            return success
        }
        
        return false
    }
    
    /**
    Saves data to the documents directory.
    
    - parameter data:           The data to be saved.
    - parameter reletivePath:   The reletive path to of the file or directory.
    - parameter fileName:       The name of the file.
    - parameter fileExtension:  The name of the file extension.
    
    - returns: `true` if the data saves correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func saveToDocuments(data data: AnyObject, reletivePath: String, fileName: String? = nil, fileExtension: String? = nil) -> Bool {
        return save(data: data, baseURL: documentsURL(), reletivePath: reletivePath, fileName: fileName, fileExtension: fileExtension)
    }
    
    /**
    Saves data to the caches directory.
    
    - parameter data:           The data to be saved.
    - parameter reletivePath:   The reletive path to of the file or directory.
    - parameter fileName:       The name of the file.
    - parameter fileExtension:  The name of the file extension.
    
    - returns: `true` if the data saves correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func saveToCaches(data data: AnyObject, reletivePath: String, fileName: String? = nil, fileExtension: String? = nil) -> Bool {
        return save(data: data, baseURL: cachesURL(), reletivePath: reletivePath, fileName: fileName, fileExtension: fileExtension)
    }
    
    /**
    Saves user data.
    
    - parameter data:    The data to be saved.
    
    - returns: `true` if the data saves correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func saveUserData(data: AnyObject) -> Bool {
        return save(data: data, baseURL: documentsURL(), reletivePath: "", fileName: userDataFilename())
    }
    
    // MARK: - Move Methods
    
    /**
    Moves files from a base URL to anouther with the same reletive path and file name. This is to be mainly used to move items from documents to the caches directories and vice versa.
    
    - parameter fromeBaseURL:   The original search path directory.
    - parameter toBaseURL:      The new search path directory.
    - parameter reletivePath:   The reletive path to of the file or directory.
    - parameter fileName:       The name of the file.
    - parameter fileExtension:  The name of the file extension.
    
    - returns: `true` if the data is moved correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    private class func move(fromBaseURL fromBaseURL: NSURL, toBaseURL: NSURL, reletivePath: String, fileName: String? = nil, fileExtension: String? = nil) throws {
        
        guard let fromURL = absoluteURL(baseURL: fromBaseURL, reletivePath: reletivePath, fileName: fileName, fileExtension: fileExtension),
            toURL = absoluteURL(baseURL: toBaseURL, reletivePath: reletivePath, fileName: fileName, fileExtension: fileExtension) else {
                return
        }
        try NSFileManager.defaultManager().moveItemAtURL(fromURL, toURL: toURL)
    }
    
    /**
    Moves files from cache to the documents directory in relation to the reletive path and file name.
    
    - parameter reletivePath:   The reletive path to of the file or directory.
    - parameter fileName:       The name of the file.
    - parameter fileExtension:  The name of the file extension.
    
    - returns: `true` if the data is moved correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func moveFromCachesToDocuments(reletivePath reletivePath: String, fileName: String? = nil, fileExtension: String? = nil) throws {
        try move(fromBaseURL: cachesURL(), toBaseURL: documentsURL(), reletivePath: reletivePath, fileName: fileName, fileExtension: fileExtension)
    }
    
    /**
    Moves files from documents to the caches directory in relation to the reletive path and file name.
    
    - parameter reletivePath:   The reletive path to of the file or directory.
    - parameter fileName:       The name of the file.
    - parameter fileExtension:  The name of the file extension.
    
    - returns: `true` if the data is moved correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func moveFromDocumentsToCaches(reletivePath reletivePath: String, fileName: String? = nil, fileExtension: String? = nil) throws {
        try move(fromBaseURL: documentsURL(), toBaseURL: cachesURL(), reletivePath: reletivePath, fileName: fileName, fileExtension: fileExtension)
    }
    
    // MARK: - Load Methods
    
    /**
    Loads files from a base URL to anouther with the same reletive path and file name.
    
    - parameter baseURL:        The search path directory to use.
    - parameter reletivePath:   The reletive path to of the file or directory.
    - parameter fileName:       The name of the file.
    - parameter fileExtension:  The name of the file extension.
    
    - returns: The object to be loaded or `nil` if it isn't found.
    */
    public class func load(baseURL baseURL: NSURL, reletivePath: String, fileName: String? = nil, fileExtension: String? = nil) -> AnyObject? {
        
        guard let url = absoluteURL(baseURL: baseURL, reletivePath: reletivePath, fileName: fileName, fileExtension: fileExtension), path = url.path else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObjectWithFile(path)
    }
    
    /**
    Loads files based in the documents directory.
    
    - parameter reletivePath:   The reletive path to of the file or directory.
    - parameter fileName:       The name of the file.
    - parameter fileExtension:  The name of the file extension.
    
    - returns: The file requested to be loaded or `nil` if it isn't found.
    */
    public class func loadFromDocuments(reletivePath reletivePath: String, fileName: String? = nil, fileExtension: String? = nil) -> AnyObject? {
        return load(baseURL: documentsURL(), reletivePath: reletivePath, fileName: fileName, fileExtension: fileExtension)
    }
    
    /**
    Loads files based in the caches directory.
    
    - parameter reletivePath:   The reletive path to of the file or directory.
    - parameter fileName:       The name of the file.
    - parameter fileExtension:  The name of the file extension.
    
    - returns: The file requested to be loaded or `nil` if it isn't found.
    */
    public class func loadFromCaches(reletivePath reletivePath: String, fileName: String? = nil, fileExtension: String? = nil) -> AnyObject? {
        return load(baseURL: cachesURL(), reletivePath: reletivePath, fileName: fileName, fileExtension: fileExtension)
    }
    
    /**
    Loads images based in the documents directory.
    
    - parameter reletivePath:   The reletive path to of the file or directory.
    - parameter fileName:       The name of the file.
    - parameter fileExtension:  The name of the file extension.
    
    - returns: The image requested to be loaded or `nil` if it isn't found.
    */
    public class func loadImageFromDocuments(reletivePath reletivePath: String, fileName: String? = nil, fileExtension: String? = nil) -> UIImage? {
        return loadFromDocuments(reletivePath: reletivePath, fileName: fileName, fileExtension: fileExtension) as? UIImage
    }
    
    /**
    Loads images based in the caches directory.
    
    - parameter reletivePath:   The reletive path to of the file or directory.
    - parameter fileName:       The name of the file.
    - parameter fileExtension:  The name of the file extension.
    
    - returns: The image requested to be loaded or `nil` if it isn't found.
    */
    public class func loadImageFromCaches(reletivePath reletivePath: String, fileName: String? = nil, fileExtension: String? = nil) -> UIImage? {
        return loadFromCaches(reletivePath: reletivePath, fileName: fileName, fileExtension: fileExtension) as? UIImage
    }
    
    /**
    Loads the user data object.
    
    - returns: The user data object requested to be loaded or `nil` if it isn't found.
    */
    public class func loadUserData() -> AnyObject? {
        return load(baseURL: documentsURL(), reletivePath: "", fileName: userDataFilename())
    }
    
    // MARK: - Delete Methods
    
    /**
    Removes an object at an absolute path. On success this method will remove the item from the Content Manager.
    
    - parameter absoluteURL:     Absolute path of the item to remove.
    
    - returns: `true` if the data is removed correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    class func remove(absoluteURL absoluteURL: NSURL) throws {
        
        try NSFileManager.defaultManager().removeItemAtURL(absoluteURL)
        ContentManager.removeContentMetadata(absoluteURL: absoluteURL)
    }
    
    /**
    Removes the file or directory from the base url in relation to the reletive path and file name. On success this method will remove the item from the Content Manager.
    
    - parameter baseURL:        The search path directory to use.
    - parameter reletivePath:   The reletive path to of the file or directory.
    - parameter fileName:       The name of the file.
    - parameter fileExtension:  The name of the file extension.
    
    - returns: `true` if the data is removed correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    private class func remove(baseURL baseURL: NSURL, reletivePath: String, fileName: String? = nil, fileExtension: String? = nil) throws {
        
        guard let url = absoluteURL(baseURL: baseURL, reletivePath: reletivePath, fileName: fileName, fileExtension: fileExtension) else {
            return
        }
        
        try remove(absoluteURL: url)
    }
    
    /**
    Removes the images directory in the documents root directory.
    
    - returns: `true` if the data is removed correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func removeDocumentsImagesDirectory() throws {
        try remove(baseURL: documentsURL(), reletivePath: imagesReletivePath())
    }
    
    /**
    Removes the data directory in the documents root directory.
    
    - returns: `true` if the data is removed correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func removeDocumentsDataDirectory() throws {
        try remove(baseURL: documentsURL(), reletivePath: dataReletivePath())
    }
    
    /**
    Removes the images directory in the caches root directory.
    
    - returns: `true` if the data is removed correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func removeCachesImagesDirectory() throws {
        try remove(baseURL: cachesURL(), reletivePath: imagesReletivePath())
    }
    
    /**
    Removes the data directory in the caches root directory.
    
    - returns: `true` if the data is removed correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func removeCachesDataDirectory() throws {
        try remove(baseURL: cachesURL(), reletivePath: dataReletivePath())
    }
    
    /**
    Removes a file or directory in the documents root directory in relation to the reletive path and file name.
    
    - parameter reletivePath:   The reletive path to of the file or directory.
    - parameter fileName:       The name of the file.
    - parameter fileExtension:  The name of the file extension.
    
    - returns: `true` if the data is removed correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func removeDocumentsObject(reletivePath reletivePath: String, fileName: String? = nil, fileExtension: String? = nil) throws {
        try remove(baseURL: documentsURL(), reletivePath: reletivePath, fileName: fileName, fileExtension: fileExtension)
    }
    
    /**
    Removes a file or directory in the caches root directory in relation to the reletive path and file name.
    
    - parameter reletivePath:   The reletive path to of the file or directory.
    - parameter fileName:       The name of the file.
    - parameter fileExtension:  The name of the file extension.
    
    - returns: `true` if the data is removed correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func removeCachesObject(reletivePath reletivePath: String, fileName: String? = nil, fileExtension: String? = nil) throws {
        try remove(baseURL: cachesURL(), reletivePath: reletivePath, fileName: fileName, fileExtension: fileExtension)
    }
    
}
