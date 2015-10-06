//
//  EditRemindersTests.swift
//  EditRemindersTests
//
//  Created by Andrew Grant on 5/26/15.
//  Copyright (c) Andrew Grant. All rights reserved.
//

import UIKit
import XCTest

class TodoAppTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNewList() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
        
        let store = TodoStore()
        
        let newList = TodoList(title: "My List")
        
        var error : NSError?
        
        store.saveObject(newList, error: &error)
        
        XCTAssert(error == nil, "Failed to save list")
        
        XCTAssert(store.lists.count == 1, "TodoStore has wrong list count")
    }
    
    func testNewItem() {
        
        let store = TodoStore()
        
        var error : NSError?
        
        let newList = TodoList(title: "My List")
        store.saveObject(newList, error: &error)
        
        XCTAssertNil(error, "Failed to save new list")
        
        let newItem = TodoEntry(title: "New Item")
        newItem.parentUuid = newList.uuid
        
        store.saveObject(newItem, error: &error)
        
        XCTAssertNil(error, "Failed to save new item")
    }
    
    func testSaveItemNewList() {
        
        let store = TodoStore()
        
        var error : NSError?
        
        let newItem = TodoEntry(title: "New Item")
        
        store.saveObject(newItem, error: &error)
        
        XCTAssertNotNil(error, "Item error was not nil")
    }
    
    func testRemoveList() {
        
        let store = TodoStore()
        let newList = TodoList(title: "New List")
        let newItem = TodoEntry(title: "New Item")
        
        store.saveObject(newList, error: nil)
        
        newItem.parentUuid = newList.uuid
        store.saveObject(newItem, error: nil)
        
        XCTAssertTrue(store.lists.count == 1, "Incorrect list count");
        XCTAssertTrue((store.itemsInList(newList)!).count == 1, "Incorrect item count");
        
        store.removeObject(newList, error: nil)
        
        XCTAssertTrue(store.lists.count == 0, "List count was not zero");

        // check that item is also gone
        
        //XCTAssertTrue(store.items[newList.uuid!] == nil, "Item cache for list was not removed")
    }
    
    func removeItem() {
        let store = TodoStore()
        let newList = TodoList(title: "New List")
        let newItem = TodoEntry(title: "New Item")
        
        store.saveObject(newList, error: nil)
        
        newItem.parentUuid = newList.uuid
        store.saveObject(newItem, error: nil)
        
        XCTAssertTrue(store.lists.count == 1, "Incorrect list count");
        XCTAssertTrue((store.itemsInList(newList)!).count == 1, "Incorrect item count");
        
        store.removeObject(newItem, error: nil)
        
        // check list
        XCTAssertTrue((store.itemsInList(newList)!).count == 0, "Incorrect item count");
        
        // check cache directly
        //let listCache = store.items[newList.uuid!]!
        //XCTAssertTrue(count(listCache) == 0, "List cache not empty")

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
