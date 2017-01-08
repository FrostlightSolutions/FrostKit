//
//  CKContainerExtensions.swift
//
//  Created by James Barrow on 06/06/2016.
//  Copyright © 2016 - 2017 James Barrow. All rights reserved.
//

import Foundation
import CloudKit

public extension CKContainer {
    
    public func fetchUserRecord(desiredKeys: [String]? = nil, completionHandler: @escaping (CKRecord?, Error?) -> Void) {
        
        fetchUserRecordID { (recordID, error) in
            
            if let anError = error {
                
                DispatchQueue.main.async {
                    completionHandler(nil, anError)
                }
                
            } else if let userRecordID = recordID {
                
                let operation = CKFetchRecordsOperation(recordIDs: [userRecordID])
                operation.qualityOfService = .userInitiated
                operation.desiredKeys = desiredKeys
                operation.fetchRecordsCompletionBlock = { (records, error) in
                    
                    DispatchQueue.main.async {
                        completionHandler(records?[userRecordID], error)
                    }
                }
                
                let database = self.publicCloudDatabase
                database.add(operation)
                
            } else {
                
                DispatchQueue.main.async {
                    completionHandler(nil, NSError.error(withMessage: "Could not get user record with no record ID.") as Error)
                }
            }
        }
    }
    
    public func update(userRecord: CKRecord, progressHandler: ((Double) -> Void)? = nil, completionHandler: @escaping (CKRecord?, Error?) -> Void) {
        publicCloudDatabase.save(record: userRecord, progressHandler: progressHandler, completionHandler: completionHandler)
    }
    
    public func update(userRecordWithObject object: CKRecordValue?, key: String, progressHandler: ((Double) -> Void)? = nil, completionHandler: @escaping (CKRecord?, Error?) -> Void) {
        
        fetchUserRecord(desiredKeys: []) { (record, error) in
            
            if let aRecord = record {
                
                aRecord.setObject(object, forKey: key)
                self.update(userRecord: aRecord, progressHandler: progressHandler, completionHandler: completionHandler)
                
            } else {
                
                DispatchQueue.main.async {
                    completionHandler(nil, NSError.error(withMessage: "No user record found!"))
                }
            }
        }
    }
    
}
