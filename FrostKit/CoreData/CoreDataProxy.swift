//
//  CoreDataProxy.swift
//  FrostKit
//
//  Created by James Barrow on 18/06/2016.
//  Copyright © 2016 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataProxy {
    
    public var storeName: String! { return nil }
    public var groupIdentifier: String? { return nil }
    public var modelURL: URL! { return nil }
    public static let shared = CoreDataProxy()
    
    // MARK: - Core Data stack
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        return NSManagedObjectModel(contentsOf: self.modelURL)
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let url: URL
        if let groupIdentifier = self.groupIdentifier, let sharedContainerURL = LocalStorage.sharedContainerURL(groupIdentifier: groupIdentifier) {
            url = sharedContainerURL
        } else {
            url = LocalStorage.documentsURL().appendingPathComponent(self.storeName)
        }
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch var error {
            coordinator = nil
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error: \(error.localizedDescription)")
        }
        
        return coordinator
    }()
    
    private lazy var managedObjectContextBase: NSManagedObjectContext = {
        
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            fatalError()
        }
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        //        managedObjectContext.mergePolicy = NSMergePolicy(mergeType: .MergeByPropertyObjectTrumpMergePolicyType)
        
        return managedObjectContext
    }()
    
    public lazy var managedObjectContextMain: NSManagedObjectContext = {
        
        let context = self.managedObjectContextBase
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.parent = context
        //        managedObjectContext.mergePolicy = NSMergePolicy(mergeType: .MergeByPropertyObjectTrumpMergePolicyType)
        
        return managedObjectContext
    }()
    
    public class func temporaryManagedObjectContext() -> NSManagedObjectContext {
        
        let context = CoreDataProxy.shared.managedObjectContextMain
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.parent = context
        //        managedObjectContext.mergePolicy = NSMergePolicy(mergeType: .MergeByPropertyObjectTrumpMergePolicyType)
        
        return managedObjectContext
    }
    
    // MARK: - Core Data Saving support
    
    private class func saveContextBase(_ complete: (() -> Void)?) {
        CoreDataProxy.saveContext(context: CoreDataProxy.shared.managedObjectContextBase, complete: complete)
    }
    
    private class func saveContextMain(_ complete: (() -> Void)?) {
        CoreDataProxy.saveContext(context: CoreDataProxy.shared.managedObjectContextMain, complete: complete)
    }
    
    public class func saveMainAndBaseContexts(_ complete: (() -> Void)? = nil) {
        CoreDataProxy.saveContextMain {
            CoreDataProxy.saveContextBase {
                complete?()
            }
        }
    }
    
    public class func saveContext(context: NSManagedObjectContext, complete: (() -> Void)? = nil) {
        context.perform {
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error: \(error.localizedDescription)")
                }
            }
            complete?()
        }
    }
}
