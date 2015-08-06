//
//  Logging.swift
//  TodoApp
//
//  Created by Andrew Grant on 7/16/15.
//  Copyright (c) 2015 Code Before Dawn, Inc. All rights reserved.
//

import Foundation


class Channel {
    
    let name : String
    let logger : Logger
    
    init(logger: Logger, name: String) {
        self.logger = logger
        self.name = name
    }
    
    func info(format: String, _ args: CVarArgType...)
    {
        print("Info", format: format, args: args)
    }
    
    func warn(format: String, _ args: CVarArgType...)
    {
        print("Warn", format: format, args: args)
    }
    
    func error(format: String, _ args: CVarArgType...)
    {
        print("Error", format: format, args: args)
    }
    
    func print(level: String, format: String, args: [CVarArgType]) {
        
        let prefix = String(format: "[%@]%@: ", name, level)
        
        let str = prefix + String(format: format, arguments: args)
        
        objc_sync_enter(self.logger)
        println(str)
        objc_sync_exit(self.logger)
    }
}


class Logger {
    
    static let lock = "Lock"
    static let instance = Logger()
    
    var showTimestamp = true
}

extension Logger {
    static let app = Channel(logger:instance, name:"App")
    static let cloudKit = Channel(logger:instance, name:"Cloudkit")
    static let localStore = Channel(logger:instance, name:"LocalStore")
}