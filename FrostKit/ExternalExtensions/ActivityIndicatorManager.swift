//
//  ActivityIndicatorManager.swift
//  FrostKit
//
//  Created by James Barrow on 17/02/2015.
//  Copyright © 2015-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit
import FrostKit

///
/// NOTE: If the project is using Alamofire, use AlamofireNetworkActivityIndicator. https://github.com/Alamofire/AlamofireNetworkActivityIndicator
///
/// Tracks the network requests using NSNotificationCenter to work out if the activity indicator should be showing.
///
/// Based off of AFNetworkActivityIndicatorManager, this has been genrallised to work with any network request in FrostKit.
/// https://github.com/AFNetworking/AFNetworking/blob/master/UIKit%2BAFNetworking/AFNetworkActivityIndicatorManager.m
///
/// To enable the activity indicator manager use the follwoing code.
/// `ActivityIndicatorManager.shared.enabled = true`
///
/// To increment or decrement the curent activitys count, use the following calls respectively.
/// `NotificationCenter.default.post(name: NSNotification.Name(rawValue: NetworkRequestDidBeginNotification), object: nil)`
/// `NotificationCenter.default.post(name: NSNotification.Name(rawValue: NetworkRequestDidCompleteNotification), object: nil)`
///
public class ActivityIndicatorManager: NSObject {
    
    /// Determins if the activity indicator manager should be enabled or not.
    public var enabled = false
    /// Returns `true` if the activity count is more than 0, and so visible, or `false` if not.
    public var isNetworkActivityIndicatorVisible: Bool { return activityCount > 0 }
    private var _activityCount: Int = 0
    private var activityCount: Int {
        get { return _activityCount }
        set {
            lockQueue.sync {
                self._activityCount = newValue
            }
            
            DispatchQueue.main.async {
                self.updateNetworkActivityIndicatorVisibilityDelayed()
            }
        }
    }
    private lazy var activityIndicatorVisibilityTimer = Timer()
    private let activityIndicatorInvisibilityDelay = 0.17
    private let lockQueue = DispatchQueue(label: "com.FrostKit.activityIndicator.lockQueue")
    
    // MARK: - Singleton & Init
    
    /// The shared manager object.
    public static let shared = ActivityIndicatorManager()
    
    private override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(networkRequest(didBegin:)), name: NSNotification.Name(rawValue: NetworkRequestDidBeginNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(networkRequest(didFinish:)), name: NSNotification.Name(rawValue: NetworkRequestDidCompleteNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        activityIndicatorVisibilityTimer.invalidate()
    }
    
    // MARK: - Notification Methods
    
    func networkRequest(didBegin notification: NSNotification) {
        incrementActivityCount()
    }
    
    func networkRequest(didFinish notification: NSNotification) {
        decrementActivityCount()
    }
    
    // MARK: - Update Methods
    
    func updateNetworkActivityIndicatorVisibility() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = self.isNetworkActivityIndicatorVisible
        }
    }
    
    private func updateNetworkActivityIndicatorVisibilityDelayed() {
        if enabled == true {
            if isNetworkActivityIndicatorVisible == false {
                activityIndicatorVisibilityTimer.invalidate()
                activityIndicatorVisibilityTimer = Timer(timeInterval: activityIndicatorInvisibilityDelay, target: self, selector: #selector(updateNetworkActivityIndicatorVisibility), userInfo: nil, repeats: false)
                RunLoop.main.add(activityIndicatorVisibilityTimer, forMode: .commonModes)
            } else {
                DispatchQueue.main.async {
                    self.updateNetworkActivityIndicatorVisibility()
                }
            }
        }
    }
    
    /**
     Increments the activity count by 1.
     
     This method should not be called directly, but called with a NotificationCenter post.
     `NotificationCenter.default.post(name: NSNotification.Name(rawValue: NetworkRequestDidBeginNotification), object: nil)`
     */
    public func incrementActivityCount() {
        willChangeValue(forKey: "activityCount")
        lockQueue.sync {
            self.activityCount += 1
        }
        didChangeValue(forKey: "activityCount")
        
        DispatchQueue.main.async {
            self.updateNetworkActivityIndicatorVisibilityDelayed()
        }
    }
    
    /**
     Decrements the activity count by 1.
     
     This method should not be called directly, but called with a NotificationCenter post.
     `NotificationCenter.default.post(name: NSNotification.Name(rawValue: NetworkRequestDidCompleteNotification), object: nil)`
     */
    public func decrementActivityCount() {
        willChangeValue(forKey: "activityCount")
        lockQueue.sync {
            self.activityCount = max(self.activityCount - 1, 0)
        }
        didChangeValue(forKey: "activityCount")
        
        DispatchQueue.main.async {
            self.updateNetworkActivityIndicatorVisibilityDelayed()
        }
    }
    
}
