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
    
    func testInit_ShouldSetName()
    {
        let item = FoodItem(name: "Test name")
        XCTAssertEqual(item.name, "Test name","Initializer should set the item name")
    }
    
    func testInit_ShouldSetNameAndCalories()
    {
        let item = FoodItem(name: "Test Name", calories: 123.3)
        XCTAssertEqual(123.3, item.calories)
    }
    
    func testInit_ShouldSetNameAndCaloriesAndCarbs()
    {
        let item = FoodItem(name: "Test Name", calories: 0.0, carbs: 123.4)
        XCTAssertEqual(123.4, item.carbs)
    }
    
    func testInit_ShouldSetNameAndCaloriesAndCarbsAndProtein()
    {
        let item = FoodItem(name: "Test Name", calories: 0.0, carbs: 0.0, protein: 123.4)
        XCTAssertEqual(123.4, item.protein)
    }
    
    func testInit_ShouldSetNameAndCaloriesAndCarbsAndProteinAndFat()
    {
        let item = FoodItem(name: "Test Name", calories: 0.0, carbs: 0.0, protein: 0.0, fat: 123.4)
        XCTAssertEqual(123.4, item.fat)
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

