//
//  CKReferenceExntensions.swift
//  FrostKit
//
//  Created by James Barrow on 27/08/16.
//  Copyright © 2016 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation
import CloudKit

public extension CKReference {
    
    public class func referencesFromRecordIDs(recordIDs: [CKRecordID], action: CKReferenceAction = .None) -> [CKReference] {
        return recordIDs.map({ (recordID) -> CKReference in
            return CKReference(recordID: recordID, action: action)
        })
    }
    
    public class func referencesFromRecordNames(names: [String], zoneID: CKRecordZoneID? = nil, action: CKReferenceAction = .None) -> [CKReference] {
        return names.map({ (name) -> CKReference in
            let recordID: CKRecordID
            if let recordZoneID = zoneID {
                recordID = CKRecordID(recordName: name, zoneID: recordZoneID)
            } else {
                recordID = CKRecordID(recordName: name)
            }
            return CKReference(recordID: recordID, action: action)
        })
    }
    
}
