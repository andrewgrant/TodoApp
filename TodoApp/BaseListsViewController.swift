//
//  ListsViewController.swift
//  SimpleReminders
//
//  Created by Andrew Grant on 5/25/15.
//  Copyright (c) Andrew Grant. All rights reserved.
//

import UIKit
import EventKit

class BaseListsViewController : UITableViewController
{
    // MARK: - Properties
    var sortedLists : [EKCalendar] = [EKCalendar]()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let rc = UIRefreshControl()
        rc.addTarget(self, action: Selector("onRefresh"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = rc
                
        if EventHelper.sharedInstance.accessRequested == false {
            EventHelper.sharedInstance.requestAccess({ (granted : Bool, error : NSError!) -> Void in
                self.onRefresh()
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if EventHelper.sharedInstance.accessGranted {
            onRefresh()
        }
    }
    
    // MARK: - Responders
    
    func onRefresh()
    {
        var calendarEntries = [EKCalendar : [EKReminder]]()
        
        let objs = EventHelper.sharedInstance.eventStore.calendarsForEntityType(EKEntityTypeReminder)
        
        if let calendars = objs as? [EKCalendar] {
            
            self.sortedLists = calendars.sorted({ (lhs, rhs) -> Bool in
                lhs.title < rhs.title
            })
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        })
    }
    
    func listWasSelected(calendar : EKCalendar) {
        preconditionFailure("This function must be overriden!")
    }
    
    // MARK: - Tableview delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        listWasSelected(sortedLists[indexPath.row])
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedLists.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("ReminderList") as? UITableViewCell
        
        let cal = sortedLists[indexPath.row]
        
        cell?.textLabel?.text = cal.title
        cell?.textLabel?.textColor = UIColor(CGColor: cal.CGColor)
        
        return cell!
    }
    
    
}
