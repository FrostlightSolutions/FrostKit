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
    public func perform(query: CKQuery, inZoneWithID zoneID: CKRecordZoneID?, countCompletionHandler: @escaping (Int, Error?) -> Void) {
        
        perform(query: query, cursor: nil, inZoneWithID: zoneID, desiredKeys: [], currentCount: 0, batchCompletionHandler: nil, countCompletionHandler: { (count, _, error) in
            countCompletionHandler(count ?? 0, error)
        })
    }
    
    public func perform(query: CKQuery, inZoneWithID zoneID: CKRecordZoneID?, desiredKeys: [String]? = nil, batchCompletionHandler: (([CKRecord]?, Error?) -> Void)?, compiledCompletionHandler: (([CKRecord]?, Error?) -> Void)?) {
        
        perform(query: query, cursor: nil, inZoneWithID: zoneID, desiredKeys: desiredKeys, currentRecords: [], batchCompletionHandler: batchCompletionHandler) { (records, _, error) in
            compiledCompletionHandler?(records, error)
        }
    }
    
    private func perform(query: CKQuery?, cursor: CKQueryCursor?, inZoneWithID zoneID: CKRecordZoneID?, desiredKeys: [String]? = nil, currentCount: Int? = nil, currentRecords: [CKRecord]? = nil, batchCompletionHandler: (([CKRecord]?, Error?) -> Void)?, countCompletionHandler: ((Int?, CKQueryCursor?, Error?) -> Void)? = nil, compiledCompletionHandler: (([CKRecord]?, CKQueryCursor?, Error?) -> Void)? = nil) {
        
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
        queryOperation?.queuePriority = .veryHigh
        queryOperation?.qualityOfService = .userInteractive
        queryOperation?.zoneID = zoneID
        queryOperation?.resultsLimit = CKQueryOperationMaximumResults
        queryOperation?.desiredKeys = desiredKeys
        queryOperation?.recordFetchedBlock = { (record: CKRecord) in
            
            count? += 1
            records?.append(record)
        }
        queryOperation?.queryCompletionBlock = { (cursor: CKQueryCursor?, error: Error?) in
            
            if let curRecords = currentRecords, let batchRecords = records {
                records = curRecords + batchRecords
                batchCompletionHandler?(batchRecords, error)
            }
            
            if let aCursor = cursor {
                self.perform(query: nil, cursor: aCursor, inZoneWithID: zoneID, desiredKeys: desiredKeys, currentCount: count, currentRecords: records, batchCompletionHandler: batchCompletionHandler, countCompletionHandler: countCompletionHandler, compiledCompletionHandler: compiledCompletionHandler)
            } else {
                countCompletionHandler?(count, cursor, error)
                compiledCompletionHandler?(records, cursor, error)
            }
        }
        
        if let operation = queryOperation {
            add(operation)
        } else {
            NSLog("Not able to create query operation")
        }
    }
    
    public func fetchRecords(withRecordIDs recordIDs: [CKRecordID], desiredKeys: [String]? = nil, perRecordHandler: ((CKRecord?, CKRecordID?, Error?) -> Void)? = nil, completetionHandler: (([CKRecordID: CKRecord]?, Error?) -> Void)? = nil) {
        
        let operation = CKFetchRecordsOperation(recordIDs: recordIDs)
        operation.queuePriority = .veryHigh
        operation.qualityOfService = .userInteractive
        operation.desiredKeys = desiredKeys
        operation.perRecordCompletionBlock = perRecordHandler
        operation.fetchRecordsCompletionBlock = completetionHandler
        
        add(operation)
    }
    
    public func save(record: CKRecord, progressHandler: ((Double) -> Void)?, completionHandler: @escaping (CKRecord?, Error?) -> Void) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.qualityOfService = .userInitiated
        operation.perRecordProgressBlock = { (_, progress) in
            
            DispatchQueue.main.async {
                progressHandler?(progress)
            }
        }
        operation.perRecordCompletionBlock = { (record, error) in
            
            DispatchQueue.main.async {
                completionHandler(record, error)
            }
        }
        add(operation)
    }
    
}
