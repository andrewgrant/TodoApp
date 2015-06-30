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


class TodoList : NSObject, NSCoding, Hashable {
    
    var uuid : String?
    var title : String
    var CGColor : CGColorRef
    var immutable = false
    
    override var hashValue : Int {
        return uuid!.hashValue
    }
    
    init (title : String) {
        self.title = title
        
        var floats : [CGFloat] = [0,0,0,1]
        self.CGColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), floats)
        
        super.init()
    }
    
    deinit {
        //CFRelease(CGColor)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.uuid = aDecoder.decodeObjectForKey("uuid") as? String
        self.title = aDecoder.decodeObjectForKey("title") as! String
        
        let colorArray = aDecoder.decodeObjectForKey("CGColor") as! [CGFloat]
        self.CGColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), colorArray)
        self.immutable = aDecoder.decodeBoolForKey("immutable")
                
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        let colors = CGColorGetComponents(CGColor)
        let colorBuffer = UnsafeBufferPointer(start: colors, count: 4)
        let colorArray = [CGFloat](colorBuffer)
        
        aCoder.encodeObject(uuid, forKey: "uuid")
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(colorArray, forKey: "CGColor")
        aCoder.encodeBool(immutable, forKey: "immutable")
    }    
}

func ==(lhs : TodoList, rhs : TodoList) -> Bool {
    return lhs.hashValue == rhs.hashValue
}