//
//  FoodItemManagerTests.swift
//  MYMEALS2
//
//  Created by Marc Felden on 26.02.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import XCTest
@testable import MYMEALS2

class FoodItemManagerTests: XCTestCase
{
    var sut: FoodItemManager!
    override func setUp()
    {
        super.setUp()
        sut = FoodItemManager()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    func testFoodItemsCount_Initially_ShouldBeZero()
    {
        XCTAssertEqual(sut.itemCount, 0, "Initially toDo count should be 0")
    }
  
    func testFoodItemsCount_AfterAddingOneItem_IsOne()
    {
        sut.addItem(FoodItem(name: "Test FoodItem"))
        XCTAssertEqual(sut.itemCount,1, "foodItemCount should be 1")
    }
    /*
    func testItemAtIndex_ShouldReturnPreviouslyAddedItem()
    {
        let item = ToDoItem(title: "Item")
        sut.addItem(item)
        let returnedItem = sut.itemAtIndex(0)
        XCTAssertEqual(item.title, returnedItem.title,"should be the same item")
    }
    
    func testCheckingItem_ChangesCountOfToDoAndOfDoneItems()
    {
        sut.addItem(ToDoItem(title: "First Item"))
        sut.checkItemAtIndex(0)
        XCTAssertEqual(sut.toDoCount,0, "todoCount should be 0")
        XCTAssertEqual(sut.doneCount, 1,"doneCount should be 1")
    }
    
    func testCheckingItem_RemovesItFromTheToDoItemList()
    {
        let firstItem = ToDoItem(title: "First")
        let secondItem = ToDoItem(title: "Second")
        sut.addItem(firstItem)
        sut.addItem(secondItem)
        sut.checkItemAtIndex(0)
        XCTAssertEqual(sut.itemAtIndex(0).title, secondItem.title)
    }
    
    func testDoneItemAtIndex_ShouldReturnPreviouslyCheckedItem()
    {
        let item = ToDoItem(title: "Item")
        sut.addItem(item)
        sut.checkItemAtIndex(0)
        let returnedItem = sut.doneItemAtIndex(0)
        XCTAssertEqual(item.title, returnedItem.title,"should be the same")
    }
*/
    
    // not equal

}

