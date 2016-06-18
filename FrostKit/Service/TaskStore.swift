//
//  TaskStore.swift
//  FrostKit
//
//  Created by James Barrow on 26/01/2015.
//  Copyright © 2015-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation

/// 
/// The task store keeps track of all tasks passed into it. It stops duplicate tesks being called by canceling any already running tasks passed to it, until they are done and removed.
/// 
/// It will however be able to differentuate between different page tasks, and so not cancel a page `n` task if page `n+1` is also added.
///
public class TaskStore {
    
    /// The store to hold references to the tasks being managed.
    private lazy var store = Dictionary<String, URLSessionTask>()
    /// Describes if the store is locked `true` or not `false`. This is set to `false` by default and is only locked when canceling all tasks.
    private var locked = false
    
    /**
    Add a rquest to the store with a url string (normally absolute is sugested) to use as the key to store the task under in the store.
    
    - parameter task: The task to store and manage.
    - parameter urlString: The url string to use as the key.
    */
    public func add(_ task: URLSessionTask, urlString: String) {
        if locked == true {
            return
        }
        
        if store[urlString] != nil {
            task.cancel()
        } else {
            store[urlString] = task
        }
    }
    
    /**
    Remove a task using a url string (normally absolute is sugested) as the key.
    
    - parameter urlString: The url string to use as the key of the task to remove.
    */
    public func remove(taskWithURL urlString: String) {
        if let storedTask = store[urlString] {
            storedTask.cancel()
            store.removeValue(forKey: urlString)
        }
    }
    
    /**
    Cancel all tasks currently in the store. This function will lock the store as it cancels all it's content, stopping any new tasks to be added.
    */
    public func cancelAllTasks() {
        locked = true
        for (_, task) in store {
            task.cancel()
        }
        locked = false
    }
    
    /**
    Checks to see if there is a rquest in the store that matches the passed in url string.
    
    - parameter urlString: The url string to check for.
    
    - returns: If a matching task is found then `true` is returned, otherwise `false` is returned.
    */
    public func contains(taskWithURL urlString: String) -> Bool {
        let containsTask = store[urlString] != nil
        return containsTask
    }
    
}
