//
//  Protocols.swift
//  TodoApp
//
//  Created by Andrew Grant on 7/19/15.
//  Copyright (c) 2015 Code Before Dawn, Inc. All rights reserved.
//

import Foundation
import CloudKit


// Defines a cloud interface for objects
protocol CloudStorage {
    
    func checkForChanges(type: String, sinceDate: NSDate?, completion : ((NSError?) -> Void)?)
    func saveObject(obj : TodoItem, completion:((NSError!) -> Void)?)
    func deleteObject(obj : TodoItem, completion:((NSError!) -> Void)?)
    
    func notifyObjectUpdated(recordID: CKRecordID)
}

protocol RemoteRecord : class {
    subscript(key: String) -> CKRecordValue? { get set }
    
    func setObject(object: CKRecordValue!, forKey: String)
    
    func objectForKey(key: String!) -> CKRecordValue?

}

// Defines a local backing store for objects
protocol LocalStorage {
    
    func objectsWereUpdated(objs : [String])
    func objectsWereRemoved(objs : [String])
    
    func saveObject(obj : TodoItem, error : NSErrorPointer)
    
    func decodeObject(type: String, record: RemoteRecord) -> SyncableItem?
    
}