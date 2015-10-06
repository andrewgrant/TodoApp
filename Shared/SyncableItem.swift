//
//  SyncedItem.swift
//  TodoApp
//
//  Created by Andrew Grant on 7/3/15.
//  Copyright (c) 2015 Code Before Dawn, Inc. All rights reserved.
//

import Foundation
import CloudKit

class SyncableItem : Hashable {
    
    var uuid : String!
    var record : CKRecord? // only for CloudKit
    
    init() {
        self.uuid = NSUUID().UUIDString
    }
    
    var hashValue : Int {
        return uuid!.hashValue
    }
    
    required init(record : RemoteRecord) {
        decodeSelf(record)
    }
    
    func typeName() -> String {
        let fullName = String(self).componentsSeparatedByString(".")
        return fullName[1]
    }
    
    func decodeSelf(record : RemoteRecord) {
        self.uuid = record["uuid"] as! String
        //self.recordID = record["cloudID"] as? CKRecordID    // note - "recordID" is reserved by Cloudkit!
    }
    
    func encodeSelf(record : RemoteRecord) {
                
        record["type"] = typeName()
        record["uuid"] = self.uuid
        //record["recordName"]  = self.recordID?.recordName
        //record["zoneID"] = self.recordID?.zoneID
        
    }
    
    func description() -> String {
        return String(format:"%@:%@", typeName(), self.uuid)
    }
}

func ==(lhs : SyncableItem, rhs : SyncableItem) -> Bool {
    return lhs.hashValue == rhs.hashValue
}