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
public extension CKReference {
    
    public class func references(fromRecordIDs recordIDs: [CKRecordID], action: CKReferenceAction = .none) -> [CKReference] {
        return recordIDs.map({ (recordID) -> CKReference in
            return CKReference(recordID: recordID, action: action)
        })
    }
    
    public class func references(fromRecordNames names: [String], zoneID: CKRecordZoneID? = nil, action: CKReferenceAction = .none) -> [CKReference] {
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
