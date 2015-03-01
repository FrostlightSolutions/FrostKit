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
    /// THe base URL parsed in form the developer tools plist.
    static let baseURLString = DeveloperTools.baseURL()
    
    case Root
    case Token([String: AnyObject])
    case Sections
    case Custom(String, Int?, [String: AnyObject]?)
    
    // MARK: URLRequestConvertible
    
    /// THe method for each case. The default is GET.
    var method: Alamofire.Method {
        switch self {
        case .Token:
            return .POST
        case .Sections, .Custom:
            return .GET
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
        default:
            return ""
        }
    }
    
    /// The absolute URL of the case.
    var URL: NSURL {
        switch self {
        case .Custom(let urlString, _, _):
            return NSURL(string: urlString)!
        default:
            let URL = NSURL(string: Router.baseURLString)!
            return URL.URLByAppendingPathComponent(path)
        }
    }
    
    /// The absolute string of the case.
    var absoluteString: String {
        return URL.absoluteString!
    }
    
    /// A reference string to save the call under.
    var saveString: String {
        switch self {
        case .Custom(let urlString, _, let parameters):
            var saveString = urlString
            
            if let someParameters = parameters {
                let keysArray = (someParameters as NSDictionary).allKeys as NSArray
                let sortedKeys = keysArray.sortedArrayUsingSelector("compare:") as! [String]
                for key in sortedKeys {
                    saveString = saveString.stringByAppendingPathComponent(someParameters[key] as! String)
                }
            }
            
            return saveString
        default:
            return absoluteString
        }
    }
    
    var page: Int? {
        switch self {
        case .Custom(_, let page, _):
            return page
        default:
            return nil
        }
    }
    
    /// The URL request of the case. Token requests to not include an Authorization HTTP header field, as that is what it is requesting.
    public var URLRequest: NSURLRequest {
        
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = method.rawValue
        mutableURLRequest.cachePolicy = .ReloadIgnoringLocalCacheData
        
        switch self {
        case .Token:
            break
        default:
            if let oAuthToken = UserStore.current.oAuthToken {
                mutableURLRequest.setValue("Bearer \(oAuthToken.accessToken)", forHTTPHeaderField: "Authorization")
            }
        }
        
        switch self {
        case .Token(let parameters):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
        case .Custom(_, let page, let extraParameters):
            var parameters = Dictionary<String, AnyObject>()
            
            if page != nil {
                parameters["page"] = page!
            }
            
            if extraParameters != nil {
                for (key, value) in extraParameters! {
                    parameters[key] = value
                }
            }
            
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
        default:
            return mutableURLRequest
        }
    }
}

/// 
/// The service client for a FUS based system. It provides methods for login, refreshing OAuth tokens and making generic requests.
///
public class FUSServiceClient: NSObject {
    
    // MARK: - Static Methods
    
    /**
    Login the the specified FUS server with username, password and a completed closure. This method does not return anything but store an `OAuthToken` object in the `UserStore`.
    
    :param: username  The username of the user to login.
    :param: password  The password of the user to login.
    :param: completed Is called on completion of the request and returns an error if the process failed, otherwise it retuens `nil`.
    */
    public class func loginUser(#username: String, password: String, completed: (error: NSError?) -> ()) {
        
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
    
    :param: completed Is called on completion of the request and returns an error if the process failed, otherwise it retuens `nil`.
    :param: force       Forces the OAuth token to refresh even if it hasn't expired.
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
    
    :param: completed Is called on completion of the request and returns an error if the process failed, otherwise it retuens `nil`.
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
    
    :param: URLRequest The URL request either manually created or generated by the Router.
    :param: completed  The completed callback that returns the response JSON and/or an error.
    
    :returns: An Alamofire request.
    */
    public class func request(URLRequest: Router, completed: (json: AnyObject?, error: NSError?) -> ()) -> Alamofire.Request {
        
        NSNotificationCenter.defaultCenter().postNotificationName(NetworkRequestDidBeginNotification, object: nil)
        return Alamofire.request(URLRequest).validate().responseJSON { (requestObject, responseObject, responseJSON, responseError) -> Void in
            completed(json: responseJSON, error: self.errorForResponse(responseObject, json: responseJSON, origError: responseError))
            NSNotificationCenter.defaultCenter().postNotificationName(NetworkRequestDidCompleteNotification, object: nil)
        }
    }
    
    // MARK: - Helper Methods
    
    /**
    Checks if an object is a URL path with a prefix of `http://` or `https://`.
    
    :param: item The item to check.
    
    :returns: Returns `true` if it is a path string or `false` if not.
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
    
    :param: response  The response that had the error, or `nil` if it doesn't exist.
    :param: json      The JSON response, or `nil` if there wasn't any.
    :param: origError The original error returned by Alamofire, or `nil` if there isn't any.
    
    :returns: An arror with a localized description of all the information passed in.
    */
    private class func errorForResponse(response: NSHTTPURLResponse?, json: AnyObject?, origError: NSError?) -> NSError? {
        if let anError = origError {
            var errorString = "\(anError.localizedDescription), "
            
            if let aResponse = response {
                errorString += "Status Code \(aResponse.statusCode), "
            }
            
            if let errorDictionary = json as? NSDictionary, let errorDescription = errorDictionary["error_description"] as? String {
                errorString += "\(errorDescription)"
            }
            
            var userInfo = Dictionary<NSObject, AnyObject>()
            if let errorUserInfo = anError.userInfo {
                userInfo = errorUserInfo
            }
            userInfo[NSLocalizedDescriptionKey] = errorString
            
            return NSError(domain: anError.domain, code: anError.code, userInfo: userInfo)
        }
        return nil
    }

}
