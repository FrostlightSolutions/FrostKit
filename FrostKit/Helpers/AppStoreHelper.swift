//
//  AppStoreHelper.swift
//  FrostKit
//
//  Created by James Barrow on 07/11/2015.
//  Copyright © 2015-Current James Barrow - Frostlight Solutions. All rights reserved.
//

#if os(OSX)
import AppKit
#else
import UIKit
#endif

public class AppStoreHelper {
    
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
    public var releaseDate: Date?
    private var bundleId: String?
    
    // MARK: - Updates
    
    /**
    Updates data from the app store and parses into local files.
    
    This is called automaticaly by FrostKit on setup if the app store ID is set.
    
    - parameter completed: Returned when to update request is completed and returns an error is it failed.
    */
    public func updateAppStoreData(_ completed: ((NSError?) -> Void)? = nil) {
        
        guard let appStoreID = FrostKit.appStoreID else {
            completed?(NSError.error(withMessage: "No app store ID set."))
            return
        }
        
        var urlString = "https://itunes.apple.com"
        if let code = Locale.autoupdatingCurrent.object(forKey: .countryCode) as? String {
            urlString += "/\(code.lowercased())"
        }
        urlString += "/lookup?id=\(appStoreID)"
        
        guard let url = URL(string: urlString) else {
            completed?(NSError.error(withMessage: "URL could not be created from string: \(urlString)"))
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url as URL) { (data, _, error) in
            
            if let anError = error {
                completed?(anError)
            } else if let jsonData = data {
                
                guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: AnyObject],
                    let results = json?["results"] as? [[String: AnyObject]],
                    let appDetails = results.first else {
                        completed?(NSError.error(withMessage: "Could not parse JSON from data."))
                    return
                }
                
                NSLog("JSON: \(json)")
                NSLog("App Details: \(appDetails)")
                
                self.version = appDetails["version"] as? String
                self.name = appDetails["trackName"] as? String
                self.seller = appDetails["sellerName"] as? String
                self.appDescription = appDetails["description"] as? String
                self.price = appDetails["price"] as? Double
                self.currency = appDetails["currency"] as? String
                self.formattedPrice = appDetails["formattedPrice"] as? String
                self.fileSize = appDetails["fileSizeBytes"] as? String
                
                if let releaseDateString = appDetails["releaseDate"] as? String {
                    self.releaseDate = Date.iso8601Date(from: releaseDateString)
                } else {
                    self.releaseDate = nil
                }
                
                self.bundleId = appDetails["bundleId"] as? String
                
                completed?(nil)
                
            } else {
                completed?(NSError.error(withMessage: "No data returned."))
            }
        }
        task.resume()
    }
    
    /**
     Retruns `true` if the needs updating comparing the local app version number with the one recived from the app store.
     
     This will only work if an update with the app store has been made successfully and the `version` and `bundleId` values have been parsed.
     
     - returns: If the app is up to date then `UpToDate` is returned, `UpdateNeeded` if the local version is behind the app store version or `Unknown` if data have not been updated and parsed from the app store.
     */
    public func appUpdateNeeded() -> UpdateStatus {
        
        if let appStoreVersion = self.version, let bundleId = self.bundleId, let bundle = Bundle(identifier: bundleId) {
            
            let localVersion = Bundle.appVersion(bundle)
            let comparisonResult = localVersion.compare(appStoreVersion, options: .numeric)
            if comparisonResult == .orderedAscending {
                return .updateNeeded
            } else {
                return .upToDate
            }
        }
        
        return .unknown
    }
    
}
