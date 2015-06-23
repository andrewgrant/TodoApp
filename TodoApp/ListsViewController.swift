//
//  MainListViewController.swift
//  EditReminders
//
//  Created by Andrew Grant on 5/26/15.
//  Copyright (c) Andrew Grant. All rights reserved.
//

import UIKit
import EventKit

class ListsViewController : BaseListsViewController {
    
    @IBOutlet var editBarButton : UIBarButtonItem!
    @IBOutlet var addBarButton : UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = editBarButton
        self.navigationItem.rightBarButtonItem = addBarButton
        
        self.title = "Lists"
    }
    
    
    override func listWasSelected(calendar: EKCalendar) {
        if (self.tableView.editing) {
            
            self.performSegueWithIdentifier("EditList", sender: calendar)
        }
        else {
            self.performSegueWithIdentifier("ViewList", sender: calendar)
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let calendar = self.sortedLists[indexPath.row]
        
        var error : NSError?
        EventHelper.sharedInstance.eventStore.removeCalendar(calendar, commit: true, error: &error)
        
        if error != nil {
            let text = error!.description
            let msg = UIAlertController(title: "Error", message: "Error Deleting Calendar:" + text, preferredStyle: UIAlertControllerStyle.Alert)
            self.presentViewController(msg, animated: true, completion: nil)
        }
        else {
            onRefresh()
        }
    }
    
    override func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject) -> Bool
    {
        let cal = self.sortedLists[indexPath.row]
        
        return cal.immutable == false
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditList" {
            
            let vc = segue.destinationViewController as! EditListViewController
            
            vc.editList = sender as? EKCalendar            
        }
        else if segue.identifier == "ViewList" {
            let vc = segue.destinationViewController as! RemindersListViewController
            vc.calendar = sender as? EKCalendar
        }
    }
    
    @IBAction func onEdit(sender : UIBarButtonItem) {
        
        let wasEditing = self.tableView.editing
        
        self.tableView.setEditing(!wasEditing, animated: true)
        
        if wasEditing {
            self.tableView.reloadData()
        }
        
        self.editBarButton.title = wasEditing ? "Edit" : "Done"
    }
    
}