//
//  ImageCache.swift
//  FrostKit
//
//  Created by James Barrow on 30/09/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit

public class ImageCache: NSObject {
    
    private let cache = NSCache()
    
    // MARK: - Singleton
    
    public class var shared: ImageCache {
        struct Singleton {
            static let instance : ImageCache = ImageCache()
        }
        return Singleton.instance
    }
    
    private func loadImage(#directory: NSSearchPathDirectory, reletivePath: String, fileName: String) -> UIImage? {
        
        let path = reletivePath.stringByAppendingPathComponent(fileName)
        var image = cache.objectForKey(path) as? UIImage
        
        if image == nil {
            
            switch directory {
            case .DocumentDirectory:
                image = LocalStorage.loadImageFromDocuments(reletivePath: reletivePath, fileName: fileName)
            case .CachesDirectory:
                image = LocalStorage.loadImageFromCaches(reletivePath: reletivePath, fileName: fileName)
            default:
                println("Error: Directory \"\(directory)\" requested for loading \(fileName) is not supported!")
            }
            
            if let anImage = image {
                cache.setObject(anImage, forKey: path)
            }
        }
        
        // TODO: Save content metadata
//        if let anImage = image {
//            
//        }
        
        return image
    }
    
    public func loadImage(#directory: NSSearchPathDirectory, reletivePath: String, fileName: String, complete: (UIImage?) -> ()) {
        complete(loadImage(directory: directory, reletivePath: reletivePath, fileName: fileName))
    }
    
    private func loadTumbnailImage(#directory: NSSearchPathDirectory, reletivePath: String, fileName: String, size: CGSize) -> UIImage? {
        
        let path = reletivePath.stringByAppendingPathComponent(NSStringFromCGSize(size)).stringByAppendingPathComponent(fileName)
        var thumbnailImage = cache.objectForKey(path) as? UIImage
        
        if thumbnailImage == nil {
            
            var image = loadImage(directory: directory, reletivePath: reletivePath, fileName: fileName)
            if let anImage = image {
                
                if CGSizeEqualToSize(size, CGSizeZero) == false {
                    
                    thumbnailImage = anImage.imageWithMaxSize(size)
                    if let aThumbnailImage = thumbnailImage {
                        cache.setObject(aThumbnailImage, forKey: path)
                    }
                    
                } else {
                    thumbnailImage = anImage
                }
            }
        }
        
        // TODO: Save content metadata
//        if let aThumbnailImage = thumbnailImage {
//            
//        }
        
        return thumbnailImage
    }
    
    public func loadTumbnailImage(#directory: NSSearchPathDirectory, reletivePath: String, fileName: String, size: CGSize, complete: (UIImage?) -> ()) {
        complete(loadTumbnailImage(directory: directory, reletivePath: reletivePath, fileName: fileName, size: size))
    }
    
    public func clearCache() {
        println("Clearing image cache")
        cache.removeAllObjects()
    }
    
}
