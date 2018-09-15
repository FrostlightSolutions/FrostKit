//
//  CKReferenceExntensions.swift
//  FrostKit
//
//  Created by James Barrow on 27/08/16.
//  Copyright © 2016 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation
import CloudKit

@available(watchOSApplicationExtension 3.0, *)
public extension CKRecord.Reference {
    
    public class func references(fromRecordIDs recordIDs: [CKRecord.ID], action: CKRecord.Reference.Action = .none) -> [CKRecord.Reference] {
        return recordIDs.map({ (recordID) -> CKRecord.Reference in
            return CKRecord.Reference(recordID: recordID, action: action)
        })
    }
    
    public class func references(fromRecordNames names: [String], zoneID: CKRecordZone.ID? = nil, action: CKRecord.Reference.Action = .none) -> [CKRecord.Reference] {
        return names.map({ (name) -> CKRecord.Reference in
            let recordID: CKRecord.ID
            if let recordZoneID = zoneID {
                recordID = CKRecord.ID(recordName: name, zoneID: recordZoneID)
            } else {
                recordID = CKRecord.ID(recordName: name)
            }
            return CKRecord.Reference(recordID: recordID, action: action)
        })
    }
}
