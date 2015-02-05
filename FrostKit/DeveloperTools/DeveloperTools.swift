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
    public var numberOfBaseURLs: Int {
        get { return baseURLs.count }
    }
    
    override init() {
        super.init()
        
        if let baseURLsPlistPath = NSBundle.mainBundle().pathForResource("DeveloperTools", ofType: "plist") {
            if let loadedBaseURLsDict = NSDictionary(contentsOfFile: baseURLsPlistPath) {
                if let loadedBaseURLs = loadedBaseURLsDict["URLs"] as? Array<String> {
                    baseURLs = loadedBaseURLs + baseURLs
                }
                
                #if DEBUG
                    if let defaultURLIndex = loadedBaseURLsDict["DefaultDebugIndex"] as? Int {
                        urlIndex = defaultURLIndex
                    }
                    #else
                    if let defaultURLIndex = loadedBaseURLsDict["DefaultProductionIndex"] as? Int {
                    urlIndex = defaultURLIndex
                    }
                #endif
            }
            
            let tapGesture = tapGestureRecogniser()
            currentGestureRecogniser = tapGesture
        } else {
            NSLog("WARNING! No DeveloperTools.plist file found.")
        }
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        urlIndex = userDefaults.integerForKey("DeveloperToolsURLIndex")
        if let customURL = NSUserDefaults.standardUserDefaults().objectForKey("DeveloperToolsCustomURL") as? String {
            baseURLs[baseURLs.count-1] = customURL
        }
    }
    
    public func registerViewController(viewController: UIViewController) {
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
    
    public func unregisterViewController(viewController: UIViewController) {
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
        
        NSLog("%@ Unlock Phase One", self)
        
        resetGestureRecogniser()
        
        let swipeGesture = swipeLeftGestureRecogniser()
        currentGestureRecogniser = swipeGesture
        addGestureRecognizerToRegisteredViewControllers(swipeGesture)
        
        startTimer()
    }
    
    internal func unlockPhaseTwo(sender: AnyObject) {
        NSLog("%@ Unlock Phase Two", self)
        
        resetGestureRecogniser()
        
        let swipeGesture = swipeRightGestureRecogniser()
        currentGestureRecogniser = swipeGesture
        addGestureRecognizerToRegisteredViewControllers(swipeGesture)
        
        startTimer()
    }
    
    internal func unlockPhaseThree(sender: AnyObject) {
        NSLog("%@ Unlock Phase Three", self)
        
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
        NSLog("%@ Reset", self)
        
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
    
    public func baseURL() -> String? {
        return baseURLFromIndex(urlIndex)
    }
    
    public func baseURLFromIndex(index: Int) -> String? {
        return baseURLs[index]
    }
    
    public func setBaseURLIndex(index: Int) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(index, forKey: "DeveloperToolsURLIndex")
        userDefaults.synchronize()
    }
    
    public func setCustomURL(customURL: String) {
        
        baseURLs[baseURLs.count-1] = customURL
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(customURL, forKey: "DeveloperToolsCustomURL")
        userDefaults.synchronize()
    }

}
