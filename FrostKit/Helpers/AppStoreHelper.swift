//
//  AppStoreHelper.swift
//  FrostKit
//
//  Created by James Barrow on 07/11/2015.
//  Copyright © 2015 James Barrow - Frostlight Solutions. All rights reserved.
//

#if os(OSX)
import AppKit
#else
import UIKit
#endif
// TODO: Uncomment when building with Swift 3 version of Alamofire
//import Alamofire

public class AppStoreHelper: NSObject {
    
    public enum UpdateStatus: Int {
        case unknown = -1
        case updateNeeded
        case upToDate
    }
    
    public static let shared = AppStoreHelper()
    
    // MARK: - Properties
    
    public var version: String?
    public var name: String?
    public var seller: String?
    public var appDescription: String?
    public var price: Double?
    public var currency: String?
    public var formattedPrice: String?
    public var fileSize: String? {
        didSet {
            
            if let fileSize = self.fileSize {
                
                if let byteCount = Int64(fileSize) {
                    formattedFileSize = ByteCountFormatter.string(fromByteCount: byteCount, countStyle: .binary)
                } else {
                    formattedFileSize = nil
                }
                
            } else {
                formattedFileSize = nil
            }
        }
    }
    public var formattedFileSize: String?
    public var releaseDate: NSDate?
    private var bundleId: String?
    /**
     If the app is up to date then `upToDate` is returned, `updateNeeded` if the local version is behind the app store version or `unknown` if data have not been updated and parsed from the app store.
 
     This will only work if an update with the app store has been made successfully and the `version` and `bundleId` values have been parsed.
     */
    public var appUpdateNeeded: UpdateStatus {
        
        if let appStoreVersion = self.version, bundleId = self.bundleId, bundle = Bundle(identifier: bundleId) {
            
            let localVersion = Bundle.appVersion(bundle: bundle)
            let comparisonResult = localVersion.compare(appStoreVersion, options: .numericSearch)
            if comparisonResult == .orderedAscending {
                return .updateNeeded
            } else {
                return .upToDate
            }
        }
        
        return .unknown
    }
    
    // MARK: - Updates
    
    /**
    Updates data from the app store and parses into local files.
    
    This is called automaticaly by FrostKit on setup if the app store ID is set.
    
    - parameter completed: Returned when to update request is completed and returns an error is it failed.
    */
    public func updateAppStoreData(completed: ((NSError?) -> Void)? = nil) {

        // TODO: Uncomment when building with Swift 3 version of Alamofire
//        if let appStoreID = FrostKit.appStoreID {
//            
//            var url = "https://itunes.apple.com"
//            if let code = Locale.autoupdatingCurrent().object(forKey: .countryCode) as? String {
//                url += "/\(code.lowercased())"
//            }
//            url += "/lookup"
//            
//            Alamofire.request(.GET, url, parameters: ["id": appStoreID], encoding: .URL, headers: nil).responseJSON { (response) -> Void in
//                
//                if let json = response.result.value as? [String: AnyObject], results = json["results"] as? [[String: AnyObject]], appDetails = results.first {
//                    
//                    self.version = appDetails["version"] as? String
//                    self.name = appDetails["trackName"] as? String
//                    self.seller = appDetails["sellerName"] as? String
//                    self.appDescription = appDetails["description"] as? String
//                    self.price = appDetails["price"] as? Double
//                    self.currency = appDetails["currency"] as? String
//                    self.formattedPrice = appDetails["formattedPrice"] as? String
//                    self.fileSize = appDetails["fileSizeBytes"] as? String
//                    
//                    if let releaseDateString = appDetails["releaseDate"] as? String {
//                        self.releaseDate = NSDate.iso8601Date(from: releaseDateString)
//                    } else {
//                        self.releaseDate = nil
//                    }
//                    
//                    self.bundleId = appDetails["bundleId"] as? String
//                }
//                
//                completed?(response.result.error)
//            }
//            
//        } else {
//            completed?(NSError.error(withMessage: "No app store ID set."))
//        }
    }
}
