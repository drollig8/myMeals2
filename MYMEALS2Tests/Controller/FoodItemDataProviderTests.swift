//
//  FoodItemDataProviderTests.swift
//  MYMEALS2
//
//  Created by Marc Felden on 27.02.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import XCTest
import CoreData
@testable import MYMEALS2

class FoodItemDataProviderTests: XCTestCase {
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var store: NSPersistentStore!
    
    var sut: FoodItemDataProvider!
    var tableView: UITableView!
    var controller: FoodItemsViewController!
    
    override func setUp()
    {
        super.setUp()
        
        // TODO Auslagern!
        managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        store = try? storeCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
        
        sut = FoodItemDataProvider()
        sut.foodItemManager = FoodItemManager(withManagedObjectContext: managedObjectContext)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        controller = storyboard.instantiateViewControllerWithIdentifier("FoodItemsViewController") as! FoodItemsViewController
        _ = controller.view
        
        tableView = controller.tableView // IMPORTANT!
        tableView.dataSource = sut
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    func testNumbersOfSection_IsSix()
    {
        let sut = FoodItemDataProvider()
        
        let tableView = UITableView()
        tableView.dataSource = sut
        
        let numberOfSections = tableView.numberOfSections
        XCTAssertEqual(numberOfSections, 6)
        
    }
    
    func testNumberOfRowsInFirstSection_IsFoodItemsCount()
    {
        let sut = FoodItemDataProvider()
        let foodItemManager = FoodItemManager(withManagedObjectContext: managedObjectContext)
        sut.foodItemManager = foodItemManager
        
        let tableView = UITableView()
        tableView.dataSource = sut
        
        sut.foodItemManager?.addItem(FoodItem(name: "Test Food Item"))
        
        XCTAssertEqual(tableView.numberOfRowsInSection(0), 1)
        
        sut.foodItemManager?.addItem(FoodItem(name: "Test Food Item2"))
        tableView.reloadData() // Es wäre super elegant, wenn der ItemManager den DataProvider informieren könnte, wenn ein Item hinzugefügt wurde, damit der TableView reloaded werden kann.
        
        XCTAssertEqual(tableView.numberOfRowsInSection(0), 2)
    }
    
    func testCellForRow_ReturnsItemCell()
    {
        sut.foodItemManager?.addItem(FoodItem(name: "Test Food Item"))
        tableView.reloadData()
        
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        
        XCTAssertTrue(cell is FoodItemCell)
    }
    
    func testCellForRow_Dequeues()
    {
        let mockTableView = MockTableView()
        
        mockTableView.dataSource = sut
        mockTableView.registerClass(FoodItemCell.self, forCellReuseIdentifier: "Cell")
        sut.foodItemManager?.addItem(FoodItem(name: "First"))
        
        mockTableView.reloadData()
        
        _ = mockTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertTrue(mockTableView.cellGotDequeued)
    }

    
    func testConfigCell_GetsCalledInCellForRow()
    {
        let mockTableView = MockTableView.mockTableViewWithDataSource(sut)
        
        let foodItem = FoodItem(name: "Test")
        
        sut.foodItemManager?.addItem(foodItem)
        mockTableView.reloadData()
        
        let cell = mockTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! MockFoodItemCell
        
        XCTAssertEqual(cell.foodItem, foodItem)
    }
    
    
    func testSelectingACell_SendsNotification()
    {
        let item = FoodItem(name: "Test")
        sut.foodItemManager?.addItem(item)
        
        expectationForNotification(kFoodItemSelectedNotification, object: nil) { (notification) -> Bool in
            
            guard let index = notification.userInfo?["index"] as? Int else {return false}
            return index == 0
        }
        tableView.delegate?.tableView?(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        
        waitForExpectationsWithTimeout(3, handler: nil)
    }
    

}


extension FoodItemDataProviderTests
{
    class MockTableView: UITableView
    {
        var cellGotDequeued = false
        override func dequeueReusableCellWithIdentifier(identifier: String, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            cellGotDequeued = true
            return super.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        }
        
        class func mockTableViewWithDataSource(dataSource: UITableViewDataSource) -> MockTableView
        {
            let mockTableView = MockTableView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), style: .Plain)
            // necessary because "zero" cells will have size 0.0 and be nil.
            
            mockTableView.dataSource = dataSource
            mockTableView.registerClass(MockFoodItemCell.self, forCellReuseIdentifier: "Cell")
            
            return mockTableView
        }
        
    }
    
    
    class MockFoodItemCell: FoodItemCell
    {
        var foodItem: FoodItem?
        override func configureCelWithItem(foodItem: FoodItem){
            self.foodItem = foodItem
        }
        
    }

   
}
