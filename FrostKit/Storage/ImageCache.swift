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
    /// The request store for image requests.
    private let imageRequestStore = RequestStore()
    /// The image to return if no image can be found.
    public var placeholderImage: UIImage?
    
    // MARK: - Singleton
    
    /**
    Returns the shared image cache object.
    
    - returns: The shared image cache object.
    */
    public class var shared: ImageCache {
        struct Singleton {
            static let instance : ImageCache = ImageCache()
        }
        return Singleton.instance
    }
    
    /**
    Attempts to load the local image from cache or from loacl storage. If not found in either of these it will return `nil`.
    
    - parameter router: The router for the image to be requested.
    
    - returns: The image requested or `nil`.
    */
    public class func loadLocalImage(router: Router, completed: (image: UIImage?, router: Router) -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            let saveString = router.saveString
            
            // Check for cached image and if found, return
            if let cachedImage = ImageCache.shared.cache.objectForKey(saveString) as? UIImage {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completed(image: cachedImage, router: router)
                })
                return
            } else {
                // If no cached image found, try and load from local storage
                if let localStorageImage = LocalStorage.loadImageFromDocuments(reletivePath: router.saveString, fileName: nil) {
                    ImageCache.shared.cache.setObject(localStorageImage, forKey: saveString)
                    ContentManager.saveContentMetadata(absolutePath: router.saveString)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completed(image: localStorageImage, router: router)
                    })
                    return
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completed(image: nil, router: router)
            })
        })
    }
    
    /**
    Attempts to load an image from cache and then local store, if no image is found then it will attempt to download it.
    
    - parameter urlString: The url string of the image.
    - parameter size:      The max rect the image should be.
    - parameter progress:  A closure of the progress of the download.
    - parameter completed: A closure of the completion of the download.
    */
    public class func loadImage(router: Router, progress: ((percentComplete: CGFloat) -> ())?, completed: (image: UIImage?, router: Router, error: NSError?) -> ()) {
        
        // Check for local image and return if found.
        loadLocalImage(router) { (image, router) -> () in
            if let localImage = image {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completed(image: localImage, router: router, error: nil)
                })
                
            } else {
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                    // If no local image found then try and download.
                    let sharedImageCache = ImageCache.shared
                    
                    if sharedImageCache.imageRequestStore.containsRequestWithRouter(router) == false {
                        let request = FUSServiceClient.imageRequest(router, progress: progress, completed: { (image, error) -> () in
                            sharedImageCache.imageRequestStore.removeRequestFor(router: router)
                            if let anError = error {
                                NSLog("Error downloading image with error: \(anError.localizedDescription)")
                            } else if let downloadedImage = image {
                                let saveString = router.saveString as NSString
                                sharedImageCache.cache.setObject(downloadedImage, forKey: saveString)
                                ContentManager.saveContentMetadata(absolutePath: saveString as String)
                                LocalStorage.saveToDocuments(data: downloadedImage, reletivePath: saveString.stringByDeletingLastPathComponent, fileName: saveString.lastPathComponent)
                            }
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                completed(image: image, router: router, error: error)
                            })
                        })
                        sharedImageCache.imageRequestStore.addRequest(request, router: router)
                    }
                })
            }
        }
    }
    
    /**
    Clears all the images in the cache.
    */
    public func clearCache() {
        NSLog("Clearing image cache")
        cache.removeAllObjects()
    }
    
    /**
    A placeholder image from placekitten.com represented by the integer passed in.
    
    - parameter size: An integer representing the place kitten back.
    
    - returns: The url for a place kitten placeholder.
    */
    public class func placeKittenURLString(size: Int) -> String {
        let baseURL = String("http://placekitten.com")
        return baseURL + "/\(size)"
    }
    
    /**
    A placegolder image from placekitten.com with a random number from 1000 to 2000
    
    - returns: The url for a place kitten placeholder.
    */
    public class func randomPlaceKittenURLString() -> String {
        return placeKittenURLString(Int(arc4random_uniform(2000)+1000))
    }
    
    
    
}
