//
//  EventHelper.swift
//  EditReminders
//
//  Created by Andrew Grant on 5/26/15.
//  Copyright (c) Andrew Grant. All rights reserved.
//

import Foundation
import EventKit


class EventHelper {
    
    static let sharedInstance = EventHelper()
    
    var eventStore = EKEventStore()
    var accessGranted = false
    var accessRequested = false
        
    func requestAccess(completion: (Bool, NSError!) -> Void) {
        eventStore.requestAccessToEntityType(EKEntityTypeReminder, completion: { (granted : Bool, error : NSError!) -> Void in
            self.accessGranted = granted
            self.accessRequested = false
            
            completion(granted, error)
        })
    }
}

