//
//  FUSServiceClient.swift
//  FrostKit
//
//  Created by James Barrow on 19/01/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit
import Alamofire

///
/// Contains all static paths for API calls to FUS in a type-safe mannor.
///
///- Root                          `/`                     The root reletive path.
///- Token([String: AnyObject])    `/api/fus/o/token/`     The token API URL, taking in a dictionary of peramiters.
///- Sections                      `/api/fus/sections/`    The sections for the current app/user.
///- Custom(String, Int?)                                  A custom URL passed in as a reletive path with an optional page number.
///
public enum Router: URLRequestConvertible {
    /// The base URL parsed in form the developer tools plist.
    public static let baseURLString = DeveloperTools.baseURL()
    
    case Root
    case Token([String: AnyObject])
    case Sections
    case CustomGET(String, Int?, [String: AnyObject]?)
    case CustomPOST(String, [String: AnyObject]?)
    case CustomPUT(String, [String: AnyObject]?)
    case CustomDELETE(String)
    case ImageGET(String, CGSize?)
    
    // MARK: URLRequestConvertible
    
    /// THe method for each case. The default is GET.
    var method: Alamofire.Method {
        switch self {
        case .Token:
            return .POST
        case .Sections, .CustomGET, .ImageGET:
            return .GET
        case .CustomPOST:
            return .POST
        case .CustomPUT:
            return .PUT
        case .CustomDELETE:
            return .DELETE
        default:
            return .GET
        }
    }
    
    /// The reletive path for each case, if it is applicable. The Custom case doesn't have a path as it is passed in as one of it's variables.
    var path: String {
        switch self {
        case .Root:
            return "/"
        case .Token:
            return "/api/fus/o/token/"
        case .Sections:
            if let name = FrostKit.FUSName {
                return "/api/\(name)/"
            } else {
                NSLog("Error: Project name not set in FrostKit setup!")
                return ""
            }
        case .ImageGET:
            let path = removeHTTPPrefix(absoluteString.stringByDeletingLastPathComponent)
            var pathComponents = path.componentsSeparatedByString("/")
            pathComponents.removeAtIndex(0)
            return (pathComponents as NSArray).componentsJoinedByString("/")
        default:
            return ""
        }
    }
    
