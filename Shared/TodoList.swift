//
//  TodoList.swift
//  TodoApp
//
//  Created by Andrew Grant on 6/23/15.
//  Copyright (c) 2015 Andrew Grant. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit


class TodoList : TodoItem  {
    
    
    var title : String!
    var CGColor : CGColorRef!
    var immutable = false
        
    init (title : String) {
        self.title = title
        
        var floats : [CGFloat] = [0,0,0,1]
        self.CGColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), floats)
        
        super.init()
    }
    
    required init(record: RemoteRecord) {
        super.init(record: record)
    }
    
    override func decodeSelf(record: RemoteRecord) {
        self.title = record["title"] as! String
        
        if record["CGColor"] != nil {
            let colorArray = record["CGColor"] as! [CGFloat]
            self.CGColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), colorArray)
            self.immutable = record["immutable"] as! Bool
        }
    }
    
    override func encodeSelf(record: RemoteRecord) {
        
        super.encodeSelf(record)
        
        let colors = CGColorGetComponents(CGColor)
        let colorBuffer = UnsafeBufferPointer(start: colors, count: 4)
        let colorArray = [CGFloat](colorBuffer)

        record.setObject(self.title, forKey: "title")
        
        record["title"] = self.title
        record["immutable"] = self.immutable
        record["CGColor"] = colorArray
    }
}

