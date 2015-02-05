//
//  DeveloperTools.swift
//  FrostKit
//
//  Created by James Barrow on 13/01/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit

public class DeveloperTools: NSObject {

    // MARK: - Singleton
    
    public class var shared: DeveloperTools {
        struct Singleton {
            static let instance : DeveloperTools = DeveloperTools()
        }
        return Singleton.instance
    }
    
    private let developerToolsPlistPath = NSBundle.mainBundle().pathForResource("DeveloperTools", ofType: "plist")
    private var developerToolsDict: NSDictionary? {
        if let developerToolsPlistPath = self.developerToolsPlistPath {
            return NSDictionary(contentsOfFile: developerToolsPlistPath)
        } else {
            return nil
        }
    }
    private let storyboard = UIStoryboard(name: "DeveloperToolsStoryboard", bundle: nil)
    private lazy var viewControllers = Array<UIViewController>()
    private var currentViewControllerIndex = NSNotFound
    private var currentViewController: UIViewController? {
        if currentViewControllerIndex < viewControllers.count {
            return viewControllers[currentViewControllerIndex]
        } else {
            return nil
        }
    }
    private var currentGestureRecogniser: UIGestureRecognizer?
    private var timer: NSTimer?
    private var baseURLs = [""]
    private var urlIndex = 0
    internal var numberOfBaseURLs: Int {
        get { return baseURLs.count }
    }
    
    override init() {
        super.init()
        
        if let developerToolsDict = self.developerToolsDict {
            if let loadedBaseURLs = developerToolsDict["URLs"] as? Array<String> {
                baseURLs = loadedBaseURLs + baseURLs
            }
            
            #if DEBUG
                if let defaultURLIndex = developerToolsDict["DefaultDebugIndex"] as? Int {
                urlIndex = defaultURLIndex
                }
                #else
                if let defaultURLIndex = loadedBaseURLsDict["DefaultProductionIndex"] as? Int {
                urlIndex = defaultURLIndex
                }
            #endif
        } else {
            NSLog("Developer Tools WARNING! No DeveloperTools.plist file found, only custom URLs will be available. Check that there is a DeveloperTools.plist file included in the project.")
        }
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        urlIndex = userDefaults.integerForKey("DeveloperToolsURLIndex")
        if let customURL = NSUserDefaults.standardUserDefaults().objectForKey("DeveloperToolsCustomURL") as? String {
            baseURLs[baseURLs.count-1] = customURL
        }
    }
    
    // MARK: - Register Methods
    
    public class func registerViewController(viewController: UIViewController) {
        DeveloperTools.shared.registerViewController(viewController)
    }
    
    func registerViewController(viewController: UIViewController) {
        if contains(viewControllers, viewController) == false {
            viewControllers.append(viewController)
            NSLog("Registeed \(viewController) for Developer Tools")
        }
        
        if let index = find(viewControllers, viewController) {
            currentViewControllerIndex = index
        } else {
            currentViewControllerIndex = NSNotFound
        }
        
        if let currentGestureRecogniser = self.currentGestureRecogniser {
            addGestureRecognizerToRegisteredViewControllers(currentGestureRecogniser)
        }
    }
    
    public class func unregisterViewController(viewController: UIViewController) {
        DeveloperTools.shared.unregisterViewController(viewController)
    }
    
    func unregisterViewController(viewController: UIViewController) {
        if let index = find(viewControllers, viewController) {
            if let currentGestureRecogniser = self.currentGestureRecogniser {
                viewController.view.removeGestureRecognizer(currentGestureRecogniser)
            }
            viewControllers.removeAtIndex(index)
            NSLog("Unregisteed \(viewController) for Developer Tools")
        }
        
        if viewControllers.count > 0 {
            currentViewControllerIndex = viewControllers.count - 1
        } else {
            currentViewControllerIndex = NSNotFound
        }
        
        if let currentGestureRecogniser = self.currentGestureRecogniser {
            addGestureRecognizerToRegisteredViewControllers(currentGestureRecogniser)
        }
    }
    
    // MARK: - Gesture Methods
    
    private func addGestureRecognizerToRegisteredViewControllers(gestureRecognizer: UIGestureRecognizer) {
        for viewController in viewControllers {
            viewController.view.addGestureRecognizer(gestureRecognizer)
        }
    }
    
    private func removeGestureRecognizerFromRegisteredViewControllers(gestureRecognizer: UIGestureRecognizer) {
        for viewController in viewControllers {
            viewController.view.removeGestureRecognizer(gestureRecognizer)
        }
    }
    
