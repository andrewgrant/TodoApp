//
//  TodoEntry.swift
//  TodoApp
//
//  Created by Andrew Grant on 6/23/15.
//  Copyright (c) 2015 Andrew Grant. All rights reserved.
//

import Foundation

class TodoEntry : TodoItem {

    var title : String!
    var parentUuid : String?
    var completed = false
    var priority : Int = 0
    
    init (title : String) {
        self.title = title
        super.init()
    }
   
    required init(record: RemoteRecord) {
        
        super.init(record: record)
    }
    
    override func decodeSelf(record : RemoteRecord) {
        self.title = record["title"] as! String
        self.parentUuid = record["parentUuid"] as? String
        self.completed = record["completed"] as! Bool
        self.priority = record["priority"] as! Int
    }
    
    override func encodeSelf(record : RemoteRecord) {
        
        super.encodeSelf(record)
        
        record["title"] = self.title
        record["parentUuid"] = self.parentUuid
        record["completed"] = self.completed
        record["priority"] = self.priority
    }
}
