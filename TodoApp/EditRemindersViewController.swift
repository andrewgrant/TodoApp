//
//  EditRemindersViewController.swift
//  EditReminders
//
//  Created by Andrew Grant on 5/28/15.
//  Copyright (c) Andrew Grant. All rights reserved.
//


import UIKit
import EventKit

class EditReminderViewController : UITableViewController
{
    // MARK: - Properties
    @IBOutlet var eventNameTextField : UITextField!
    @IBOutlet var listTableViewCell : UITableViewCell!
    @IBOutlet var prioritySegments : UISegmentedControl!
    @IBOutlet var cancelButton : UIBarButtonItem!
    @IBOutlet var saveButton : UIBarButtonItem!
    
    var reminder : EKReminder!
    var owningCalendar : EKCalendar?
    var defaultReminderName  = "New Reminder"
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        
        if reminder == nil {
            // If no reminder provided create a new one and set buttons to save/cancel
            reminder = EKReminder(eventStore: EventHelper.sharedInstance.eventStore)
            reminder.calendar = owningCalendar
            reminder.title = self.defaultReminderName
            self.navigationItem.rightBarButtonItem = self.saveButton
            self.navigationItem.leftBarButtonItem = self.cancelButton
        }        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.eventNameTextField?.text = self.reminder?.title
        self.listTableViewCell.detailTextLabel!.text = self.reminder?.calendar.title
        
        if self.reminder.priority <= 4 {
            self.prioritySegments.selectedSegmentIndex = self.reminder.priority
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        if let reminder = self.reminder {
            
            if count(self.eventNameTextField.text) > 0 {
                reminder.title = eventNameTextField.text
            }
            
            reminder.priority = prioritySegments.selectedSegmentIndex

            var error : NSError?
            
            EventHelper.sharedInstance.eventStore.saveReminder(reminder, commit: true, error: &error)
            
            if error != nil {
                let msg = UIAlertController(title: nil, message: "Error Saving Reminder: " + error!.description, preferredStyle: UIAlertControllerStyle.Alert)
                self.presentViewController(msg, animated: true, completion: nil)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "SelectList" {
            if let cvc = segue.destinationViewController as? ChangeListViewController {
                cvc.reminder = self.reminder
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
        self.reminder = nil
        self.navigationController?.popViewControllerAnimated(true)
    }    
}
