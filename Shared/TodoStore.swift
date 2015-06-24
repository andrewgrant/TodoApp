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
    
    
    func removeList(list : TodoList, error : NSErrorPointer) {
        
    }
    
    func saveList(list : TodoList, error : NSErrorPointer) {
        
    }
    
    func saveItem(item : TodoItem, error : NSErrorPointer) {
        
    }
    
    func removeItem(item: TodoItem, error : NSErrorPointer) {
        
    }
    
}

