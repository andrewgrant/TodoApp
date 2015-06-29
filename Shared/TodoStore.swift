//
//  EventHelper.swift
//  EditReminders
//
//  Created by Andrew Grant on 5/26/15.
//  Copyright (c) Andrew Grant. All rights reserved.
//

import Foundation


class TodoStore {
    
    static let sharedInstance = TodoStore()
    
    var lists = [TodoList]()
    
    
    init () {
        loadDocument()
    }
    
    
    func removeList(list : TodoList, error : NSErrorPointer) {
        
    }
    
    func saveList(list : TodoList, error : NSErrorPointer) {
        
    }
    
    func saveItem(item : TodoItem, error : NSErrorPointer) {
        
    }
    
    func removeItem(item: TodoItem, error : NSErrorPointer) {
        
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
                lists = newLists
            }
            else {
                lists = [TodoList]()
            }
        }
    }
    
    func saveDocument() {
        
        let path = documentLocation().URLByAppendingPathComponent("Todo.dat")
        
        let data = NSMutableData()
        let archive = NSKeyedArchiver(forWritingWithMutableData: data)

        archive.encodeObject(lists, forKey: "lists")
        
        archive.finishEncoding()
        
        data.writeToURL(path, atomically: true)        
    }
    
}

