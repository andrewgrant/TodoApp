//
//  RemindersListViewController.swift
//  EditReminders
//
//  Created by Andrew Grant on 5/26/15.
//  Copyright (c) Andrew Grant. All rights reserved.
//

import UIKit

class RemindersListViewController : UITableViewController, UITextFieldDelegate
{
    // MARK: Properties
    
    var list : TodoList?
    var items = [TodoEntry]()
    
    @IBOutlet var editBarButton : UIBarButtonItem!
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editBarButton
        self.title = list?.title
        
        let rc = UIRefreshControl()
        rc.addTarget(self, action: Selector("onRefresh:"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = rc
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
                controller.item = self.items[indexPath.row]
            }
            else if let tf = sender as? UITextField {
                controller.defaultReminderName = tf.text!
            }
            
            controller.owningList = self.list
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
        let item = self.items[sender.tag]
        
        item.completed = !item.completed
        sender.setTitle(item.completed ? "🔳" : "◻️", forState: UIControlState.Normal)
        
        TodoStore.sharedInstance.saveObject(item, error: nil)
    }
    
    
    func onRefresh(sender : AnyObject?)
    {
        if let list = self.list {
        
            if let newItems = TodoStore.sharedInstance.itemsInList(list) {
                self.items = newItems.sort({ (lhs, rhs) -> Bool in
                    return lhs.title.compare(rhs.title) == NSComparisonResult.OrderedAscending
                })
            }
        }
        
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - Textfield Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField.text?.characters.count > 0 {
            self.performSegueWithIdentifier("AddReminder", sender: textField)
        }
        return true
    }
    
    // MARK: - Tableview delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell
        
        if (indexPath.row < self.items.count)
        {
            let reminderCell = tableView.dequeueReusableCellWithIdentifier("ReminderCell") as! ReminderTableViewCell
            
            let reminder = self.items[indexPath.row]
            
            reminderCell.titleLabel.text = reminder.title
            reminderCell.completeButton.setTitle(reminder.completed ? "🔳" : "◻️", forState: UIControlState.Normal)
            reminderCell.completeButton.tag = indexPath.row
            
            cell = reminderCell
        }
        else
        {
            cell = tableView.dequeueReusableCellWithIdentifier("CreateCell")! 
            if let textField = cell.contentView.subviews.first as? UITextField {
                textField.text = nil
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete && indexPath.row < self.items.count {
            let rem = self.items[indexPath.row]
            
            var error : NSError?
            TodoStore.sharedInstance.removeObject(rem, error: &error)
            
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
        return indexPath.row < self.items.count
    }
}
