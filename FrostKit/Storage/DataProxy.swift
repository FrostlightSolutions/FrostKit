//
//  DataProxy.swift
//  DataProxy
//
//  Created by James Barrow on 18/06/2016.
//  Copyright (c) 2015-Current Pig on a Hill Productions. All rights reserved.
//

import Foundation
import CoreData

public class DataProxy {
    
    public var storeName: String! { return nil }
    public var groupIdentifier: String? { return nil }
    public var modelURL: NSURL! { return nil }
    public static let shared = DataProxy()
    
    // MARK: - Core Data stack
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        return NSManagedObjectModel(contentsOfURL: self.modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let url: NSURL
        if let groupIdentifier = self.groupIdentifier, sharedContainerURL = LocalStorage.sharedContainerURL(groupIdentifier) {
            url = sharedContainerURL
        } else {
            url = LocalStorage.documentsURL().URLByAppendingPathComponent(self.storeName)
        }
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
        } catch var error as NSError {
            coordinator = nil
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error.userInfo)")
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    
    public lazy var managedObjectContextMain: NSManagedObjectContext? = {
        
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.mergePolicy = NSMergePolicy(mergeType: .MergeByPropertyStoreTrumpMergePolicyType)
        
        return managedObjectContext
    }()
    
    public lazy var managedObjectContextPrivate: NSManagedObjectContext? = {
        
        let context = self.managedObjectContextMain
        if context == nil {
            return nil
        }
        
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.parentContext = context
        managedObjectContext.mergePolicy = NSMergePolicy(mergeType: .MergeByPropertyStoreTrumpMergePolicyType)
        
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    public func saveContextMain(complete: (() -> Void)?) {
        saveContext(managedObjectContextMain, complete: complete)
    }
    
    public func saveContextPrivate(complete: (() -> Void)?) {
        saveContext(managedObjectContextPrivate, complete: complete)
    }
    
    public func saveAllContexts(complete: (() -> Void)?) {
        saveContextPrivate { () -> Void in
            self.saveContextMain({ () -> Void in
                complete?()
            })
        }
    }
    
    public func saveContext(context: NSManagedObjectContext?, complete: (() -> Void)?) {
        context?.performBlock({ () -> Void in
            if context!.hasChanges {
                do {
                    try context!.save()
                } catch let error as NSError {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error: \(error.localizedDescription)")
                } catch {
                    fatalError()
                }
            }
            complete?()
        })
    }
    
}
