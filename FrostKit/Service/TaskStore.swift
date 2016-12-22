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
    private lazy var store = [String: Any]()
    /// Describes if the store is locked `true` or not `false`. This is set to `false` by default and is only locked when canceling all tasks.
    private var locked = false
    
    /// Add a rquest to the store with a url string (normally absolute is sugested) to use as the key to store the task under in the store.
    ///
    /// - Parameters:
    ///   - task: The task to store and manage.
    ///   - urlString: The url string to use as the key.
    /// - Returns: `true` if added or `false` if not (either from lock or already existing in the store).
    public func add(_ task: URLSessionTask, urlString: String) -> Bool {
        
        if locked == true || store[urlString] != nil {
            task.cancel()
            return false
        }
        
        store[urlString] = task
        return true
    }
    
    /// Add a rquest to the store with a url string (normally absolute is sugested) to use as the key to store the operation under in the store.
    ///
    /// - Parameters:
    ///   - operation: The operation to store and manage.
    ///   - urlString: The url string to use as the key.
    /// - Returns: `true` if added or `false` if not (either from lock or already existing in the store).
    public func add(_ operation: Operation, urlString: String) -> Bool {
        
        if locked == true || store[urlString] != nil {
            operation.cancel()
            return false
        }
        
        store[urlString] = operation
        return true
    }
    
    /// Remove a task using a url string (normally absolute is sugested) as the key.
    ///
    /// - Parameter urlString: The url string to use as the key of the task to remove.
    public func remove(taskWithURL urlString: String) {
        
        if let removedItem = store.removeValue(forKey: urlString) {
            cancel(removedItem)
        }
    }
    
    /// Internal function for canceling an item in the store, when it's unknown if it's a task or operation.
    ///
    /// - Parameter item: The item (task/operation) to cancel.
    private func cancel(_ item: Any) {
        
        if let storedTask = item as? URLSessionTask {
            storedTask.cancel()
        } else if let storedOperation = item as? Operation {
            storedOperation.cancel()
        }
    }
    
    /// Cancel all tasks currently in the store. This function will lock the store as it cancels all it's content, stopping any new tasks to be added.
    public func cancelAllTasks() {
        locked = true
        for (_, item) in store {
            cancel(item)
        }
        locked = false
    }
    
    /// Checks to see if there is a rquest in the store that matches the passed in url string.
    ///
    /// - Parameter urlString: The url string to check for.
    /// - Returns: If a matching task is found then `true` is returned, otherwise `false` is returned.
    public func contains(taskWithURL urlString: String) -> Bool {
        return store[urlString] != nil
    }
    
}
