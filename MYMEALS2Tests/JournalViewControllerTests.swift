//
//  JournalViewControllerTests.swift
//  MYMEALS2
//
//  Created by Marc Felden on 02.02.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import XCTest
import CoreData
@testable import MYMEALS2

class JournalViewControllerTests: XCTestCase {
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var store: NSPersistentStore!
    var sut:JournalViewController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewControllerWithIdentifier("JournalViewController") as! JournalViewController
        managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        store = try? storeCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
        sut.managedObjectContext = managedObjectContext
    }
    
    override func tearDown() {
        super.tearDown()
        managedObjectContext = nil
    }
    
    // MARK: - UITableView Tests
    
    func testThatTableViewHasDataSource() {
        XCTAssertNotNil(sut.tableView)
        XCTAssertNotNil(sut.tableView.dataSource)
        XCTAssertNotNil(sut.tableView.delegate)
    }
    
    func testThatOneFoodEntryReturnsOneRow() {
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        try!foodItem.managedObjectContext?.save()
        let _ = sut.view
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0),1,"There should be one row in this test")
    }
    func testThatTwoFoodEntrysReturnTwoRows() {
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        let foodEntry1 = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        try!foodEntry.managedObjectContext?.save()
        try!foodEntry1.managedObjectContext?.save()
        let _ = sut.view
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0),2,"There should be one row in this test")
    }
    
    func testThatTwoFoodEntrysWithSameTimeReturnOneSection() {
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        let foodEntry1 = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        foodEntry.timeString = "08:00"
        foodEntry1.timeString = foodEntry.timeString
        try!foodEntry.managedObjectContext?.save()
        try!foodEntry1.managedObjectContext?.save()
        let _ = sut.view
        XCTAssertEqual(sut.numberOfSectionsInTableView(sut.tableView),2,"There should be one section in this test")
    }
    
    func testThatTwoFoodEntrysWithDifferentTimeReturnTwoSections() {
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        let foodEntry1 = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        foodEntry.timeString = "08:00"
        foodEntry1.timeString = "09:00"
        try!foodEntry.managedObjectContext?.save()
        try!foodEntry1.managedObjectContext?.save()
        let _ = sut.view
        XCTAssertEqual(sut.numberOfSectionsInTableView(sut.tableView),3,"There should be one section in this test")
    }
    
    
    func testThatTableViewCellReturnsNameUnitOfFoodItem() {
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        foodEntry.timeString = "08:00"
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        foodItem.name = "TestName"
        foodItem.kcal = "150"
        foodEntry.unit = "g"
        foodEntry.amount = "50"
        foodEntry.foodItemRel = foodItem
        try!foodEntry.managedObjectContext?.save()
        let _ = sut.view
        sut.tableView.reloadData()
        let cell = sut.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! JournalCell
        let name = cell.name.text
        XCTAssertEqual(name,"TestName 50g","Cell should return formatted content.")
    }
    
    func testThatTableViewCellReturnsCaloriesOfFoodItem() {
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        foodEntry.timeString = "08:00"
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        foodItem.name = "TestName"
        foodItem.kcal = "150"
        foodEntry.unit = "g"
        foodEntry.amount = "50"
        foodEntry.foodItemRel = foodItem
        try!foodEntry.managedObjectContext?.save()
        let _ = sut.view
        sut.tableView.reloadData()
        let cell = sut.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! JournalCell
        let name = cell.kcal.text
        XCTAssertEqual(name,"75 kcal","Cell should return formatted content.")
    }
    
    func testThatTableViewCellInLastSectionPushesAddEntry() {
        // We create 2 sections
        let navController = UINavigationController()
        navController.viewControllers = [sut]
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        let foodEntry1 = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        foodEntry.timeString = "08:00"
        foodEntry1.timeString = "09:00"
        try!foodEntry.managedObjectContext?.save()
        try!foodEntry1.managedObjectContext?.save()
        let _ = sut.view
        sut.tableView(sut.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2))
        XCTAssertTrue(navController.viewControllers.count == 2, "Should push viewcontroller")
        XCTAssertNotNil((navController.viewControllers.last as? FoodItemsViewController)?.managedObjectContext, "Should set MOC")
    }
    
    func testThatTableViewhasEditButton() {
        let _ = sut.view
        XCTAssertNotNil(sut.navigationItem.rightBarButtonItem, "There should be a button")
    }
    func testThatTableViewsEditButtonHasEditAction() {
        let _ = sut.view
        XCTAssertEqual(sut.navigationItem.rightBarButtonItem?.action.description, "edit:","We should have an edit button")
    }

    func testThatTableViewCanBeSetIntoEditingMode() {
        let _ = sut.view
        sut.edit(UIBarButtonItem())
        XCTAssertTrue(sut.editing, "TableView Should now be in editing mode.")
    }
    
    func testThatCellsCanBeDeleted() {
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        foodItem.timeString = "A"
        let foodItem1 = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        try!managedObjectContext?.save()
        foodItem1.timeString = "A"
        let _ = sut.view
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0),2,"There should be two row in this test")
        sut.edit(UIBarButtonItem())
        sut.tableView(sut.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        //print(sut.fetchedResultsController.fetchedObjects?.count)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0),1,"There should be one row in this test")
    }
    
    func testThatCellsCanBeMovedIntoAnotherSection() {
        // Create 2 Sections
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        let foodEntry1 = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        foodEntry.timeString = "08:00"
        foodEntry1.timeString = "09:00"
        try!foodEntry.managedObjectContext?.save()
        let _ = sut.view
        XCTAssertEqual(sut.numberOfSectionsInTableView(sut.tableView),3,"There should be 3 sections in this test")
        sut.tableView(sut.tableView, moveRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1), toIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        print(foodEntry.timeString)
        print(foodEntry1.timeString)
        XCTAssertEqual(sut.numberOfSectionsInTableView(sut.tableView),2,"There should be 2 sections in this test")
    }
    
    func testThatAddSectionEntryCannotBeMoved() {
        // Create 2 Sections
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        let foodEntry1 = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        foodEntry.timeString = "08:00"
        foodEntry1.timeString = "09:00"
        try!foodEntry.managedObjectContext?.save()
        XCTAssertFalse(sut.tableView(sut.tableView, canMoveRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)),"Add Section should not be movable")
    }
    
    func testThatAddSectionEntryCannotBeDeleted() {
        // Create 2 Sections
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        let foodEntry1 = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        foodEntry.timeString = "08:00"
        foodEntry1.timeString = "09:00"
        try!foodEntry.managedObjectContext?.save()
        XCTAssertFalse(sut.tableView(sut.tableView, canEditRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)),"Add Section should not be deleted")
    }
    
    func testThatSelectingAnEntryInEditModePushesEditEntry() {
        let navController = UINavigationController()
        navController.viewControllers = [sut]
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        let foodEntry1 = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        foodEntry.timeString = "08:00"
        foodEntry1.timeString = "09:00"
        try!foodEntry.managedObjectContext?.save()
        let _ = sut.view
        sut.editing = true
        XCTAssertTrue(navController.viewControllers.count == 1, "Should be only one viewcontroller")
        sut.tableView(sut.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertTrue(navController.viewControllers.count == 2, "Should push viewcontroller")
    }
    
    func testThatSelectingAnEntryInNotEditModePushesShowEntry() {
        let navController = UINavigationController()
        navController.viewControllers = [sut]
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        let foodEntry1 = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        foodEntry.timeString = "08:00"
        foodEntry1.timeString = "09:00"
        try!foodEntry.managedObjectContext?.save()
        let _ = sut.view
        sut.editing = false
        XCTAssertTrue(navController.viewControllers.count == 1, "Should be only one viewcontroller")
        sut.tableView(sut.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertTrue(navController.viewControllers.count == 2, "Should push viewcontroller")
    }
    
    func testThatHeaderOfSectionContainMealAndTime() {
        let navController = UINavigationController()
        navController.viewControllers = [sut]
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        let foodEntry1 = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        foodEntry.timeString = "08:00"
        foodEntry1.timeString = "09:00"
        try!foodEntry.managedObjectContext?.save()
        let _ = sut.view
        let header = sut.tableView(sut.tableView, titleForHeaderInSection: 0)
        let header1 = sut.tableView(sut.tableView, titleForHeaderInSection: 1)
        XCTAssertEqual(header,"Mahlzeit von 08:00 Uhr", "08:00 should be header of first section")
        XCTAssertEqual(header1,"Mahlzeit von 09:00 Uhr", "09:00 should be header of second section")
    }
    
    func testThatFooterContainsSumOfCalories() {
        let navController = UINavigationController()
        navController.viewControllers = [sut]
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        let foodEntry1 = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        foodEntry.timeString = "08:00"
        foodEntry.amount = "80"
        foodEntry1.timeString = "08:00"
        foodEntry1.amount = "90"
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        foodItem.kcal = "100"
        foodEntry.foodItemRel = foodItem
        foodEntry1.foodItemRel = foodItem
        try!foodEntry.managedObjectContext?.save()
        let _ = sut.view
        let footer = sut.tableView(sut.tableView, titleForFooterInSection:  0)
        XCTAssertEqual(footer,"Summe: 170 kcal", "Summe: 170 kcal should be footer of first section")
    }
    func testThatFooterCopesWithNilValues() {
        let navController = UINavigationController()
        navController.viewControllers = [sut]
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        let foodEntry1 = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        foodEntry.timeString = "08:00"
        foodEntry.amount = nil
        foodEntry1.timeString = "08:00"
        foodEntry1.amount = nil
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        foodItem.kcal = nil
        foodEntry.foodItemRel = foodItem
        foodEntry1.foodItemRel = foodItem
        try!foodEntry.managedObjectContext?.save()
        let _ = sut.view
        let footer = sut.tableView(sut.tableView, titleForFooterInSection:  0)
        XCTAssertEqual(footer,"Summe: 0 kcal", "Summe: 0 kcal should be footer of first section")
    }
    
    func testThatViewControllerHasTitle() {
        let _ = sut.view
        XCTAssertEqual(sut.navigationItem.title, "Ernährungs-Tagebuch","Titel vom Viewcontroller should be Ernährungs-Tagebuch")
    }
    
    func testThatCalendarIsConnected() {
        let _ = sut.view
        XCTAssertNotNil(sut.calendar, "Calendar View Should not be nil.")
    }
    
    func testThatCalendarViewIsOfTypeDIDatepicker() {
        let _ = sut.view
        XCTAssertTrue(sut.calendar.isKindOfClass(DIDatepicker))
    }

}

