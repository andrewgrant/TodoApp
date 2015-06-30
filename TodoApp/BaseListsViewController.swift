//
//  ListsViewController.swift
//  SimpleReminders
//
//  Created by Andrew Grant on 5/25/15.
//  Copyright (c) Andrew Grant. All rights reserved.
//

import UIKit

class BaseListsViewController : UITableViewController
{
    // MARK: - Properties
    var sortedLists : [TodoList] = [TodoList]()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let rc = UIRefreshControl()
        rc.addTarget(self, action: Selector("onRefresh"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = rc
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        onRefresh()
    }
    
    // MARK: - Responders
    
    func onRefresh()
    {
        var calendarEntries = [TodoList : [TodoItem]]()
        
        let objs = TodoStore.sharedInstance.lists
        
        self.sortedLists = objs.sorted({ (lhs, rhs) -> Bool in
            lhs.title < rhs.title
        })
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        })
    }
    
    func listWasSelected(list : TodoList) {
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
