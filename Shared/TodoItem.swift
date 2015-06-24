//
//  TodoItem.swift
//  TodoApp
//
//  Created by Andrew Grant on 6/23/15.
//  Copyright (c) 2015 Code Before Dawn, Inc. All rights reserved.
//

import Foundation


class TodoItem : Hashable {
    
    var uuid : String
    var completed = false
    var creationDate : NSDate?
    var title : String
    var priority : Int = 0
    
    var list : TodoList? {
        didSet {
            if oldValue != nil && oldValue != self.list {
                
                if let index = find(oldValue!.items, self) {
                    oldValue!.items.removeAtIndex(index)
                }
            }
            
            self.list?.items.append(self)
        }
    }
    
    var hashValue : Int {
        return uuid.hashValue
    }
    
    init (store : TodoStore) {
        uuid = NSUUID().UUIDString
        title = "New Item"
    }
}

func ==(lhs : TodoItem, rhs : TodoItem) -> Bool {
    return lhs.hashValue == rhs.hashValue
}