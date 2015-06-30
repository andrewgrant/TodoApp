//
//  EventHelper.swift
//  EditReminders
//
//  Created by Andrew Grant on 5/26/15.
//  Copyright (c) Andrew Grant. All rights reserved.
//

import Foundation


class TodoStore : NSObject {
    
    static let sharedInstance = TodoStore()
    
    private var _lists = [TodoList]()
    private var _items = [String:[TodoItem]]()
    
    var lists : [TodoList] {
        return _lists
    }
    
    var items : [String:[TodoItem]] {
        return _items
    }
    
    override init () {
        super.init()
    }
    
    
    func removeList(list : TodoList, error : NSErrorPointer) {
        
        // remove from our list of lists
        if let uuid = list.uuid {
            
            if let index = find(_lists, list) {
                _lists.removeAtIndex(index)
            }
            
            // remove items
            if _items[uuid] != nil {
                _items[uuid] = nil
            }
        }
    }
    
    func saveList(list : TodoList, error : NSErrorPointer) {
        
        // assign a UUID if it doesn't have one
        if list.uuid == nil {
            list.uuid = NSUUID().UUIDString
        }
        
        if contains(_lists, list) == false {
            _lists.append(list)
            _items[list.uuid!] = [TodoItem]()
        }
    }
    
    func saveItem(item : TodoItem, error : NSErrorPointer) {
        
        if let parentUuid = item.parentUuid {
            
            // If list has a UUID the map should have an array
            if item.uuid == nil {
                item.uuid = NSUUID().UUIDString
            }
            
            if contains(_items[parentUuid]!, item) == false {
                _items[parentUuid]!.append(item)
            }
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
    
    func removeItem(item: TodoItem, error : NSErrorPointer) {
        
        if let parentUuid = item.parentUuid {
            if let arr = _items[parentUuid] {
                if let index = find(arr, item) {
                    _items[parentUuid]!.removeAtIndex(index)
                }
            }
        }
    }
    
    func listFromUuid(uuid : String) -> TodoList? {
        for list in _lists {
            if list.uuid!.lowercaseString == uuid.lowercaseString {
                return list
            }
        }
        
        return nil
    }
    
    func itemsInList(list : TodoList) -> [TodoItem]? {
        if let uuid = list.uuid {
            return _items[uuid]
        }
        
        return nil
    }
    
    private func documentLocation() -> NSURL {
        
        let directories = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        
        return directories.first as! NSURL
    }
    
    func loadDocument() {
        let path = documentLocation().URLByAppendingPathComponent("Todo.dat")

        if let data = NSData(contentsOfURL: path) {
            
            let archive = NSKeyedUnarchiver(forReadingWithData: data)
            
            if let newLists = archive.decodeObjectForKey("lists") as? [TodoList] {
                _lists = newLists
            }
            else {
                _lists = [TodoList]()
            }
            
            if let newItems = archive.decodeObjectForKey("items") as? [String:[TodoItem]] {
                _items = newItems
            }
            else {
                _items = [String:[TodoItem]]()
            }
        }
        
        checkValidity(false)
    }
    
    func saveDocument() {
        
        let path = documentLocation().URLByAppendingPathComponent("Todo.dat")
        
        let data = NSMutableData()
        let archive = NSKeyedArchiver(forWritingWithMutableData: data)

        archive.encodeObject(_lists, forKey: "lists")
        archive.encodeObject(_items, forKey: "items")
        
        archive.finishEncoding()
        
        data.writeToURL(path, atomically: true)        
    }
    
    func checkValidity(andDie : Bool) {
        for list in _lists {
            if list.uuid == nil {
                assertionFailure("List has no assigned uuid")
            }
            else {
                if _items[list.uuid!] == nil {
                    assertionFailure(String(format: "List with UUID %@ has no entry in item hashmap!", list.uuid!))
                }
            }
        }
        
        for key in _items.keys {
            for item in _items[key]! {
                if item.uuid == nil {
                    assertionFailure("Item has no assigned uuid")
                }
            }
        }
    }
    
    func fixup() {
        
        for list in _lists {
            if list.uuid == nil {
                list.uuid = NSUUID().UUIDString
            }
            
            if _items[list.uuid!] == nil {
                _items[list.uuid!] = [TodoItem]()
            }
        }
    }
    
}

