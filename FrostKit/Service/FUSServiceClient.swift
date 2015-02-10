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
    case Custom(String, Int?)
    
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
            if let name = FrostKit.shared.FUSName {
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
        case .Custom(let urlString, _):
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
    
    var page: Int? {
        switch self {
        case .Custom(_, let page):
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
        case .Custom(_, let page):
            if page != nil {
                return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["page": page!]).0
            } else {
                return mutableURLRequest
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
        if let OAuthClientToken = FrostKit.shared.OAuthClientToken {
            parameters["client_id"] = OAuthClientToken
        }
        if let OAuthClientSecret = FrostKit.shared.OAuthClientSecret {
            parameters["client_secret"] = OAuthClientSecret
        }
        
        Alamofire.request(Router.Token(parameters)).validate().responseJSON { (request, response, responseJSON, responseError) -> Void in
            if let anError = responseError {
                completed(error: self.errorForResponse(response, json: responseJSON, origError: anError))
            } else if let jsonDict = responseJSON as? NSDictionary {
                UserStore.current.username = username
                UserStore.current.oAuthToken = OAuthToken(json: jsonDict, requestDate: requestDate)
                UserStore.saveUser()
                completed(error: self.errorForResponse(response, json: responseJSON, origError: responseError))
            } else {
                completed(error: NSError.errorWithMessage("Returned JSON is not a NSDictionary: \(responseJSON)"))
            }
        }
    }
    
    /**
    Refresh an `OAuthToken` if it has expired.
    
    :param: completed Is called on completion of the request and returns an error if the process failed, otherwise it retuens `nil`.
    :param: force       Forces the OAuth token to refresh even if it hasn't expired.
    */
    public class func refreshOAuthToken(completed: (error: NSError?) -> (), force: Bool = false) {
        
        if let oAuthToken = UserStore.current.oAuthToken {
            
            if force == false {
                if oAuthToken.expired == false {
                    completed(error: nil)
                    return
                }
            }
            
            let requestDate = NSDate()
            var parameters = ["grant_type": "refresh_token", "refresh_token": oAuthToken.refreshToken]
            if let OAuthClientToken = FrostKit.shared.OAuthClientToken {
                parameters["client_id"] = OAuthClientToken
            }
            if let OAuthClientSecret = FrostKit.shared.OAuthClientSecret {
                parameters["client_secret"] = OAuthClientSecret
            }
            
            Alamofire.request(Router.Token(parameters)).validate().responseJSON { (request, response, responseJSON, responseError) -> Void in
                if let anError = responseError {
                    completed(error: self.errorForResponse(response, json: responseJSON, origError: anError))
                } else if let jsonDict = responseJSON as? NSDictionary {
                    UserStore.current.oAuthToken = OAuthToken(json: jsonDict, requestDate: requestDate)
                    UserStore.saveUser()
                    completed(error: self.errorForResponse(response, json: responseJSON, origError: responseError))
                } else {
                    completed(error: NSError.errorWithMessage("Returned JSON is not a NSDictionary: \(responseJSON)"))
                }
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
        Alamofire.request(Router.Sections).validate().responseJSON({ (requestObject, responseObject, responseJSON, responseError) -> Void in
            if let anError = responseError {
                completed(error: self.errorForResponse(responseObject, json: responseJSON, origError: anError))
            } else if let jsonDictionary = responseJSON as? [String: AnyObject] {
                if let jsonArray = jsonDictionary["sections"] as? [[String: String]] {
                    UserStore.current.sections = jsonArray
                    completed(error: self.errorForResponse(responseObject, json: responseJSON, origError: responseError))
                } else {
                    completed(error: NSError.errorWithMessage("Returned JSON is not an Array: \(responseJSON)"))
                }
            } else {
                completed(error: NSError.errorWithMessage("Returned JSON is not a Dictionary: \(responseJSON)"))
            }
        })
    }
    
    // MARK: - Generic Methods
    
    /**
    A generic request method for calling .Sections for .Custom from the Router.
    
    :param: URLRequest The URL request either manually created or generated by the Router.
    :param: completed  The completed callback that returns the response JSON and/or an error.
    
    :returns: An Alamofire request.
    */
    public class func request(URLRequest: Router, completed: (json: AnyObject?, error: NSError?) -> ()) -> Alamofire.Request {
        return Alamofire.request(URLRequest).validate().responseJSON({ (requestObject, responseObject, responseJSON, responseError) -> Void in
            completed(json: responseJSON, error: self.errorForResponse(responseObject, json: responseJSON, origError: responseError))
        })
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
            
            if let errorDictionary = json as? NSDictionary {
                if let errorDescription = errorDictionary["error_description"] as? String {
                    errorString += "\(errorDescription)"
                }
            }
            return NSError.errorWithMessage(errorString)
        }
        return nil
    }

}
