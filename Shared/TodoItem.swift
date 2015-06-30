//
//  TodoItem.swift
//  TodoApp
//
//  Created by Andrew Grant on 6/23/15.
//  Copyright (c) 2015 Andrew Grant. All rights reserved.
//

import Foundation


class TodoItem : NSObject, Hashable, NSCoding {
    
    var uuid : String?
    var creationDate : NSDate
    var title : String
    var parentUuid : String?
    var completed = false
    var priority : Int = 0
    
    override var hashValue : Int {
        return uuid!.hashValue
    }
    
    init (title : String) {
        self.title = title
        self.uuid = NSUUID().UUIDString
        self.creationDate = NSDate()
        super.init()

    }
    
    required init(coder aDecoder: NSCoder) {
        self.uuid = aDecoder.decodeObjectForKey("uuid") as? String
        self.creationDate = aDecoder.decodeObjectForKey("creationDate") as! NSDate
        self.title = aDecoder.decodeObjectForKey("title") as! String
        self.parentUuid = aDecoder.decodeObjectForKey("parentUuid") as? String
        self.completed = aDecoder.decodeBoolForKey("completed")
        self.priority = aDecoder.decodeIntegerForKey("priority")
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(uuid, forKey: "uuid")
        aCoder.encodeObject(creationDate, forKey: "creationDate")
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(parentUuid, forKey: "parentUuid")
        aCoder.encodeBool(completed, forKey: "completed")
        aCoder.encodeInteger(priority, forKey: "priority")
    }
    
}

func ==(lhs : TodoItem, rhs : TodoItem) -> Bool {
    return lhs.hashValue == rhs.hashValue
}