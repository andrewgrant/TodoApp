//
//  ChangeListViewController.swift
//  SimpleReminders
//
//  Created by Andrew Grant on 5/25/15.
//  Copyright (c) Andrew Grant. All rights reserved.
//

import UIKit
import EventKit

class ChangeListViewController : BaseListsViewController
{
    var reminder : EKReminder!
    
    override func listWasSelected(calendar : EKCalendar) {       
        reminder.calendar = calendar
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
