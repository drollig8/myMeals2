//
//  File.swift
//  MYMEALS2
//
//  Created by Marc Felden on 26.02.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import XCTest
@testable import MYMEALS2

class FoodItemTests: XCTestCase
{
    override func setUp()
    {
        super.setUp()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    func testInit_ShouldSetTitle()
    {
        let item = FoodItem(name: "Test name")
        XCTAssertEqual(item.name, "Test name","Initializer should set the item name")
    }
    
    func testFoodItems_ShouldBeEqual()
    {
        let firstFoodItem = FoodItem(name: "Entry1")
        let secondFoodItem = FoodItem(name: "Entry1")
        XCTAssertEqual(firstFoodItem, secondFoodItem)
    }
    
    func testWhenFoodItemNamesDiffer_ShouldbeNotEqual()
    {
        let firstFoodItem = FoodItem(name: "Entry1")
        let secondFoodItem = FoodItem(name: "Entry2")
        
        XCTAssertNotEqual(firstFoodItem, secondFoodItem)
    }
}