    /**
    Returns the absolute URL for the `urlString` passed in. It checks for the prefix `http://` or `https://` and if found then it reutrns the `urlString` as an NSURL. If these prefixes aren't found then the `urlString` is assumed to be reletive and is appended to the end of the `baseURL`.
    
    - parameter urlString: The urlString to turn into the absoluteURL.
    
    - returns: The absoluteURL created the the absolute or reletive `urlString` passed in.
    */
    private func absoluteURLFromString(urlString: String) -> NSURL {
        if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
            return NSURL(string: urlString)!
        } else {
            let URL = NSURL(string: Router.baseURLString)!
            return URL.URLByAppendingPathComponent(urlString)
        }
    }
    
    public func removeHTTPPrefix(urlString: String) -> String {
        let saveStringComponents = urlString.componentsSeparatedByString("://")
        if let path = saveStringComponents.last {
            return path
        }
        return urlString
    }
    
    private func resizeURL() -> NSURL {
        let URL = NSURL(string: Router.baseURLString)!
        return URL.URLByAppendingPathComponent("resize")
    }
    
    /// The absolute URL of the case.
    var URL: NSURL {
        switch self {
        case .CustomGET(let urlString, _, _):
            return absoluteURLFromString(urlString)
        case .CustomPOST(let urlString, _):
            return absoluteURLFromString(urlString)
        case .CustomPUT(let urlString, _):
            return absoluteURLFromString(urlString)
        case .CustomDELETE(let urlString):
            return absoluteURLFromString(urlString)
        case .ImageGET(let urlString, let size):
            if size != nil {
                return resizeURL()
            } else {
                return absoluteURLFromString(urlString)
            }
        default:
            return absoluteURLFromString(path)
        }
    }
    
    /// The absolute string of the case.
    var absoluteString: String {
        switch self {
        case .ImageGET(let urlString, _):
            return absoluteURLFromString(urlString).absoluteString
        default:
            return URL.absoluteString
        }
    }
    
    /// A reference string to save the call under.
    public var saveString: String {
        switch self {
        case .CustomGET(let urlString, _, let parameters):
            var saveString = urlString
            
            if let someParameters = parameters {
                let keysArray = (someParameters as NSDictionary).allKeys as NSArray
                let sortedKeys = keysArray.sortedArrayUsingSelector("compare:") as! [String]
                for key in sortedKeys {
                    saveString = saveString.stringByAppendingPathComponent(someParameters[key] as! String)
                }
            }
            return saveString
        case .ImageGET(let urlString, let size):
            if let frameSize = size {
                let sizeString = "\(Int(frameSize.width))x\(Int(frameSize.height))"
                let saveString = path.stringByAppendingPathComponent(sizeString + "_" + urlString.lastPathComponent)
                return saveString
            }
            return removeHTTPPrefix(absoluteString)
        default:
            return absoluteString
        }
    }
    
    /// Returns the `absoluteString` without the `baseURL` if it is found in the `absoluteString`.
    var reletiveString: String {
        let absoluteString = self.absoluteString
        return absoluteString.stringByReplacingOccurrencesOfString(absoluteString, withString: "", options: [], range: nil)
    }
    
    /// The page number of the request if passed in. Only available with `.CustonGET`.
    var page: Int? {
        switch self {
        case .CustomGET(_, let page, _):
            return page
        default:
            return nil
        }
    }
    
    /// The size passed in for an image or `nil` if not set or not an image request.
    var imageSize: CGSize? {
        switch self {
        case .ImageGET(_, let size):
            return size
        default:
            return nil
        }
    }
    
    /// The URL request of the case. Token requests to not include an Authorization HTTP header field, as that is what it is requesting.
    public var URLRequest: NSURLRequest {
        
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = method.rawValue
        mutableURLRequest.cachePolicy = .ReloadIgnoringLocalCacheData
        
        if let langCode = NSLocale.preferredLanguages().first {
            mutableURLRequest.setValue(langCode, forHTTPHeaderField: "Accept-Language")
        }
        
        switch self {
        case .Token, .ImageGET:
            break
        default:
            if let oAuthToken = UserStore.current.oAuthToken {
                mutableURLRequest.setValue("Bearer \(oAuthToken.accessToken)", forHTTPHeaderField: "Authorization")
            }
        }
        
        switch self {
        case .Token(let parameters):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
        case .CustomGET(_, let page, var parameters):
            if parameters == nil {
                parameters = Dictionary<String, AnyObject>()
            }
            
            if page != nil {
                parameters!["page"] = page!
            }
            
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
        case .CustomPOST(_, let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .CustomPUT(_, let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .CustomDELETE(_):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0
        case .ImageGET(let urlString, let size):
            if let frameSize = size {
                let parameters = [
                    "resize": "\(Int(frameSize.width))x\(Int(frameSize.height))",
                    "source": urlString
                ]
                return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
            } else {
                return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0
            }
        default:
            return mutableURLRequest
        }
    }
}

/// 
/// The service client for a FUS based system. It provides methods for login, refreshing OAuth tokens and making generic requests.
///
public class FUSServiceClient: NSObject {
    
    // MARK: - URL Methods
    
    public class func imageResizeURLFromURLString(urlString: String, size: CGSize) -> NSURL? {
        
        let sizeString = "\(Int(size.width))x\(Int(size.height))"
        let path = "resize?resize=" + sizeString + "&source=" + urlString
        
        let imageURL = NSURL(string: Router.baseURLString)
        return NSURL(string: path, relativeToURL: imageURL)
    }
    
    // MARK: - Static Methods
    
    /**
    Login the the specified FUS server with username, password and a completed closure. This method does not return anything but store an `OAuthToken` object in the `UserStore`.
    
    - parameter username:  The username of the user to login.
    - parameter password:  The password of the user to login.
    - parameter completed: Is called on completion of the request and returns an error if the process failed, otherwise it retuens `nil`.
    */
    public class func loginUser(username username: String, password: String, completed: (error: NSError?) -> ()) {
        
        let requestDate = NSDate()
        var parameters = ["grant_type": "password", "username": username, "password": password]
        if let OAuthClientID = FrostKit.OAuthClientID {
            parameters["client_id"] = OAuthClientID
        }
        if let OAuthClientSecret = FrostKit.OAuthClientSecret {
            parameters["client_secret"] = OAuthClientSecret
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(NetworkRequestDidBeginNotification, object: nil)
        Alamofire.request(Router.Token(parameters)).validate().responseJSON { (request, response, responseJSON, responseError) -> Void in
            if let anError = responseError {
                completed(error: self.errorForResponse(response, json: responseJSON, origError: anError))
            } else if let jsonDict = responseJSON as? NSDictionary {
                UserStore.current.username = username
                UserStore.current.oAuthToken = OAuthToken(json: jsonDict, requestDate: requestDate)
                UserStore.saveUser()
                
                FUSServiceClient.updateSections { (error) -> () in
                    if let anError = error {
                        completed(error: anError)
                    } else {
                        completed(error: self.errorForResponse(response, json: responseJSON, origError: responseError))
                    }
                }
            } else {
                completed(error: NSError.errorWithMessage("Returned JSON is not a NSDictionary: \(responseJSON)"))
            }
            NSNotificationCenter.defaultCenter().postNotificationName(NetworkRequestDidCompleteNotification, object: nil)
        }
    }
    
    /**
    Refresh an `OAuthToken` if it has expired.
    
    - parameter completed: Is called on completion of the request and returns an error if the process failed, otherwise it retuens `nil`.
    - parameter force:       Forces the OAuth token to refresh even if it hasn't expired.
    */
    public class func refreshOAuthToken(force: Bool = false, completed: (error: NSError?) -> ()) {
        
        if let oAuthToken = UserStore.current.oAuthToken {
            
            if force == false && oAuthToken.expired == false {
                FUSServiceClient.updateSections { (error) -> () in
                    if let anError = error {
                        completed(error: anError)
                    } else {
                        completed(error: nil)
                    }
                }
                return
            }
            
            let requestDate = NSDate()
            var parameters = ["grant_type": "refresh_token", "refresh_token": oAuthToken.refreshToken]
            if let OAuthClientID = FrostKit.OAuthClientID {
                parameters["client_id"] = OAuthClientID
            }
            if let OAuthClientSecret = FrostKit.OAuthClientSecret {
                parameters["client_secret"] = OAuthClientSecret
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(NetworkRequestDidBeginNotification, object: nil)
            Alamofire.request(Router.Token(parameters)).validate().responseJSON { (request, response, responseJSON, responseError) -> Void in
                if let anError = responseError {
                    completed(error: self.errorForResponse(response, json: responseJSON, origError: anError))
                } else if let jsonDict = responseJSON as? NSDictionary {
                    UserStore.current.oAuthToken = OAuthToken(json: jsonDict, requestDate: requestDate)
                    UserStore.saveUser()
                    
                    FUSServiceClient.updateSections { (error) -> () in
                        if let anError = error {
                            completed(error: anError)
                        } else {
                            completed(error: self.errorForResponse(response, json: responseJSON, origError: responseError))
                        }
                    }
                } else {
                    completed(error: NSError.errorWithMessage("Returned JSON is not a NSDictionary: \(responseJSON)"))
                }
                NSNotificationCenter.defaultCenter().postNotificationName(NetworkRequestDidCompleteNotification, object: nil)
            }
        } else {
            completed(error: NSError.errorWithMessage("No OAuthToken in User Store."))
        }
    }
    
    /**
    Updates the current users sections from a FUS based system and stores them in the user store.
    
    - parameter completed: Is called on completion of the request and returns an error if the process failed, otherwise it retuens `nil`.
    */
    public class func updateSections(completed: (error: NSError?) -> ()) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(NetworkRequestDidBeginNotification, object: nil)
        Alamofire.request(Router.Sections).validate().responseJSON { (requestObject, responseObject, responseJSON, responseError) -> Void in
            if let anError = responseError {
                completed(error: self.errorForResponse(responseObject, json: responseJSON, origError: anError))
            } else if let jsonDictionary = responseJSON as? [String: AnyObject] {
                if let jsonArray = jsonDictionary["sections"] as? [[String: String]] {
                    UserStore.current.sections = jsonArray
                    UserStore.saveUser()
                    NSNotificationCenter.defaultCenter().postNotificationName(FUSServiceClientUpdateSections, object: nil)
                    completed(error: self.errorForResponse(responseObject, json: responseJSON, origError: responseError))
                } else {
                    completed(error: NSError.errorWithMessage("Returned JSON is not an Array: \(responseJSON)"))
                }
            } else {
                completed(error: NSError.errorWithMessage("Returned JSON is not a Dictionary: \(responseJSON)"))
            }
            NSNotificationCenter.defaultCenter().postNotificationName(NetworkRequestDidCompleteNotification, object: nil)
        }
    }
    
    // MARK: - Generic Methods
    
    /**
    A generic request method for calling .Sections for .Custom from the Router.
    
    - parameter router: The URL request either manually created or generated by the Router.
    - parameter completed:  The completed callback that returns the response JSON and/or an error.
    
    - returns: An Alamofire request.
    */
    public class func request(router: Router, completed: (json: AnyObject?, error: NSError?) -> ()) -> Alamofire.Request {
        
        NSNotificationCenter.defaultCenter().postNotificationName(NetworkRequestDidBeginNotification, object: nil)
        return Alamofire.request(router).validate().responseJSON { (requestObject, responseObject, responseJSON, responseError) -> Void in
            completed(json: responseJSON, error: self.errorForResponse(responseObject, json: responseJSON, origError: responseError))
            NSNotificationCenter.defaultCenter().postNotificationName(NetworkRequestDidCompleteNotification, object: nil)
        }
    }
    
    /**
    A request for downloading an image using .ImageGET from the Router.
    
    - parameter router:   The URL request either manually created or generated by the Router.
    - parameter progress: The progress call back that returns the progress from 0.0 to 1.0.
    - parameter completed:  The completed callback that returns the response UIImage and/or an error.
    
    - returns: An Alamofire request.
    */
    public class func imageRequest(router: Router, progress: ((percentComplete: CGFloat) -> ())?, completed: (image: UIImage?, error: NSError?) -> ()) -> Alamofire.Request {
        
        NSNotificationCenter.defaultCenter().postNotificationName(NetworkRequestDidBeginNotification, object: nil)
        return Alamofire.request(router).validate().progress({ (_, totalBytesRead, totalBytesExpectedToRead) -> Void in
            var percent: CGFloat = -1
            if totalBytesExpectedToRead >= 0 {
                percent = CGFloat(totalBytesRead) / CGFloat(totalBytesExpectedToRead)
            }
            progress?(percentComplete: percent)
        }).responseImage({ (_, _, image, error) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(NetworkRequestDidCompleteNotification, object: nil)
            completed(image: image, error: error)
        })
    }
    
    // MARK: - Helper Methods
    
    /**
    Checks if an object is a URL path with a prefix of `http://` or `https://`.
    
    - parameter item: The item to check.
    
    - returns: Returns `true` if it is a path string or `false` if not.
    */
    public class func isItemSection(item: AnyObject) -> Bool {
        if let path = item as? String where path.hasPrefix("http://") || path.hasPrefix("https://") {
            return true
        }
        return false
    }
    
    // MARK: - Error Handling
    
    /**
    Creates an error object that joins the original error description, the response status code and the JSON error dictionary where available.
    
    - parameter response:  The response that had the error, or `nil` if it doesn't exist.
    - parameter json:      The JSON response, or `nil` if there wasn't any.
    - parameter origError: The original error returned by Alamofire, or `nil` if there isn't any.
    
    - returns: An arror with a localized description of all the information passed in.
    */
    private class func errorForResponse(response: NSHTTPURLResponse?, json: AnyObject?, origError: NSError?) -> NSError? {
        if let anError = origError {
            var errorString = "\(anError.localizedDescription), "
            
            if let aResponse = response {
                errorString += "Status Code \(aResponse.statusCode), "
            }
            
            if let errorDictionary = json as? NSDictionary {
                errorString += "\(errorDictionary)"
            }
            
            var userInfo = anError.userInfo
            userInfo[NSLocalizedDescriptionKey] = errorString
            
            return NSError(domain: anError.domain, code: anError.code, userInfo: userInfo)
        }
        return nil
    }

}

extension Alamofire.Request {
    class func imageResponseSerializer() -> GenericResponseSerializer<UIImage> {
        return GenericResponseSerializer { request, response, data in
            if data == nil || data?.length == 0 {
                return (nil, nil)
            }
            
            return (UIImage(data: data!, scale: UIScreen.mainScreen().scale), nil)
        }
    }
    
    func responseImage(completionHandler: (NSURLRequest, NSHTTPURLResponse?, UIImage?, NSError?) -> Void) -> Self {
        
        return response(
            responseSerializer: Request.imageResponseSerializer(),
            completionHandler: completionHandler
        )
    }
}
