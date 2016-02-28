//
//  FoodItemManagerTests.swift
//  MYMEALS2
//
//  Created by Marc Felden on 26.02.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import XCTest
import CoreData
@testable import MYMEALS2

class FoodItemManagerTests: XCTestCase
{
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var store: NSPersistentStore!
    var sut: FoodItemManager!
    
    override func setUp()
    {
        super.setUp()
        
        managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        store = try? storeCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
        
        sut = FoodItemManager(withManagedObjectContext: managedObjectContext)
        assert(managedObjectContext != nil)
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
    
    // Hier müssen wir testen, dass wenn wir einmal den Manager = nil setzten und neu
    // instantitiieren, dass die Objecte noch vorhanden sind. Weil: Er muss sie - egal wie - in CD speichern.
    
    func testFoodItemsCount_AfterReiinitializingFoodItemManager_StillIsOne()
    {
        sut.addItem(FoodItem(name: "Test FoodItem"))
        XCTAssertEqual(sut.itemCount,1, "foodItemCount should be 1")
        
        sut = nil
        sut = FoodItemManager(withManagedObjectContext: managedObjectContext)
        XCTAssertEqual(sut.itemCount,1, "foodItemCount should be 1")
    }
    
    func testFoodItemAtIndex_ShouldReturnItem()
    {
        let item = FoodItem(name: "Item")
        sut.addItem(item)
        let returnedItem = sut.itemAtIndex(0)
        XCTAssertEqual(item.name, returnedItem.name,"should be the same")
    }
    
    func testThatAddingTheSameItem_DoesNotIncreaseCount()
    {
        let firstItem = FoodItem(name: "First")
        sut.addItem(firstItem)
        sut.addItem(firstItem)
        XCTAssertEqual(sut.itemCount, 1)
    }


}

