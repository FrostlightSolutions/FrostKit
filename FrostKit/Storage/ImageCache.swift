//
//  ImageCache.swift
//  FrostKit
//
//  Created by James Barrow on 30/09/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

///
/// Image Cache supplies a place to store images in a NSCache object.
/// Images will be loaded from cache if they are available, if not they will be loaded from local storage and saved in the cache.
///
/// All images are stored by using the absolute path as the key.
///
public class ImageCache: NSObject {
    
    /// The cache store for the images.
    private let cache = NSCache()
    
    // MARK: - Singleton
    
    /**
    Returns the shared image cache object.
    
    :returns: The shared image cache object.
    */
    public class var shared: ImageCache {
        struct Singleton {
            static let instance : ImageCache = ImageCache()
        }
        return Singleton.instance
    }
    
    /**
    Load an image from cache. If the image is not available in cache then it will be attempted to be loaded from the local store.
    This is a private method. Use the public class method from outside this class.
    
    :param: directory       The search path directory to use.
    :param: reletivePath    The reletive path to of the file or directory.
    :param: fileName        The name of the file (including the extension).
    
    :returns: The image at the absolute path made from the passed in argments or `nil` if not found.
    */
    private func loadImage(#directory: NSSearchPathDirectory, reletivePath: String, fileName: String) -> UIImage? {
        
        let absoluteURL = LocalStorage.absoluteURL(directory: directory, reletivePath: reletivePath, fileName: fileName)
        if let absolutePath = absoluteURL?.path {
            
            var image = cache.objectForKey(absolutePath) as? UIImage
            
            if image == nil {
                
                switch directory {
                case .DocumentDirectory:
                    image = LocalStorage.loadImageFromDocuments(reletivePath: reletivePath, fileName: fileName)
                case .CachesDirectory:
                    image = LocalStorage.loadImageFromCaches(reletivePath: reletivePath, fileName: fileName)
                default:
                    NSLog("Error: Directory \"\(directory)\" requested for loading \(fileName) is not supported!")
                }
                
                if let anImage = image {
                    cache.setObject(anImage, forKey: absolutePath)
                }
            }
            
            if let anImage = image {
                ContentManager.saveContentMetadata(absolutePath: absolutePath)
            }
            
            return image
        } else {
            NSLog("Error: Could not get path from absolute URL \(absoluteURL) when loading image!")
        }
        
        return nil
    }
    
    /**
    Load an image from cache. If the image is not available in cache then it will be attempted to be loaded from the local store.
    
    :param: directory       The search path directory to use.
    :param: reletivePath    The reletive path to of the file or directory.
    :param: fileName        The name of the file (including the extension).
    :param: complete        A closure that returns the image at the absolute path made from the passed in argments or `nil` if not found.
    */
    public func loadImage(#directory: NSSearchPathDirectory, reletivePath: String, fileName: String, complete: (UIImage?) -> ()) {
        complete(loadImage(directory: directory, reletivePath: reletivePath, fileName: fileName))
    }
    
    /**
    Load a thumbnail image from cache. If the image is not available in cache then it will be attempted to be loaded from the local store.
    This is a private method. Use the public class method from outside this class.
    
    :param: directory       The search path directory to use.
    :param: reletivePath    The reletive path to of the file or directory.
    :param: fileName        The name of the file (including the extension).
    
    :returns: The thumbnail image at the absolute path made from the passed in argments or `nil` if not found.
    */
    private func loadTumbnailImage(#directory: NSSearchPathDirectory, reletivePath: String, fileName: String, size: CGSize) -> UIImage? {
        
        let absoluteURL = LocalStorage.absoluteURL(directory: directory, reletivePath: reletivePath, fileName: fileName)
        if let absolutePath = absoluteURL?.path {
            
            var thumbnailImage = cache.objectForKey(absolutePath) as? UIImage
            
            if thumbnailImage == nil {
                
                var image = loadImage(directory: directory, reletivePath: reletivePath, fileName: fileName)
                if let anImage = image {
                    
                    if CGSizeEqualToSize(size, CGSizeZero) == false {
                        
                        thumbnailImage = anImage.imageWithMaxSize(size)
                        if let aThumbnailImage = thumbnailImage {
                            cache.setObject(aThumbnailImage, forKey: absolutePath)
                        }
                        
                    } else {
                        thumbnailImage = anImage
                    }
                }
            }
            
            return thumbnailImage
        } else {
            NSLog("Error: Could not get path from absolute URL \(absoluteURL) when loading thumbnail!")
        }
        
        return nil
    }
    
    /**
    Load a thumbnail image from cache. If the image is not available in cache then it will be attempted to be loaded from the local store.
    
    :param: directory       The search path directory to use.
    :param: reletivePath    The reletive path to of the file or directory.
    :param: fileName        The name of the file (including the extension).
    :param: complete        A closure that returns the image at the absolute path made from the passed in argments or `nil` if not found.
    */
    public func loadTumbnailImage(#directory: NSSearchPathDirectory, reletivePath: String, fileName: String, size: CGSize, complete: (UIImage?) -> ()) {
        complete(loadTumbnailImage(directory: directory, reletivePath: reletivePath, fileName: fileName, size: size))
    }
    
    /**
    Clears all the images in the cache.
    */
    public func clearCache() {
        NSLog("Clearing image cache")
        cache.removeAllObjects()
    }
    
}
