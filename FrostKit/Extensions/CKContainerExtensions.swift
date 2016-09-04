//
//  CKContainerExtensions.swift
//
//  Created by James Barrow on 06/06/2016.
//  Copyright © 2016 James Barrow. All rights reserved.
//

import Foundation
import CloudKit

public extension CKContainer {
    
    public func fetchUserRecord(desiredKeys: [String]? = nil, completionHandler: (CKRecord?, NSError?) -> Void) {
        
        fetchUserRecordIDWithCompletionHandler { (recordID, error) in
            
            if let anError = error {
                
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(nil, anError)
                })
                
            } else if let userRecordID = recordID {
                
                let operation = CKFetchRecordsOperation(recordIDs: [userRecordID])
                operation.qualityOfService = .UserInitiated
                operation.desiredKeys = desiredKeys
                operation.fetchRecordsCompletionBlock = { (records, error) in
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(records?[userRecordID], error)
                    })
                }
                
                let database = self.publicCloudDatabase
                database.addOperation(operation)
                
            } else {
                
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(nil, NSError.errorWithMessage("Could not get user record with no record ID."))
                })
            }
        }
    }
    
    public func update(userRecord: CKRecord, progressHandler: ((Double) -> Void)? = nil, completionHandler: (CKRecord?, NSError?) -> Void) {
        publicCloudDatabase.saveRecord(userRecord, progressHandler: progressHandler, completionHandler: completionHandler)
    }
    
    public func update(userRecordWithObject object: CKRecordValue?, key: String, progressHandler: ((Double) -> Void)? = nil, completionHandler: (CKRecord?, NSError?) -> Void) {
        
        fetchUserRecord([]) { (record, error) in
            
            if let aRecord = record {
                
                aRecord.setObject(object, forKey: key)
                self.update(aRecord, progressHandler: progressHandler, completionHandler: completionHandler)
                
            } else {
                
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(nil, NSError.errorWithMessage("No user record found!"))
                })
            }
        }
    }
    
}
