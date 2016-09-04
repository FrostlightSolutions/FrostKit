//
//  CKRecordIDExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 27/08/16.
//  Copyright © 2016 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation
import CloudKit

public extension CKRecordID {
    
    public class func recordIDsFromRecordNames(names: [String], zoneID: CKRecordZoneID? = nil, action: CKReferenceAction = .None) -> [CKRecordID] {
        return names.map({ (name) -> CKRecordID in
            let recordID: CKRecordID
            if let recordZoneID = zoneID {
                recordID = CKRecordID(recordName: name, zoneID: recordZoneID)
            } else {
                recordID = CKRecordID(recordName: name)
            }
            return recordID
        })
    }
    
}
