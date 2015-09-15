//
//  AlamofireExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 15/09/2015.
//  Copyright © 2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import Alamofire

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

public extension Alamofire.Request {
    
    public static func imageResponseSerializer() -> GenericResponseSerializer<UIImage> {
        
        return GenericResponseSerializer { _, _, data in
            
            if let imageData = data where imageData.length > 0 {
                
#if os(iOS) || os(tvOS)
                let scale = UIScreen.mainScreen().scale
#elseif os(watchOS)
                let scale = WKInterfaceDevice.currentDevice().screenScale
#endif
                if let image = UIImage(data: data!, scale: scale) {
                    
                    return .Success(image)
                    
                } else {
                    
                    let error = Error.errorWithCode(0, failureReason: "Could not create UIImage from data.")
                    return .Failure(data, error)
                }
                
            } else {
                
                let error = Error.errorWithCode(0, failureReason: "No data or zero length.")
                return .Failure(data, error)
            }
        }
    }
    
    public func responseImage(completionHandler: (NSURLRequest?, NSHTTPURLResponse?, Result<UIImage>) -> Void) -> Self {
        
        return response(responseSerializer: Request.imageResponseSerializer(), completionHandler: completionHandler)
    }
}
