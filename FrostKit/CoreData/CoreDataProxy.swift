//
//  CoreDataProxy.swift
//  FrostKit
//
//  Created by James Barrow on 18/06/2016.
//  Copyright © 2016-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataProxy {
    
    public var storeName: String! { return nil }
    public var groupIdentifier: String? { return nil }
    public var modelURL: NSURL! { return nil }
    public static let shared = CoreDataProxy()
    
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
            url = sharedContainerURL.URLByAppendingPathComponent(self.storeName)
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
    
    private lazy var managedObjectContextBase: NSManagedObjectContext = {
        
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            fatalError()
        }
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
//        managedObjectContext.mergePolicy = NSMergePolicy(mergeType: .MergeByPropertyObjectTrumpMergePolicyType)
        
        return managedObjectContext
    }()
    
    public lazy var managedObjectContextMain: NSManagedObjectContext = {
        
        let context = self.managedObjectContextBase
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.parentContext = context
//        managedObjectContext.mergePolicy = NSMergePolicy(mergeType: .MergeByPropertyObjectTrumpMergePolicyType)
        
        return managedObjectContext
    }()
    
    public class func temporaryManagedObjectContext() -> NSManagedObjectContext {
        
        let context = CoreDataProxy.shared.managedObjectContextMain
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.parentContext = context
//        managedObjectContext.mergePolicy = NSMergePolicy(mergeType: .MergeByPropertyObjectTrumpMergePolicyType)
        
        return managedObjectContext
    }
    
    // MARK: - Core Data Saving support
    
    private class func saveContextBase(complete: (() -> Void)?) {
        CoreDataProxy.saveContext(CoreDataProxy.shared.managedObjectContextBase, complete: complete)
    }
    
    private class func saveContextMain(complete: (() -> Void)?) {
        CoreDataProxy.saveContext(CoreDataProxy.shared.managedObjectContextMain, complete: complete)
    }
    
    public class func saveMainAndBaseContexts(complete: (() -> Void)? = nil) {
        CoreDataProxy.saveContextMain({ () -> Void in
            CoreDataProxy.saveContextBase({
                complete?()
            })
        })
    }
    
    public class func saveContext(context: NSManagedObjectContext, complete: (() -> Void)? = nil) {
        context.performBlock({ () -> Void in
            if context.hasChanges {
                do {
                    try context.save()
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
