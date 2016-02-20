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
import Alamofire

public class AppStoreHelper: NSObject {
    
    public enum UpdateStatus: Int {
        case Unknown = -1
        case UpdateNeeded
        case UpToDate
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
                    formattedFileSize = NSByteCountFormatter.stringFromByteCount(byteCount, countStyle: .Binary)
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
    
    // MARK: - Updates
    
    /**
    Updates data from the app store and parses into local files.
    
    This is called automaticaly by FrostKit on setup if the app store ID is set.
    
    - parameter completed: Returned when to update request is completed and returns an error is it failed.
    */
    public func updateAppStoreData(completed: ((NSError?) -> Void)? = nil) {
        
        if let appStoreID = FrostKit.appStoreID {
            
            var url = "https://itunes.apple.com"
            if let code = NSLocale.autoupdatingCurrentLocale().objectForKey(NSLocaleCountryCode) as? String {
                url += "/\(code.lowercaseString)"
            }
            url += "/lookup"
            
            Alamofire.request(.GET, url, parameters: ["id": appStoreID], encoding: .URL, headers: nil).responseJSON { (response) -> Void in
                
                if  let json = response.result.value as? [String: AnyObject],
                    let results = json["results"] as? [[String: AnyObject]],
                    let appDetails = results.first {
                        
                        self.version = appDetails["version"] as? String
                        self.name = appDetails["trackName"] as? String
                        self.seller = appDetails["sellerName"] as? String
                        self.appDescription = appDetails["description"] as? String
                        self.price = appDetails["price"] as? Double
                        self.currency = appDetails["currency"] as? String
                        self.formattedPrice = appDetails["formattedPrice"] as? String
                        self.fileSize = appDetails["fileSizeBytes"] as? String
                        
                        if let releaseDateString = appDetails["releaseDate"] as? String {
                            self.releaseDate = NSDate.iso8601Date(releaseDateString)
                        } else {
                            self.releaseDate = nil
                        }
                        
                        self.bundleId = appDetails["bundleId"] as? String
                }
                
                completed?(response.result.error)
            }
            
        } else {
            completed?(NSError.errorWithMessage("No app store ID set."))
        }
    }
    
    /**
     Retruns `true` if the needs updating comparing the local app version number with the one recived from the app store.
     
     This will only work if an update with the app store has been made successfully and the `version` and `bundleId` values have been parsed.
     
     - returns: If the app is up to date then `UpToDate` is returned, `UpdateNeeded` if the local version is behind the app store version or `Unknown` if data have not been updated and parsed from the app store.
     */
    public func appUpdateNeeded() -> UpdateStatus {
        
        if  let appStoreVersion = self.version,
            let bundleId = self.bundleId,
            let bundle = NSBundle(identifier: bundleId),
            let localVersion = bundle.objectForInfoDictionaryKey("CFBundleShortVersionString") as? String {
                
                let comparisonResult = localVersion.compare(appStoreVersion, options: .NumericSearch)
                if comparisonResult == .OrderedAscending {
                    return .UpdateNeeded
                } else {
                    return .UpToDate
                }
        }
        
        return .Unknown
    }
    
}
