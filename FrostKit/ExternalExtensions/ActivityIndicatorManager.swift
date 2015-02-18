//
//  ActivityIndicatorManager.swift
//  FrostKit
//
//  Created by James Barrow on 17/02/2015.
//  Copyright (c) 2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit
import FrostKit

private let ActivityIndicatorLockQueue = "com.FrostKit.activityIndicator.lockqueue"

///
/// Tracks the network requests using NSNotificationCenter to work out if the activity indicator should be showing.
///
/// Based off of AFNetworkActivityIndicatorManager, this has been genrallised to work with any network request in FrostKit.
/// https://github.com/AFNetworking/AFNetworking/blob/master/UIKit%2BAFNetworking/AFNetworkActivityIndicatorManager.m
///
/// To enable the activity indicator manager use the follwoing code.
/// `ActivityIndicatorManager.sharedManager.enabled = true`
///
/// To increment or decrement the curent activitys count, use the following calls respectively.
/// `NSNotificationCenter.defaultCenter().postNotificationName(NetworkRequestDidBeginNotification, object: nil)`
/// `NSNotificationCenter.defaultCenter().postNotificationName(NetworkRequestDidCompleteNotification, object: nil)`
///
public class ActivityIndicatorManager: NSObject {
    
    /// Determins if the activity indicator manager should be enabled or not.
    public var enabled = false
    /// Returns `true` if the activity count is more than 0, and so visible, or `false` if not.
    public var networkActivityIndicatorVisible: Bool {
        return activityCount > 0
    }
    private var _activityCount: Int = 0
    private var activityCount: Int {
        get {
            return _activityCount
        }
        set {
            dispatch_sync(dispatch_queue_create(ActivityIndicatorLockQueue, nil)) {
                self._activityCount = newValue
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.updateNetworkActivityIndicatorVisibilityDelayed()
            })
        }
    }
    private lazy var activityIndicatorVisibilityTimer = NSTimer()
    private let activityIndicatorInvisibilityDelay = 0.17
    
    // MARK: - Singleton
    
    /**
    Returns the shared manager object.
    
    :returns: The shared manager object.
    */
    public class var sharedManager: ActivityIndicatorManager {
        struct Singleton {
            static let instance: ActivityIndicatorManager = ActivityIndicatorManager()
        }
        return Singleton.instance
    }
    
    private override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "networkRequestDidBegin:", name: NetworkRequestDidBeginNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "networkRequestDidFinish:", name: NetworkRequestDidCompleteNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        activityIndicatorVisibilityTimer.invalidate()
    }
    
    // MARK: - Notification Methods
    
    func networkRequestDidBegin(notification: NSNotification) {
        incrementActivityCount()
    }
    
    func networkRequestDidFinish(notification: NSNotification) {
        decrementActivityCount()
    }
    
    // MARK: -
    
    func updateNetworkActivityIndicatorVisibility() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = networkActivityIndicatorVisible
    }
    
    private func updateNetworkActivityIndicatorVisibilityDelayed() {
        if enabled == true {
            if networkActivityIndicatorVisible == false {
                activityIndicatorVisibilityTimer.invalidate()
                activityIndicatorVisibilityTimer = NSTimer(timeInterval: activityIndicatorInvisibilityDelay, target: self, selector: "updateNetworkActivityIndicatorVisibility", userInfo: nil, repeats: false)
                NSRunLoop.mainRunLoop().addTimer(activityIndicatorVisibilityTimer, forMode: NSRunLoopCommonModes)
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.updateNetworkActivityIndicatorVisibility()
                })
            }
        }
    }
    
    /**
    Increments the activity count by 1.
    
    This method should not be called directly, but called with an NSNotificationCenter post.
    `NSNotificationCenter.defaultCenter().postNotificationName(NetworkRequestDidBeginNotification, object: nil)
    */
    public func incrementActivityCount() {
        willChangeValueForKey("activityCount")
        dispatch_sync(dispatch_queue_create(ActivityIndicatorLockQueue, nil)) {
            self.activityCount += 1
        }
        didChangeValueForKey("activityCount")
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.updateNetworkActivityIndicatorVisibilityDelayed()
        })
    }
    
    /**
    Decrements the activity count by 1.
    
    This method should not be called directly, but called with an NSNotificationCenter post.
    `NSNotificationCenter.defaultCenter().postNotificationName(NetworkRequestDidCompleteNotification, object: nil)`
    */
    public func decrementActivityCount() {
        willChangeValueForKey("activityCount")
        dispatch_sync(dispatch_queue_create(ActivityIndicatorLockQueue, nil)) {
            self.activityCount = max(self.activityCount - 1, 0)
        }
        didChangeValueForKey("activityCount")
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.updateNetworkActivityIndicatorVisibilityDelayed()
        })
    }
    
}
