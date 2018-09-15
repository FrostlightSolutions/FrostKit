//
//  CKRecordIDExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 27/08/16.
//  Copyright © 2016 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation
import CloudKit

@available(watchOSApplicationExtension 3.0, *)
public extension CKRecord.ID {
    
    public class func recordIDs(fromRecordNames names: [String], zoneID: CKRecordZone.ID? = nil) -> [CKRecord.ID] {
        return names.map({ (name) -> CKRecord.ID in
            let recordID: CKRecord.ID
            if let recordZoneID = zoneID {
                recordID = CKRecord.ID(recordName: name, zoneID: recordZoneID)
            } else {
                recordID = CKRecord.ID(recordName: name)
            }
            return recordID
        })
    }
}
