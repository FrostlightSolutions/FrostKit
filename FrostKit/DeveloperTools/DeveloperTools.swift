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
    
    private let storyboard = UIStoryboard(name: "DeveloperToolsStoryboard", bundle: NSBundle(forClass: DeveloperTools.self))
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
        
        if let baseURLs = FrostKit.baseURLs {
            self.baseURLs = FrostKit.baseURLs + self.baseURLs
        }
        
        #if DEBUG
            urlIndex = FrostKit.defaultDebugIndex
        #else
            urlIndex = FrostKit.defaultProductionIndex
        #endif
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.objectForKey("DeveloperToolsURLIndex") != nil {
            urlIndex = userDefaults.integerForKey("DeveloperToolsURLIndex")
        }
        if let customURL = NSUserDefaults.standardUserDefaults().objectForKey("DeveloperToolsCustomURL") as? String {
            baseURLs[baseURLs.count-1] = customURL
        }
        
        let tapGesture = tapGestureRecogniser()
        currentGestureRecogniser = tapGesture
        
        NSLog("Developer Tools Setup")
    }
    
    // MARK: - Register Methods
    
    public class func registerViewController(viewController: UIViewController) {
        DeveloperTools.shared.registerViewController(viewController)
    }
    
    func registerViewController(viewController: UIViewController) {
        if viewControllers.contains(viewController) == false {
            viewControllers.append(viewController)
            NSLog("Registeed \(viewController) for Developer Tools")
        }
        
        if let index = viewControllers.indexOf(viewController) {
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
        if let index = viewControllers.indexOf(viewController), let currentGestureRecogniser = self.currentGestureRecogniser {
            viewController.view.removeGestureRecognizer(currentGestureRecogniser)
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
        if let viewController = currentViewController, developerToolsVC = storyboard.instantiateInitialViewController() {
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
    
}
