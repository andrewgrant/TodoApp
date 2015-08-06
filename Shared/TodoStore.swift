//
//  EventHelper.swift
//  EditReminders
//
//  Created by Andrew Grant on 5/26/15.
//  Copyright (c) Andrew Grant. All rights reserved.
//

import Foundation


class TodoStore : LocalStorage {
    
    
    static let TSObjectsUpdatedNotification = "TSObjectsUpdatedNotification"
    static let TSObjectsRemovedNotification = "TSObjectsRemovedNotification"
    
    static let sharedInstance = TodoStore()
    private var _itemCache = [String:TodoItem]()
    private var _dates = [String:NSDate]()

    var cloudStorage : CloudStorage?
    
    
    var lists : [TodoList] {
        return self.filteredLists({ (item) -> Bool in
            return true
        })
    }
    
    var itemCache : [String:TodoItem] {
        return _itemCache
    }
    
    init () {

    }
    
    func checkForUpdates(completion : ((Void) -> Void)?) {
        
        let types = ["TodoList", "TodoEntry"]
        
        for type in types {
            
            cloudStorage?.checkForChanges(type, sinceDate:_dates[type]) { error in
                self._dates[type] = NSDate()
            }
        }
        
        completion?()
        
    }
    
    func decodeObject(type: String, record: RemoteRecord) -> SyncableItem? {
    
        let uuid = record["uuid"] as! String
        
        var item = _itemCache[uuid]
        
        if item == nil {
            
            switch type {
                case "TodoList":
                    item = TodoList(title:"tmp")
                    break
                
                case "TodoEntry":
                    item = TodoEntry(title:"tmp")
                    break
                    
                default:
                    break
            }
            
            item!.uuid = uuid
            _itemCache[uuid] = item
        }
        
        item?.decodeSelf(record)
    
        return item
    }
    
    func objectsWereUpdated(objs : [String]) {
        // TODO - mark dirty in local store?
        
        let dict = ["uuids" : objs]
        NSNotificationCenter.defaultCenter().postNotificationName(TodoStore.TSObjectsUpdatedNotification, object: self, userInfo: dict)
    }
    
    func objectsWereRemoved(objs : [String]) {
        
        // remove from cache
        objs.map {
            self._itemCache[$0] = nil
        }
        
        let dict = ["uuids" : objs]
        NSNotificationCenter.defaultCenter().postNotificationName(TodoStore.TSObjectsRemovedNotification, object: self, userInfo: dict)
    }

    
    private func internalSaveObject(obj: TodoItem, error : NSErrorPointer) {
        
        // assign a UUID if it doesn't have one
        if obj.uuid == nil {
            obj.uuid = NSUUID().UUIDString
        }
        
        _itemCache[obj.uuid] = obj
        
        // start cloud save
        cloudStorage?.saveObject(obj, completion:nil)
    }

    
    func saveObject(obj: TodoItem, error : NSErrorPointer) {
        internalSaveObject(obj, error: error)
    }
    
    
    func saveObject(obj: TodoEntry, error : NSErrorPointer) {
        
        if let parentUuid = obj.parentUuid {
            internalSaveObject(obj, error: error)
        }
        else  {
            
            let userInfo = [NSLocalizedDescriptionKey : "Error: Parent item is nill or as not been saved"]
            let errorVal  = NSError(domain: "TodoAppDomain", code: -1, userInfo: userInfo)
            
            if error != nil {
                error.memory = errorVal
            }
            println(errorVal.description)
        }
    }

    func removeObject(item: TodoItem, error : NSErrorPointer) {
        
        if item is TodoList {
            let list = item as! TodoList
            
            for entry in self.itemsInList(list)! {
                removeObject(entry, error: nil)
            }
        }
        
        _itemCache.removeValueForKey(item.uuid)
        
        cloudStorage?.deleteObject(item, completion: nil)
    }
    
    
    func filteredLists( pred : (item : TodoList) -> Bool) -> [TodoList] {
        
        var lists = [TodoList]()
        
        for entry in _itemCache.values.array {
            if entry is TodoList {
                let list = entry as! TodoList
                if pred(item: list) {
                    lists.append(list)
                }
            }
        }
        
        return lists
    }
    
    func filteredItems( pred : (item : TodoEntry) -> Bool) -> [TodoEntry] {
        
        var items = [TodoEntry]()
        
        for entry in _itemCache.values.array {
            if entry is TodoEntry {
                let item = entry as! TodoEntry
                if pred(item: item) {
                    items.append(item)
                }
            }
        }
        
        return items
    }

    
    func itemsInList(list : TodoList) -> [TodoEntry]? {

        let allObjects = _itemCache.values.array
            
        let filtered = allObjects.filter() {
            if let entry = $0 as? TodoEntry {
                return entry.parentUuid == list.uuid
            }
            
            return false
        }
        
        return filtered as? [TodoEntry]
    }
    
    private func documentLocation() -> NSURL {
        
        let directories = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        
        return directories.first as! NSURL
    }
}

