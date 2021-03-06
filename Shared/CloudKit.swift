//
//  CloudKit.swift
//  TodoApp
//
//  Created by Andrew Grant on 6/30/15.
//  Copyright (c) 2015 Code Before Dawn, Inc. All rights reserved.
//

import Foundation
import CloudKit

extension CKRecord {
    class Sub {
        let record: CKRecord
        
        init(record : CKRecord) {
            self.record = record
        }
        
        subscript(key: String) -> CKRecordValue? {
            get {
                return record.objectForKey(key)
            }
            set {
                record.setObject(newValue, forKey: key)
            }
        }
    }
    
    var sub : Sub {
        return Sub(record: self)
    }
}


class CloudKitRecord : RemoteRecord {
    
    var record: CKRecord
    
    init(record: CKRecord) {
        self.record = record
    }
    
    subscript(key: String) -> CKRecordValue? {
        get {
            return record.objectForKey(key)
        }
        set {
            record.setObject(newValue, forKey: key)
        }
    }
    
    func setObject(object: CKRecordValue!, forKey: String) {
        record.setObject(object, forKey: forKey)
    }
    
    func objectForKey(key: String!) -> CKRecordValue? {
        return record.objectForKey(key)
    }
}



class CloudKit : CloudStorage{
    
    static let sharedInstance = CloudKit()
    
    var publicDB : CKDatabase
    var privateDB : CKDatabase
    var defaultDatabase : CKDatabase
    var localStore : LocalStorage!
    
    var _processedUpdatedObjs = [String]()
    var _processedRemovedObjs = [String]()
    
    init() {
        publicDB = CKContainer.defaultContainer().publicCloudDatabase
        privateDB = CKContainer.defaultContainer().privateCloudDatabase
        
        defaultDatabase = publicDB
        
        // todo - test iCloud access
        //checkForNewStuff()
        
        let pred = NSPredicate(format: "type = %@", "TodoEntry")
        
        
        // TODO - save subscription types!
        
        let subscription = CKSubscription(recordType: "TodoEntry", predicate: pred, options: [.FiresOnRecordUpdate, .FiresOnRecordCreation, .FiresOnRecordDeletion])
        
        let notification = CKNotificationInfo()
        notification.shouldBadge = true
        
        self.defaultDatabase.saveSubscription(subscription, completionHandler: { (sub, error) -> Void in
            if error != nil {
                Logger.cloudKit.warn("Failed to save subscription: %@", error!.localizedDescription)
            }
        })
    }

    func beginProcessingChanges() {
        
        objc_sync_enter(self)
        
        _processedUpdatedObjs.removeAll()
        _processedRemovedObjs.removeAll()
    }
    
    func endProcessingChanges() {
        
        if _processedUpdatedObjs.count > 0 {
            self.localStore.objectsWereUpdated(_processedUpdatedObjs)
        }
        
        if _processedRemovedObjs.count > 0 {
            self.localStore.objectsWereRemoved(_processedRemovedObjs)
        }
        
        _processedUpdatedObjs.removeAll()
        _processedRemovedObjs.removeAll()
        
        objc_sync_exit(self)

    }
    
    func processChangedObject(type: String, record: CKRecord) {
        
        let cloudRecord = CloudKitRecord(record: record)
        
        let uuid = cloudRecord["uuid"] as! String
        
        let deleted = cloudRecord["deleted"] as? Bool
        
        if deleted != nil && deleted! == true
        {
            _processedRemovedObjs.append(uuid)
            Logger.cloudKit.info("Received deleted iCloud record \(type):\(uuid)")
        }
        else
        {
        
            Logger.cloudKit.info("Received changed iCloud record \(type):\(uuid)")

            if let obj = self.localStore.decodeObject(type, record: cloudRecord) {
                obj.record = record
                
                _processedUpdatedObjs.append(uuid)
            }
        }
    }
    
    func checkForChanges(type: String, sinceDate: NSDate?, completion : ((NSError?) -> Void)?) {
        
        let searchDate = sinceDate ?? NSDate.distantPast() 
        
        let pred = NSPredicate(format:"modificationDate > %@", searchDate)
        
        //let pred = NSPredicate(value: true)
        
        let query = CKQuery(recordType: type, predicate: pred)
        
        defaultDatabase.performQuery(query, inZoneWithID: nil) { (objects, error) -> Void in
            if error != nil {
                Logger.cloudKit.info(error!.localizedDescription)
            }
            else
            {
                if let records = objects {
                    
                    self.beginProcessingChanges()
                    for list in records {
                        self.processChangedObject(type, record: list)
                    }
                    self.endProcessingChanges()
                }
            }
            
            completion?(error)
        }
    }
    
    func notifyObjectUpdated(recordID: CKRecordID) {
        
        let records = [CKRecordID](arrayLiteral: recordID)
        
        let query = CKFetchRecordsOperation(recordIDs: records)
        
        Logger.cloudKit.info("Received object update notification. Fetching records...")
        
        query.fetchRecordsCompletionBlock = { recordsByID, error in
            
            Logger.cloudKit.info("Found %d matching object", recordsByID!.count)
            
            self.beginProcessingChanges()
            
            for (_, record) in recordsByID! {
        
                if let type = record["type"] as? String {
                    self.processChangedObject(type, record: record)
                }
            }
            
            self.endProcessingChanges()
            
        }
        
        self.defaultDatabase.addOperation(query)        
    }
    
    func saveObject(obj : TodoItem, completion:((NSError!) -> Void)?) {
        
        //let values = obj.encodeSelf()
        
        //var record : CKRecord!
        
        if obj.record == nil {
            let recordID = CKRecordID(recordName: obj.uuid)
            obj.record = CKRecord(recordType: obj.typeName(), recordID: recordID)
        }
        
        let cloudRecord = CloudKitRecord(record: obj.record!)
        
        obj.encodeSelf(cloudRecord)
        
        if let record = obj.record {
            
            /*for k in values.keys {
                record.sub[k] = values[k] as? CKRecordValue
            }*/
            
            self.defaultDatabase.saveRecord(record, completionHandler: { (newRecord, error) -> Void in
                
                if error != nil {
                    Logger.cloudKit.warn("Error when saving object %@: %@", obj.uuid, error!.localizedDescription)
                }
                else {
                    Logger.cloudKit.info("Saved record %@", obj.uuid)

                    obj.record = newRecord
                }
                
                completion?(error)
            })
        }
    }
    
    func deleteObject(obj : TodoItem, completion:((NSError!) -> Void)?) {
        
        if let record = obj.record {
            
            // we don't truly delete objects, just mark them as such.
            record.sub["deleted"] = true
            
            self.defaultDatabase.saveRecord(record) { record, error in
                
                if error != nil {
                    Logger.cloudKit.warn("Error when marking object %@ as deleted: %@", obj.uuid, error!.localizedDescription)
                }
                else {
                    Logger.cloudKit.info("Marked as deleted %@", obj.uuid)
                }
                
                completion?(error)
            }
        }
    }
}