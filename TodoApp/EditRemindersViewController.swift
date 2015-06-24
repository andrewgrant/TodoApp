//
//  EditRemindersViewController.swift
//  EditReminders
//
//  Created by Andrew Grant on 5/28/15.
//  Copyright (c) Andrew Grant. All rights reserved.
//


import UIKit

class EditReminderViewController : UITableViewController
{
    // MARK: - Properties
    @IBOutlet var eventNameTextField : UITextField!
    @IBOutlet var listTableViewCell : UITableViewCell!
    @IBOutlet var prioritySegments : UISegmentedControl!
    @IBOutlet var cancelButton : UIBarButtonItem!
    @IBOutlet var saveButton : UIBarButtonItem!
    
    var item : TodoItem!
    var owningList : TodoList?
    var defaultReminderName  = "New Reminder"
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        
        if item == nil {
            // If no reminder provided create a new one and set buttons to save/cancel
            item = TodoItem(store: TodoStore.sharedInstance)
            item.list = owningList
            item.title = self.defaultReminderName
            self.navigationItem.rightBarButtonItem = self.saveButton
            self.navigationItem.leftBarButtonItem = self.cancelButton
        }        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.eventNameTextField?.text = self.item?.title
        self.listTableViewCell.detailTextLabel!.text = self.item?.list?.title
        
        if self.item.priority <= 4 {
            self.prioritySegments.selectedSegmentIndex = self.item.priority
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        if let item = self.item {
            
            if count(self.eventNameTextField.text) > 0 {
                item.title = eventNameTextField.text
            }
            
            item.priority = prioritySegments.selectedSegmentIndex

            var error : NSError?
            
            TodoStore.sharedInstance.saveItem(item, error: &error)
            
            if error != nil {
                let msg = UIAlertController(title: nil, message: "Error Saving Reminder: " + error!.description, preferredStyle: UIAlertControllerStyle.Alert)
                self.presentViewController(msg, animated: true, completion: nil)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "SelectList" {
            if let cvc = segue.destinationViewController as? ChangeListViewController {
                cvc.item = self.item
                cvc.title = "Select List"
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func onSave(sender : UIBarButtonItem?) {
        if count(self.eventNameTextField.text) == 0 {
            self.eventNameTextField.text = self.defaultReminderName
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onCancel(sender : UIBarButtonItem?) {
        // set to nil so nothing is saved
        self.item = nil
        self.navigationController?.popViewControllerAnimated(true)
    }    
}
