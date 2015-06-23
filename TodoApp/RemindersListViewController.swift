//
//  RemindersListViewController.swift
//  EditReminders
//
//  Created by Andrew Grant on 5/26/15.
//  Copyright (c) Andrew Grant. All rights reserved.
//

import UIKit
import EventKit

class RemindersListViewController : UITableViewController, UITextFieldDelegate
{
    // MARK: Properties
    
    var calendar : EKCalendar?
    var reminders = [EKReminder]()
    
    @IBOutlet var editBarButton : UIBarButtonItem!
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editBarButton
        self.title = calendar?.title
        
        let rc = UIRefreshControl()
        refreshControl?.addTarget(self, action: Selector("onRefresh:"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        onRefresh(nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let controller = segue.destinationViewController as? EditReminderViewController {
            
            // Segue may be triggered either by selecting a tableview or pressing enter in
            // the text field
            if let tvc = sender as? UITableViewCell {
                let indexPath = self.tableView.indexPathForCell(tvc)!
                controller.reminder = self.reminders[indexPath.row]
            }
            else if let tf = sender as? UITextField {
                controller.defaultReminderName = tf.text
            }
            
            controller.owningCalendar = self.calendar
        }
    }

    // MARK: Actions
    
    @IBAction func onEdit(sender : UIBarButtonItem?)
    {
        self.tableView.editing = !self.tableView.editing
        self.editBarButton.title = self.tableView.editing ? "Done" : "Edit"
    }
    
    
    @IBAction func onCompleteButton(sender : UIButton)
    {
        let reminder = self.reminders[sender.tag]
        
        reminder.completed = !reminder.completed
        sender.setTitle(reminder.completed ? "🔳" : "◻️", forState: UIControlState.Normal)
        
        EventHelper.sharedInstance.eventStore.saveReminder(reminder, commit: true, error: nil)
    }
    
    
    func onRefresh(sender : AnyObject?)
    {
        let lists = [EKCalendar](arrayLiteral: calendar!)
        
        let pred = EventHelper.sharedInstance.eventStore.predicateForRemindersInCalendars(lists)
        
        EventHelper.sharedInstance.eventStore.fetchRemindersMatchingPredicate(pred, completion: { (objects : [AnyObject]!) -> Void in
            
            if let rem = objects as? [EKReminder] {
                
                self.reminders = rem
            }
            
            self.reminders.sort({ (lhs, rhs) -> Bool in
                
                if lhs.creationDate == nil || rhs.creationDate == nil {
                    return false
                }
                
                return lhs.creationDate?.compare(rhs.creationDate) == NSComparisonResult.OrderedAscending
            })
                        
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            })

        })
    }
    
    // MARK: - Textfield Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if count(textField.text) > 0 {
            self.performSegueWithIdentifier("AddReminder", sender: textField)
        }
        return true
    }
    
    // MARK: - Tableview delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reminders.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell
        
        if (indexPath.row < self.reminders.count)
        {
            let reminderCell = tableView.dequeueReusableCellWithIdentifier("ReminderCell") as! ReminderTableViewCell
            
            let reminder = self.reminders[indexPath.row]
            
            reminderCell.titleLabel.text = reminder.title
            reminderCell.completeButton.setTitle(reminder.completed ? "🔳" : "◻️", forState: UIControlState.Normal)
            reminderCell.completeButton.tag = indexPath.row
            
            cell = reminderCell
        }
        else
        {
            cell = tableView.dequeueReusableCellWithIdentifier("CreateCell")! as! UITableViewCell
            if let textField = cell.contentView.subviews.first as? UITextField {
                textField.text = nil
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete && indexPath.row < self.reminders.count {
            let rem = self.reminders[indexPath.row]
            
            var error : NSError?
            EventHelper.sharedInstance.eventStore.removeReminder(rem, commit: true, error: &error)
            
            if error != nil {
                let msg = UIAlertController(title: nil, message: "Error Deleting Reminder: " + error!.description, preferredStyle: UIAlertControllerStyle.Alert)
                self.presentViewController(msg, animated: true, completion: nil)
            }
            else
            {
                onRefresh(nil)
            }
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row < self.reminders.count
    }
}
