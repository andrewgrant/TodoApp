//
//  EditListViewController.swift
//  EditReminders
//
//  Created by Andrew Grant on 5/26/15.
//  Copyright (c) Andrew Grant. All rights reserved.
//

import UIKit


class EditListViewController : UITableViewController
{
    // MARK: - Properties
    @IBOutlet var saveBarButton : UIBarButtonItem!
    @IBOutlet var titleTextField : UITextField!
    
    var editList : TodoList!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if editList != nil {
            self.titleTextField.text = editList.title
            self.navigationItem.title = editList.title
        }
        else {
            self.navigationItem.rightBarButtonItem = saveBarButton
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if editList != nil && titleTextField.text?.characters.count > 0 {
            editList.title = titleTextField.text
            
            var error : NSError?
            
            TodoStore.sharedInstance.saveObject(editList, error: &error)
            
            if error != nil {
                print(error!.description)
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onSave(sender : UIBarButtonItem)
    {
        if titleTextField.text?.characters.count > 0 {
            
            // create a new list, it will be saved when we disappear
            editList = TodoList(title: titleTextField.text!)
            
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}
