//
//  TodoList.swift
//  TodoApp
//
//  Created by Andrew Grant on 6/23/15.
//  Copyright (c) 2015 Code Before Dawn, Inc. All rights reserved.
//

import Foundation
import CoreGraphics


class TodoList : Hashable {
    
    var uuid : String
    
    var title : String
    
    var CGColor : CGColorRef
    
    var hashValue : Int {
        return uuid.hashValue
    }
    
    var items = [TodoItem]()
    
    var immutable = false
    
    init (title : String, store : TodoStore) {
        uuid = NSUUID().UUIDString
        self.title = title
        
        var floats : [CGFloat] = [0,0,0,1]
        self.CGColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), floats)
        
        store.lists.append(self)
    }
    
    deinit {
        //CFRelease(CGColor)
    }

}

func ==(lhs : TodoList, rhs : TodoList) -> Bool {
    return lhs.hashValue == rhs.hashValue
}