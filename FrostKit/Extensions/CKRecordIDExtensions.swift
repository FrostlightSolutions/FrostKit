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
public extension CKRecordID {
    
    public class func recordIDs(fromRecordNames names: [String], zoneID: CKRecordZoneID? = nil, action: CKReferenceAction = .none) -> [CKRecordID] {
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
