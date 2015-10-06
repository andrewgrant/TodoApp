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
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let rc = UIRefreshControl()
        rc.addTarget(self, action: Selector("onRefresh"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = rc
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("onObjectChange:"), name: TodoStore.TSObjectsUpdatedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("onObjectChange:"), name: TodoStore.TSObjectsRemovedNotification, object: nil)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        onRefresh()
    }
    
    // MARK: - Responders
    
    func onObjectChange(obj : AnyObject?) {
        postRefresh() // brute force
    }
    
    func postRefresh(){
        let objs = TodoStore.sharedInstance.lists
        
        self.sortedLists = objs.sort({ (lhs, rhs) -> Bool in
            lhs.title < rhs.title
        })
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        })

    }
    
    func onRefresh()
    {
        
        TodoStore.sharedInstance.checkForUpdates() {
            self.postRefresh()
        }
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ReminderList")
        
        let cal = sortedLists[indexPath.row]
        
        cell?.textLabel?.text = cal.title
        cell?.textLabel?.textColor = UIColor(CGColor: cal.CGColor)
        
        return cell!
    }
    
    
}
