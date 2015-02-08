//
//  LocalStorage.swift
//  FrostKit
//
//  Created by James Barrow on 30/09/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

/// Describes the location of the directory for saving files.
public enum Location: UInt {
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
    
    :returns: "Images/" string.
    */
    public class func imagesReletivePath() -> String {
        return "Images/"
    }
    
    /**
    Reletive path for data.
    
    :returns: "Data/" string.
    */
    public class func dataReletivePath() -> String {
        return "Data/"
    }
    
    /**
    User data filename.
    
    :returns: "User.data" string filename.
    */
    private class func userDataFilename() -> String {
        return "User.data"
    }
    
    /**
    URL for the documents directory.
    
    :returns: Documents directory URL.
    */
    private class func documentsURL() -> NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
    }
    
    /**
    URL for the caches directory.
    
    :returns: Caches directory URL.
    */
    private class func cachesURL() -> NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0] as NSURL
    }
    
    /**
    Returns the URL the correct directory passed in. Only the Document and Caches directorys are parsed. Any other value will return `nil` and print an error warning to the console.
    
    :param: directory   The search path directory to use.
    
    :returns: The correct URL for the seatch path directory.
    */
    class func baseURL(#directory: NSSearchPathDirectory) -> NSURL? {
        
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
    
    :param: directory       The search path directory to use.
    :param: reletivePath    The reletive path to of the file or directory.
    :param: fileName        The name of the file (including the extension) with a default of `nil` if a directory is being requested.
    
    :returns: A URL comprised of the passed in parameters
    */
    class func absoluteURL(#directory: NSSearchPathDirectory, reletivePath: String, fileName: String? = nil) -> NSURL? {
        
        if let baseURL = baseURL(directory: directory) {
            return absoluteURL(baseURL: baseURL, reletivePath: reletivePath, fileName: fileName)
        }
        return nil
    }
    
    /**
    A private class for the public class function.
    
    :returns: A non-optional version of the public class function.
    */
    private class func absoluteURL(#baseURL: NSURL, reletivePath: String, fileName: String? = nil) -> NSURL {
        
        var url = baseURL.URLByAppendingPathComponent(reletivePath)
        if let name = fileName {
            url = url.URLByAppendingPathComponent(name)
        }
        return url
    }
    
    // MARK: - Directory Creation Methods
    
    /**
    Creates a directory at a paticular URL.
    
    :returns: `true` if the directory is created. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    private class func createDirectory(#url: NSURL) -> Bool {
        
        var error: NSError?
        let success = NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil, error: &error)
        if success == false {
            if let anError = error {
                NSLog(anError.localizedDescription)
            } else {
                NSLog("Error: Directory not able to be created at URL \(url)")
            }
        }
        
        return success
    }
    
    // MARK: - Save Methods
    
    /**
    Saved data to the base URL, reletive path and filename.
    
    :param: data            The data to be saved.
    :param: baseURL         The search path directory to use.
    :param: reletivePath    The reletive path to of the file or directory.
    :param: fileName        The name of the file (including the extension).
    
    :returns: `true` if the data saves correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    private class func save(#data: AnyObject, baseURL: NSURL, reletivePath: String, fileName: String) -> Bool {
        
        var url = baseURL.URLByAppendingPathComponent(reletivePath)
        createDirectory(url: url)
        url = url.URLByAppendingPathComponent(fileName)
        
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
    
    :param: data            The data to be saved.
    :param: reletivePath    The reletive path to of the file or directory.
    :param: fileName        The name of the file (including the extension).
    
    :returns: `true` if the data saves correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func saveToDocuments(#data: AnyObject, reletivePath: String, fileName: String) -> Bool {
        return save(data: data, baseURL: documentsURL(), reletivePath: reletivePath, fileName: fileName)
    }
    
    /**
    Saves data to the caches directory.
    
    :param: data            The data to be saved.
    :param: reletivePath    The reletive path to of the file or directory.
    :param: fileName        The name of the file (including the extension).
    
    :returns: `true` if the data saves correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func saveToCaches(#data: AnyObject, reletivePath: String, fileName: String) -> Bool {
        return save(data: data, baseURL: cachesURL(), reletivePath: reletivePath, fileName: fileName)
    }
    
    /**
    Saves user data.
    
    :param: data    The data to be saved.
    
    :returns: `true` if the data saves correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func saveUserData(data: AnyObject) -> Bool {
        return save(data: data, baseURL: documentsURL(), reletivePath: "", fileName: userDataFilename())
    }
    
    // MARK: - Move Methods
    
    /**
    Moves files from a base URL to anouther with the same reletive path and file name. This is to be mainly used to move items from documents to the caches directories and vice versa.
    
    :param: fromeBaseURL    The original search path directory.
    :param: toBaseURL       The new search path directory.
    :param: reletivePath    The reletive path to of the file or directory.
    :param: fileName        The name of the file (including the extension).
    
    :returns: `true` if the data is moved correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    private class func move(#fromBaseURL: NSURL, toBaseURL: NSURL, reletivePath: String, fileName: String) -> Bool {
        
        let fromURL = absoluteURL(baseURL: fromBaseURL, reletivePath: reletivePath, fileName: fileName)
        let toURL = absoluteURL(baseURL: toBaseURL, reletivePath: reletivePath, fileName: fileName)
        
        var error: NSError?
        let success = NSFileManager.defaultManager().moveItemAtURL(fromURL, toURL: toURL, error: &error)
        if success == false {
            if let anError = error {
                NSLog(anError.localizedDescription)
            } else {
                NSLog("Error: Can't move item from \(fromURL) to \(toURL)")
            }
        }
        
        return success
    }
    
    /**
    Moves files from cache to the documents directory in relation to the reletive path and file name.
    
    :param: reletivePath    The reletive path to of the file or directory.
    :param: fileName        The name of the file (including the extension).
    
    :returns: `true` if the data is moved correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func moveFromCachesToDocuments(#reletivePath: String, fileName: String) -> Bool {
        return move(fromBaseURL: cachesURL(), toBaseURL: documentsURL(), reletivePath: reletivePath, fileName: fileName)
    }
    
    /**
    Moves files from documents to the caches directory in relation to the reletive path and file name.
    
    :param: reletivePath    The reletive path to of the file or directory.
    :param: fileName        The name of the file (including the extension).
    
    :returns: `true` if the data is moved correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func moveFromDocumentsToCaches(#reletivePath: String, fileName: String) -> Bool {
        return move(fromBaseURL: documentsURL(), toBaseURL: cachesURL(), reletivePath: reletivePath, fileName: fileName)
    }
    
    // MARK: - Load Methods
    
    /**
    Loads files from a base URL to anouther with the same reletive path and file name.
    
    :param: baseURL         The search path directory to use.
    :param: reletivePath    The reletive path to of the file or directory.
    :param: fileName        The name of the file (including the extension).
    
    :returns: The object to be loaded or `nil` if it isn't found.
    */
    private class func load(#baseURL: NSURL, reletivePath: String, fileName: String) -> AnyObject? {
        
        let url = absoluteURL(baseURL: baseURL, reletivePath: reletivePath, fileName: fileName)
        
        if let path = url.path {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(path)
        }
        
        return nil
    }
    
    /**
    Loads files based in the documents directory.
    
    :param: reletivePath    The reletive path to of the file or directory.
    :param: fileName        The name of the file (including the extension).
    
    :returns: The file requested to be loaded or `nil` if it isn't found.
    */
    public class func loadFromDocuments(#reletivePath: String, fileName: String) -> AnyObject? {
        return load(baseURL: documentsURL(), reletivePath: reletivePath, fileName: fileName)
    }
    
    /**
    Loads files based in the caches directory.
    
    :param: reletivePath    The reletive path to of the file or directory.
    :param: fileName        The name of the file (including the extension).
    
    :returns: The file requested to be loaded or `nil` if it isn't found.
    */
    public class func loadFromCaches(#reletivePath: String, fileName: String) -> AnyObject? {
        return load(baseURL: cachesURL(), reletivePath: reletivePath, fileName: fileName)
    }
    
    /**
    Loads images based in the documents directory.
    
    :param: reletivePath    The reletive path to of the file or directory.
    :param: fileName        The name of the file (including the extension).
    
    :returns: The image requested to be loaded or `nil` if it isn't found.
    */
    public class func loadImageFromDocuments(#reletivePath: String, fileName: String) -> UIImage? {
        return loadFromDocuments(reletivePath: reletivePath, fileName: fileName) as? UIImage
    }
    
    /**
    Loads images based in the caches directory.
    
    :param: reletivePath    The reletive path to of the file or directory.
    :param: fileName        The name of the file (including the extension).
    
    :returns: The image requested to be loaded or `nil` if it isn't found.
    */
    public class func loadImageFromCaches(#reletivePath: String, fileName: String) -> UIImage? {
        return loadFromCaches(reletivePath: reletivePath, fileName: fileName) as? UIImage
    }
    
    /**
    Loads the user data object.
    
    :returns: The user data object requested to be loaded or `nil` if it isn't found.
    */
    public class func loadUserData() -> AnyObject? {
        return load(baseURL: documentsURL(), reletivePath: "", fileName: userDataFilename())
    }
    
    // MARK: - Delete Methods
    
    /**
    Removes an object at an absolute path. On success this method will remove the item from the Content Manager.
    
    :param: absoluteURL     Absolute path of the item to remove.
    
    :returns: `true` if the data is removed correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    class func remove(#absoluteURL: NSURL) -> Bool {
        var error: NSError?
        let success = NSFileManager.defaultManager().removeItemAtURL(absoluteURL, error: &error)
        if success == false {
            if let anError = error {
                NSLog(anError.localizedDescription)
            } else {
                NSLog("Error: Directory or data not able to be deleted at URL \(absoluteURL)")
            }
        } else {
            ContentManager.removeContentMetadata(absoluteURL: absoluteURL)
        }
        
        return success
    }
    
    /**
    Removes the file or directory from the base url in relation to the reletive path and file name. On success this method will remove the item from the Content Manager.
    
    :param: baseURL         The search path directory to use.
    :param: reletivePath    The reletive path to of the file or directory.
    :param: fileName        The name of the file (including the extension) with a default of `nil` if a directory is being requested.
    
    :returns: `true` if the data is removed correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    private class func remove(#baseURL: NSURL, reletivePath: String, fileName: String? = nil) -> Bool {
        return remove(absoluteURL: absoluteURL(baseURL: baseURL, reletivePath: reletivePath, fileName: fileName))
    }
    
    /**
    Removes the images directory in the documents root directory.
    
    :returns: `true` if the data is removed correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func removeDocumentsImagesDirectory() -> Bool {
        return remove(baseURL: documentsURL(), reletivePath: imagesReletivePath())
    }
    
    /**
    Removes the data directory in the documents root directory.
    
    :returns: `true` if the data is removed correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func removeDocumentsDataDirectory() -> Bool {
        return remove(baseURL: documentsURL(), reletivePath: dataReletivePath())
    }
    
    /**
    Removes the images directory in the caches root directory.
    
    :returns: `true` if the data is removed correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func removeCachesImagesDirectory() -> Bool {
        return remove(baseURL: cachesURL(), reletivePath: imagesReletivePath())
    }
    
    /**
    Removes the data directory in the caches root directory.
    
    :returns: `true` if the data is removed correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func removeCachesDataDirectory() -> Bool {
        return remove(baseURL: cachesURL(), reletivePath: dataReletivePath())
    }
    
    /**
    Removes a file or directory in the documents root directory in relation to the reletive path and file name.
    
    :param: reletivePath    The reletive path to of the file or directory.
    :param: fileName        The name of the file (including the extension).
    
    :returns: `true` if the data is removed correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func removeDocumentsObject(#reletivePath: String, fileName: String) -> Bool {
        return remove(baseURL: documentsURL(), reletivePath: reletivePath, fileName: fileName)
    }
    
    /**
    Removes a file or directory in the caches root directory in relation to the reletive path and file name.
    
    :param: reletivePath    The reletive path to of the file or directory.
    :param: fileName        The name of the file (including the extension).
    
    :returns: `true` if the data is removed correctly. `false` if it fails and an error will be printed regarding the nature of the nature of the error.
    */
    public class func removeCachesObject(#reletivePath: String, fileName: String) -> Bool {
        return remove(baseURL: cachesURL(), reletivePath: reletivePath, fileName: fileName)
    }
    
}
