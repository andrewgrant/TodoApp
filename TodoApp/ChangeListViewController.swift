//
//  ChangeListViewController.swift
//  SimpleReminders
//
//  Created by Andrew Grant on 5/25/15.
//  Copyright (c) Andrew Grant. All rights reserved.
//

import UIKit

class ChangeListViewController : BaseListsViewController
{
    var item : TodoItem!
    
    override func listWasSelected(list : TodoList) {
        item.list = list
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
