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
    
    // MARK: Helper Methods
    
    private func createFoodEntry(timeString: String? = nil, unit: String? = nil, amount: String? = nil, foodItem: FoodItem? = nil) -> FoodEntry {
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        if let timeString = timeString {
            foodEntry.timeString = timeString
        }
        if let unit = unit {
            foodEntry.unit = unit
        }
        if let amount = amount {
            foodEntry.amount = amount
        }
        if let foodItem = foodItem {
            foodEntry.foodItemRel = foodItem
        }
        return foodEntry
    }
    
    private func createFoodItem(name name: String? = nil, kcal: String? = nil) -> FoodItem {
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        if let name = name {
            foodItem.name = name
        }
        if let kcal = kcal {
            foodItem.kcal = kcal
        }

        return foodItem
    }
    
    private func createTwoFoodEntriesInTwoSections() {
        let _ = createFoodEntry("A")
        let _ = createFoodEntry("B")
    }
    
    private func createTwoFoodEntriesInOneSections() {
        let _ = createFoodEntry("A")
        let _ = createFoodEntry("A")
    }
    
    // MARK: Tests
    
    func testThatOneFoodEntryReturnsOneRow() {
        createFoodEntry()
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0),1,"There should be one row in this test")
    }
    func testThatTwoFoodEntrysReturnTwoRows() {
        createTwoFoodEntriesInOneSections()
        let _ = sut.view
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0),2,"There should be one row in this test")
    }
 
    
    func testThatTwoFoodEntrysWithSameTimeReturnOneSection() {
        createTwoFoodEntriesInOneSections()
        let _ = sut.view
        XCTAssertEqual(sut.numberOfSectionsInTableView(sut.tableView),2,"There should be two sections in this test")
    }
    
    func testThatTwoFoodEntrysWithDifferentTimeReturnTwoSections() {
        createTwoFoodEntriesInTwoSections()
        let _ = sut.view
        XCTAssertEqual(sut.numberOfSectionsInTableView(sut.tableView),3,"There should be three sections in this test")
    }
    
    
    func testThatTableViewCellReturnsNameUnitOfFoodItem() {
        
        let foodItem = createFoodItem(name: "TestName", kcal: "150")
        let _ = createFoodEntry("08:00", unit: "g", amount: "50", foodItem: foodItem)
        let _ = sut.view
        sut.tableView.reloadData()
        let cell = sut.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! JournalCell
        let name = cell.name.text
        XCTAssertEqual(name,"TestName 50g","Cell should return formatted content.")
    }
    
    func testThatTableViewCellReturnsCaloriesOfFoodItem() {

        let foodItem = createFoodItem(name: "TestName", kcal: "150")
        let _ = createFoodEntry("08:00", unit: "g", amount: "50", foodItem: foodItem)
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
        createTwoFoodEntriesInTwoSections()
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
        createTwoFoodEntriesInOneSections()
        let _ = sut.view
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0),2,"There should be two row in this test")
        sut.edit(UIBarButtonItem())
        sut.tableView(sut.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0),1,"There should be one row in this test")
    }
    

    
    func testThatCellsCanBeMovedIntoAnotherSection() {
        createTwoFoodEntriesInTwoSections()
        let _ = sut.view
        XCTAssertEqual(sut.numberOfSectionsInTableView(sut.tableView),3,"There should be 3 sections in this test")
        sut.tableView(sut.tableView, moveRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1), toIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertEqual(sut.numberOfSectionsInTableView(sut.tableView),2,"There should be 2 sections in this test")
    }
    
    func testThatAddSectionEntryCannotBeMoved() {
        createTwoFoodEntriesInTwoSections()
        XCTAssertFalse(sut.tableView(sut.tableView, canMoveRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)),"Add Section should not be movable")
    }
    
    func testThatAddSectionEntryCannotBeDeleted() {
        createTwoFoodEntriesInTwoSections()
        XCTAssertFalse(sut.tableView(sut.tableView, canEditRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)),"Add Section should not be deleted")
    }
    
    func testThatSelectingAnEntryInEditModePushesEditEntry() {
        let navController = UINavigationController()
        navController.viewControllers = [sut]
        createTwoFoodEntriesInTwoSections()
        let _ = sut.view
        sut.editing = true
        XCTAssertTrue(navController.viewControllers.count == 1, "Should be only one viewcontroller")
        sut.tableView(sut.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertTrue(navController.viewControllers.count == 2, "Should push viewcontroller")
    }
    
    func testThatSelectingAnEntryInNotEditModePushesShowEntry() {
        let navController = UINavigationController()
        navController.viewControllers = [sut]
        createTwoFoodEntriesInTwoSections()
        let _ = sut.view
        sut.editing = false
        XCTAssertTrue(navController.viewControllers.count == 1, "Should be only one viewcontroller")
        sut.tableView(sut.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertTrue(navController.viewControllers.count == 2, "Should push viewcontroller")
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
    
    func DIS_testThatSelectingDateInDatePickerSetsSelectedDate() {
        let _ = sut.view
        let testDate = NSDate()
        sut.calendar.selectDate(testDate)
        print(testDate)
        print(sut.selectedDateOnDatepicker)
        XCTAssertEqual(testDate, sut.selectedDateOnDatepicker, "When changing date on Datepicker, the Class must be notified.")
    }
    
    func testThatSelectingDateThatAlreadyContainsValuesShowsTheseValues() {
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        foodEntry.timeString = "08:00"
        foodEntry.amount = "80"
    }
    
    private func titleInSection(section: Int) -> String {
        return sut.tableView(sut.tableView, titleForHeaderInSection: section)!
    }
    
    func testThatFirstSectionContaisFrühstück() {
        XCTAssertEqual(titleInSection(0),"Frühstück","First Section should contain Frühstück")
    }
    func testThatFirstSectionContaisZweitesFrühstück() {
        XCTAssertEqual(titleInSection(1),"2. Frühstück","First Section should contain 2. Frühstück")
    }
    func testThatFirstSectionContaisMittagessen() {
        XCTAssertEqual(titleInSection(2),"Mittagessen","First Section should contain Mittagessen")
    }
    func testThatFirstSectionContaispostworkoutShaje() {
        XCTAssertEqual(titleInSection(3),"Post-Workout-Shake","First Section should contain PostworkoutShake")
    }
    func testThatFirstSectionContainsAbendbrot() {
        XCTAssertEqual(titleInSection(4),"Abendbrot","First Section should contain Abendbrot")
    }
    func testThatFirstSectionContainsNachtisch() {
        XCTAssertEqual(titleInSection(5),"Nachtisch","First Section should contain Nachtisch")
    }
    
    private func initSutWithNavigationController() ->  UINavigationController {
        let navigationController = UINavigationController()
        navigationController.viewControllers = [sut]
        let _ = sut.view
        return navigationController
    }
    func testThatButtomLineExists() {
        let navigationController = initSutWithNavigationController()
        XCTAssertFalse(navigationController.toolbarHidden, "Show Toolbar")
    }
    
    private func initSutWithNavigationControllerAndGetButton() -> UIBarButtonItem {
        let navigationController = initSutWithNavigationController()
        let button = navigationController.toolbarItems!.first! as UIBarButtonItem
        return button
    }
    
    func testThatToolbarButtonHasTitle() {
        let button = initSutWithNavigationControllerAndGetButton()
        XCTAssertEqual(button.title, "Load Default", "There should be one Button in Toolbar with title Load Default")
    }
    
    func testThatToolbarButtonHasAction() {
        let button = initSutWithNavigationControllerAndGetButton()
        XCTAssertEqual(button.action.description, "loadDefaults:", "There should be one Button in Toolbar with action Load Default")
    }
    
    func testThatLoadDefaultActionLoadsValues() {
        let _ = sut.view
        XCTAssertEqual(sut.fetchedResultsController.fetchedObjects?.count, 0, "First there should be no objects in database")
        sut.loadDefaults(self)
        sut.fetch()
        XCTAssertEqual(sut.fetchedResultsController.fetchedObjects?.count, 5, "First there should be no objects in database")
    }
    
//    func testThatFoodEntriesHaveCorrectValues() {
//        sut.loadDefaults(self)
//        sut.fetch()
//        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! FoodEntry
//        XCTAssertEqual(foodEntry.amount,"35")
//    }

}

