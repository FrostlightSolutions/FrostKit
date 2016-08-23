//
//  CKDatabaseExtensions.swift
//
//  Created by James Barrow on 06/06/2016.
//  Copyright © 2016 James Barrow. All rights reserved.
//

import Foundation
import CloudKit

extension CKDatabase {
    
    /**
     Searches the specified zone asynchronously and returns a count of records that match the query parameters.
     
     - parameter query:                  The query object containing the parameters for the search. This method throws an exception if this parameter is `nil`. For information about how to construct queries, see CKQuery Class Reference.
     - parameter zoneID:                 The ID of the zone to search. Search results are limited to records in the specified zone. Specify `nil` to search the default zone of the database.
     - parameter countCompletionHandler: The block to execute with the count results.
     */
    public func performQuery(query query: CKQuery, inZoneWithID zoneID: CKRecordZoneID?, countCompletionHandler: (Int, NSError?) -> Void) {
        
        performQuery(query: query, cursor: nil, inZoneWithID: zoneID, desiredKeys: [], currentCount: 0, batchCompletionHandler: nil, countCompletionHandler: { (count, _, error) in
            
            dispatch_async(dispatch_get_main_queue(), {
                countCompletionHandler(count ?? 0, error)
            })
        })
    }
    
    public func performQuery(query query: CKQuery, inZoneWithID zoneID: CKRecordZoneID?, desiredKeys: [String]? = nil, batchCompletionHandler: (([CKRecord]?, NSError?) -> Void)?, compiledCompletionHandler: (([CKRecord]?, NSError?) -> Void)?) {
        
        performQuery(query: query, cursor: nil, inZoneWithID: zoneID, desiredKeys: desiredKeys, currentRecords: [], batchCompletionHandler: batchCompletionHandler) { (records, _, error) in
            
            dispatch_async(dispatch_get_main_queue(), {
                compiledCompletionHandler?(records, error)
            })
        }
    }
    
    private func performQuery(query query: CKQuery?, cursor: CKQueryCursor?, inZoneWithID zoneID: CKRecordZoneID?, desiredKeys: [String]? = nil, currentCount: Int? = nil, currentRecords: [CKRecord]? = nil, batchCompletionHandler: (([CKRecord]?, NSError?) -> Void)?, countCompletionHandler: ((Int?, CKQueryCursor?, NSError?) -> Void)? = nil, compiledCompletionHandler: (([CKRecord]?, CKQueryCursor?, NSError?) -> Void)? = nil) {
        
        var count = currentCount
        var records: [CKRecord]?
        if currentRecords != nil {
            records = [CKRecord]()
        }
        
        let queryOperation: CKQueryOperation?
        if let aQuery = query {
            queryOperation = CKQueryOperation(query: aQuery)
        } else if let aCursor = cursor {
            queryOperation = CKQueryOperation(cursor: aCursor)
        } else {
            queryOperation = nil
        }
        queryOperation?.queuePriority = .VeryHigh
        queryOperation?.qualityOfService = .UserInteractive
        queryOperation?.zoneID = zoneID
        queryOperation?.resultsLimit = CKQueryOperationMaximumResults
        queryOperation?.desiredKeys = desiredKeys
        queryOperation?.recordFetchedBlock = { (record: CKRecord) in
            
            count? += 1
            records?.append(record)
        }
        queryOperation?.queryCompletionBlock = { (cursor: CKQueryCursor?, error: NSError?) in
            
            if let curRecords = currentRecords, batchRecords = records {
                records = curRecords + batchRecords
                
                dispatch_async(dispatch_get_main_queue(), {
                    batchCompletionHandler?(batchRecords, error)
                })
            }
            
            if let aCursor = cursor {
                self.performQuery(query: nil, cursor: aCursor, inZoneWithID: zoneID, currentCount: count, currentRecords: records, desiredKeys: desiredKeys, batchCompletionHandler: batchCompletionHandler, countCompletionHandler: countCompletionHandler, compiledCompletionHandler: compiledCompletionHandler)
            } else {
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    countCompletionHandler?(count, cursor, error)
                    compiledCompletionHandler?(records, cursor, error)
                })
            }
        }
        
        if let operation = queryOperation {
            addOperation(operation)
        } else {
            NSLog("Not able to create query operation")
        }
    }
    
    public func saveRecord(record: CKRecord, progressHandler: ((Double) -> Void)?, completionHandler: (CKRecord?, NSError?) -> Void) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.qualityOfService = .UserInitiated
        operation.perRecordProgressBlock = { (_, progress) in
            
            dispatch_async(dispatch_get_main_queue(), {
                progressHandler?(progress)
            })
        }
        operation.perRecordCompletionBlock = { (record, error) in
            
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(record, error)
            })
        }
        addOperation(operation)
    }
    
}