    // MARK: - Unlock Developer Tools Methods
    
    private func tapGestureRecogniser() -> UIGestureRecognizer {
        let tapGesture = UITapGestureRecognizer(target: self, action: "unlockPhaseOne:")
        tapGesture.numberOfTapsRequired = 6
        return tapGesture
    }
    
    private func swipeLeftGestureRecogniser() -> UIGestureRecognizer {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: "unlockPhaseTwo:")
        swipeGesture.direction = .Left
        return swipeGesture
    }
    
    private func swipeRightGestureRecogniser() -> UIGestureRecognizer {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: "unlockPhaseThree:")
        swipeGesture.direction = .Right
        return swipeGesture
    }
    
    internal func unlockPhaseOne(sender: AnyObject) {
        
        if NSUserDefaults.standardUserDefaults().boolForKey("DeveloperToolsAvailability") == false {
            return
        }
        
        NSLog("%@ Unlock Phase One", 1)
        
        resetGestureRecogniser()
        
        let swipeGesture = swipeLeftGestureRecogniser()
        currentGestureRecogniser = swipeGesture
        addGestureRecognizerToRegisteredViewControllers(swipeGesture)
        
        startTimer()
    }
    
    internal func unlockPhaseTwo(sender: AnyObject) {
        NSLog("%@ Unlock Phase Two", 2)
        
        resetGestureRecogniser()
        
        let swipeGesture = swipeRightGestureRecogniser()
        currentGestureRecogniser = swipeGesture
        addGestureRecognizerToRegisteredViewControllers(swipeGesture)
        
        startTimer()
    }
    
    internal func unlockPhaseThree(sender: AnyObject) {
        NSLog("%@ Unlock Phase Three", 3)
        
        resetGestureRecogniser()
        
        // Present Tools
        if let viewController = currentViewController {
            let developerToolsVC = storyboard.instantiateInitialViewController() as UIViewController
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                developerToolsVC.modalPresentationStyle = .PageSheet
            }
            viewController.presentViewController(developerToolsVC, animated: true, completion: { () -> Void in
                self.reset()
            })
        }
    }
    
    private func resetGestureRecogniser() {
        stopTimer()
        
        if let currentGestureRecogniser = self.currentGestureRecogniser {
            removeGestureRecognizerFromRegisteredViewControllers(currentGestureRecogniser)
        }
    }
    
    internal func reset() {
        NSLog("%@ Reset", 4)
        
        resetGestureRecogniser()
        
        let tapGesture = tapGestureRecogniser()
        currentGestureRecogniser = tapGesture
        addGestureRecognizerToRegisteredViewControllers(tapGesture)
    }
    
    private func startTimer() {
        stopTimer()
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "reset", userInfo: nil, repeats: false)
    }
    
    private func stopTimer() {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    // MARK: - Base Server URL Methods
    
    public class func baseURL() -> String {
        if let baseURL = DeveloperTools.shared.baseURLFromIndex(DeveloperTools.shared.urlIndex) {
            return baseURL
        } else {
            NSLog("Developer Tools WARNING! No BaseURL found. Check that there is a DeveloperTools.plist file included in the project and it has a URL in the URLs list.")
            return ""
        }
    }
    
    func baseURLFromIndex(index: Int) -> String? {
        return baseURLs[index]
    }
    
    func setBaseURLIndex(index: Int) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(index, forKey: "DeveloperToolsURLIndex")
        userDefaults.synchronize()
    }
    
    func setCustomURL(customURL: String) {
        
        baseURLs[baseURLs.count-1] = customURL
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(customURL, forKey: "DeveloperToolsCustomURL")
        userDefaults.synchronize()
    }
    
    // MARK: - OAuth Methods
    
    public class func oAuthClientToken() -> String {
        if let clientToken = DeveloperTools.shared.developerToolsDict?["OAuthClientToken"] as? String {
            return clientToken
        } else {
            NSLog("Developer Tools WARNING! No OAuth client token found. Check that there is a DeveloperTools.plist file included in the project and it has an OAuthClientToken")
            return ""
        }
    }
    
    public class func oAuthClientSecret() -> String {
        if let clientSecret = DeveloperTools.shared.developerToolsDict?["OAuthClientSecret"] as? String {
            return clientSecret
        } else {
            NSLog("Developer Tools WARNING! No OAuth client secret found. Check that there is a DeveloperTools.plist file included in the project and it has an OAuthClientSecret")
            return ""
        }
    }

}
