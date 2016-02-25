//
//  FoodItemsViewControllerTests.swift
//  MYMEALS2.0
//
//  Created by Marc Felden on 30.01.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import XCTest
import CoreData
@testable import MYMEALS2

class FoodItemsViewControllerTests: XCTestCase {
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var store: NSPersistentStore!
    var sut:FoodItemsViewController!
    
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewControllerWithIdentifier("FoodItemsViewController") as! FoodItemsViewController
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
    
    func testThatOneEntryReturnsOneRow() {
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        try!foodItem.managedObjectContext?.save()
        let _ = sut.view
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0),1,"There should be one row in this test")
    }
    
    func testThatTwoEntriesReturnsTwoRows() {
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        try!foodItem.managedObjectContext?.save()
        let foodItem1 = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        try!foodItem1.managedObjectContext?.save()
        let _ = sut.view
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0),2,"There should be one row in this test")
    }
    
    // Problem: Dieser Testcase setzt voraus, dass Zellen bereits Werte zurückgeben.
    func DISABLED_testThatFoodEntriesAreInReversedLastUsedOrder() {
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        foodItem.name = "distantPast"
        try!foodItem.managedObjectContext?.save()
        let foodItem1 = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        foodItem1.name = "distantFuture"
        try!foodItem1.managedObjectContext?.save()
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        foodEntry.date = NSDate.distantPast()
        try!foodEntry.managedObjectContext?.save()
        let foodEntry1 = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        foodEntry.date = NSDate.distantFuture()
        try!foodEntry1.managedObjectContext?.save()
        let _ = sut.view
        foodEntry.foodItemRel = foodItem
        foodEntry1.foodItemRel = foodItem1
        let cell = sut.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        let cell1 = sut.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
        let name = cell?.textLabel?.text
        let name1 = cell1?.textLabel?.text
        XCTAssertEqual(name,"distantFuture","Future is latest Entry")
        XCTAssertEqual(name1,"distantPast","Past is remotest Entry")
    }
    
    func testThatFoodEntriesAreInReversedLastUsedOrder() {
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        foodItem.name = "distantPast"
        foodItem.lastUsed = NSDate.distantPast()
        try!foodItem.managedObjectContext?.save()
        let foodItem1 = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        foodItem1.name = "distantFuture"
        foodItem1.lastUsed = NSDate.distantFuture()
        try!foodItem1.managedObjectContext?.save()
        let _ = sut.view
        let name = (sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! FoodItem).name
        let name1 = (sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! FoodItem).name
        XCTAssertEqual(name,"distantFuture","Future is latest Entry")
        XCTAssertEqual(name1,"distantPast","Past is remotest Entry")
    }
    
    func testThatTableViewCellReturnsNameOfFoodItem() {
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        foodItem.name = "TestName"
        try!foodItem.managedObjectContext?.save()
        let _ = sut.view
        sut.tableView.reloadData()
        let cell = sut.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        let name = cell?.textLabel?.text
        XCTAssertEqual(name,"TestName","Cell should return the Name")
    }
    
    // MARK: - Segue Tests
    
    func testThatAllSegueNamesExist() {
        sut.performSegueWithIdentifier(kSegue.AddFoodItem, sender: self)
        sut.performSegueWithIdentifier(kSegue.ShowDetailsOfFoodItem, sender: self)
  //      sut.performSegueWithIdentifier(kSegue.AddAmount, sender: self)
        sut.performSegueWithIdentifier(kSegue.ScanFoodItem, sender: self)
    }
    
    func testThatAddFoodItemButtonIsConnected() {
        let _ = sut.view
        let toolbarButton = (sut.toolbarItems?.first)! as UIBarButtonItem
        XCTAssertNotNil(toolbarButton,"Button should exist")
    }
    
    func testThatAddFoodItemButtonHasAction() {
        let _ = sut.view
        let toolbarButton = (sut.toolbarItems?.first)! as UIBarButtonItem
        let actions = toolbarButton.action.description
        XCTAssertEqual(actions,"addFoodItem:","Button should have action")

    }
    
    func testThatAddFoodItemButtonPerformsSegue() {
        class FoodItemsViewControllerMock:FoodItemsViewController {
            var addFoodItemSegueHasBeenCalled = false
            private override func performSegueWithIdentifier(identifier: String, sender: AnyObject?) {
                if identifier == kSegue.AddFoodItem {
                    addFoodItemSegueHasBeenCalled = true
                }
            }
        }
        let sut = FoodItemsViewControllerMock()
        sut.managedObjectContext = managedObjectContext
        let _ = sut.view
        sut.addFoodItem(self)
        XCTAssertTrue(sut.addFoodItemSegueHasBeenCalled,"Button should perform Segue")
    }
    
    func testThatCellContainsInfoButton() {
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        foodItem.name = "TestName"
        try!foodItem.managedObjectContext?.save()
        let _ = sut.view
        sut.tableView.reloadData()
        let cell = sut.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertTrue(cell!.accessoryType == .DetailDisclosureButton,"Cell should have DetailButton")
    }
    
    
    func testThatInfoButtonPerformsSegue() {
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        foodItem.name = "TestName"
        try!foodItem.managedObjectContext?.save()
        let _ = sut.view
        sut.tableView.reloadData()
        sut.tableView(sut.tableView, accessoryButtonTappedForRowWithIndexPath: NSZeroIndexPath)
        XCTAssertTrue(sut.performSegueHasBeenCalled,"Button should perform Segue")
    }
    
    
    private func initSutWithNavigationController() ->  UINavigationController {
        let navigationController = UINavigationController()
        navigationController.viewControllers = [sut]
        let _ = sut.view
        return navigationController
    }
    
    func testThatDidSelectPerformsSegue() {

        CoreDataHelper.createFoodItem(inManagedObjectContext: managedObjectContext)
        let navController = initSutWithNavigationController()
        XCTAssertTrue(navController.viewControllers.count == 1, "Should push viewcontroller")
        let indexPath =  NSIndexPath(forRow: 0, inSection: 0)
        
        sut.tableView(sut.tableView, didSelectRowAtIndexPath: indexPath)
        XCTAssertTrue(navController.viewControllers.count == 2, "Should push viewcontroller")

    }
    
    private func initSut() {
        let _ = sut.view
    }
    func testThatTitelIsEintragHinzufügen() {
        initSut()
        XCTAssertEqual(sut.navigationItem.title, "Eintrag hinzufügen")
    }
    
    

    
    func testThatScanButtonIsConnected() {
        let _ = sut.view
        XCTAssertNotNil(sut.navigationItem.rightBarButtonItem ,"Button should exist")
    }
    
    func testThatScanButtonHasAction() {
        initSut()
        let toolbarButton = sut.navigationItem.rightBarButtonItem! as UIBarButtonItem
        let actions = toolbarButton.action.description
        XCTAssertEqual(actions,"scanFoodItem:","Button should have action")
    }
    
    func testThatScanPerformsSegue() {
        class FoodItemsViewControllerMock:FoodItemsViewController {
            var scanFoodItemSegueHasBeenCalled = false
            private override func performSegueWithIdentifier(identifier: String, sender: AnyObject?) {
                if identifier == kSegue.ScanFoodItem {
                scanFoodItemSegueHasBeenCalled = true
                }
            }
        }
        let sut = FoodItemsViewControllerMock()
        sut.scanButton = UIButton()
        sut.managedObjectContext = managedObjectContext
        let _ = sut.view
        sut.scanFoodItem(self)
        XCTAssertTrue(sut.scanFoodItemSegueHasBeenCalled,"Button should perform Segue")
    }
    
    func testThatAddFoodItemProvidesDestinationViewControllerWithFoodItem() {
        let navVC = UINavigationController()
        let destVC = AddFoodItemViewController()
        navVC.viewControllers.append(destVC)
        let segue = UIStoryboardSegue(identifier: kSegue.AddFoodItem, source: sut, destination: navVC)
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        foodItem.name = "TestName"
        try!foodItem.managedObjectContext?.save()
        let _ = sut.view
        sut.tableView.reloadData()
        sut.selectedFoodItem = foodItem
        sut.prepareForSegue(segue, sender: sut)
        XCTAssertTrue(destVC.foodItem != nil, "Destination View Controller requires Food Item")
    }
    
    func testThatAddFoodItemProvidesDestinationViewControllerWithDelegate() {
        let navVC = UINavigationController()
        let destVC = AddFoodItemViewController()
        navVC.viewControllers.append(destVC)
        let segue = UIStoryboardSegue(identifier: kSegue.AddFoodItem, source: sut, destination: navVC)
        let foodItem = FoodItem()
        try!foodItem.managedObjectContext?.save()
        let _ = sut.view
        sut.selectedFoodItem = foodItem
        sut.prepareForSegue(segue, sender: sut)
        XCTAssertNotNil(destVC.delegate, "Destination View Controller requires delegate")
    }
    
    func testThatScanFoodItemProvidesDestinationViewControllerWithDelegate() {
        let destVC = ScanFoodItemViewController()
        let segue = UIStoryboardSegue(identifier: kSegue.ScanFoodItem, source: sut, destination: destVC)
        let foodItem = FoodItem()
        try!foodItem.managedObjectContext?.save()
        let _ = sut.view
        sut.selectedFoodItem = foodItem
        sut.prepareForSegue(segue, sender: sut)
        XCTAssertNotNil(destVC.delegate, "Destination View Controller requires delegate")
    }
    
    func testThatShowDetailsOfFoodItemProvidesDestinationViewControllerWithSelectedFoodItem() {
        let destVC = ShowFoodItemViewController()
        let segue = UIStoryboardSegue(identifier: kSegue.ShowDetailsOfFoodItem, source: sut, destination: destVC)
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        foodItem.name = "TestName"
        try!foodItem.managedObjectContext?.save()
        let _ = sut.view
        sut.tableView.reloadData()
        sut.selectedFoodItem = foodItem
        sut.prepareForSegue(segue, sender: sut)
        XCTAssertEqual(destVC.foodItem, foodItem, "Destination View Controller requires Food Item")
    }
    

    func testThatAddAmountProvidesDestinationViewControllerWithDelegate() {
        CoreDataHelper.createFoodItem(inManagedObjectContext: managedObjectContext)
        let navigationController = UINavigationController()
        navigationController.viewControllers.append(sut)
        
        print(navigationController.topViewController)
        
        sut.tableView(sut.tableView, didSelectRowAtIndexPath: ZeroIndexPath)
        print(navigationController.topViewController)
        let destVC = navigationController.topViewController as! AddAmountViewController
        
        XCTAssertNotNil(destVC.delegate)
        XCTAssertNotNil(destVC.foodItem)
    }
    
    // MARK: - SearchTests
    
    func testThatViewControllerHasSearchbar() {
        let _ = sut.view
        XCTAssertNotNil(sut.searchBar)
    }
    
    func testThatUISearchBarDelegateIsSet() {
        let _ = sut.view
        XCTAssertNotNil(sut.searchBar.delegate)
    }
    
    func testThatOneRowRemainsWhenSearchingItem() {
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        foodItem.name = "Müsli"
        try!foodItem.managedObjectContext?.save()
        let foodItem1 = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        foodItem1.name = "H-Milch"
        try!foodItem1.managedObjectContext?.save()
        let _ = sut.view
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0),2,"There should be one row in this test")
        sut.searchBar.text = "H-Milch"
        sut.searchBar(sut.searchBar, textDidChange: "H-Milch")
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0),1,"There should be one row in this test")
    }
    
    func testThatKeyboardsShowFDDBButton() {
        let _ = sut.view
        XCTAssertTrue(sut.searchBar.returnKeyType == .Search,"Search on the keyboard")
    }
    
    func testThatKeyboardReturnKeyTriggersSearch() {
        class FoodDatabaseSearchControllerMock: FoodDatabaseSearchController {
            var performSearchWasCalled = false
            private override func performSearch(completionHandler: ([FoodItem]) -> ()) {
                performSearchWasCalled = true
            }
        }
        let foodDatabaseSearchControllerMock = FoodDatabaseSearchControllerMock()
        sut.foodDatabaseSearchController = foodDatabaseSearchControllerMock
        let _ = sut.view
        sut.searchBar = UISearchBar()
  //      sut.searchBar.text = "Test"
        sut.searchBarSearchButtonClicked(sut.searchBar)
        XCTAssertTrue(foodDatabaseSearchControllerMock.performSearchWasCalled)

    }
    
    func testThatSearchStringReturnsFoodItems() {
        let expectation = expectationWithDescription("3 Items")
        let foodDatabaseSearchController = FoodDatabaseSearchController()
        foodDatabaseSearchController.searchText = "H-Milch"
        foodDatabaseSearchController.managedObjectContext = managedObjectContext
        foodDatabaseSearchController.performSearch { (fooditems) -> () in
            XCTAssertEqual(fooditems.count, 10,"We should get results")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(4) { (error) -> Void in
            if let error = error {
                print(error.description)
            }
        }
    }
    
    func testThatAfterFDDBSearchTableViewShowsFDDBResults() {
        let foodItem = FoodItem()
        sut.foodDatabaseSearchFoodItems = [FoodItem]()
        sut.foodDatabaseSearchFoodItems.append(foodItem)
        sut.tableView.reloadData()
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 1)
    }
    
    func testThatAfterFDDBSearchResignToFirstResponderIsCalled() {
        class UISearchBarMock:UISearchBar {
            var resignFirstResponderHasBeenCalled = false
            private override func resignFirstResponder() -> Bool {
                resignFirstResponderHasBeenCalled = true
                return true
            }
        }
        let searchBarMock = UISearchBarMock()
        sut.searchBar = searchBarMock
        let _ = sut.view
        sut.searchBarSearchButtonClicked(searchBarMock)
        XCTAssertTrue(searchBarMock.resignFirstResponderHasBeenCalled, "Performing Search dismisses Keyboard")
    }
    
    
    func testThatToolBarIsVisible() {
        let navigationController = UINavigationController()
        navigationController.viewControllers = [sut]
        initSut()
        XCTAssertFalse(navigationController.toolbarHidden, "")
    }

    func testThatFoodItemsNameIsHelveticaNeue() {
        CoreDataHelper.createFoodItem(inManagedObjectContext: managedObjectContext)
        let cell = sut.tableView(sut.tableView, cellForRowAtIndexPath: ZeroIndexPath)
        XCTAssertEqual(cell.textLabel!.font, bodyFont)
    }
    
    // MARK: Anforderung 2: beim normalen Klicken auf eine Zelle wird der empfangene FoodEntry (der Datum und Section enthält, in die eingefügt werden soll) an die AddAmount Scene übertragen und diese auf den Stack des NavigationControllers gelegt.

    private func dummyFoodEntry() -> FoodEntry
    {
        return CoreDataHelper.addFoodEntry(dateString: todayDateString, inSection: 0, inManagedObjectContext: managedObjectContext)
    }
    
    func testThatCellSelectionProvidesDestinationViewControllerWithFoodEntry()
    {
        CoreDataHelper.createFoodItem(inManagedObjectContext: managedObjectContext)
        sut.foodEntry = dummyFoodEntry()
        sut.tableView(sut.tableView, didSelectRowAtIndexPath: ZeroIndexPath)
        // TODO: I do not know how to verify this.
    }
    
    func testThatWeProvideAddAmountViewControllerWithFoodEntry()
    {
        let navigationController = UINavigationController()
        CoreDataHelper.createFoodItem(inManagedObjectContext: managedObjectContext)
        sut.foodEntry = dummyFoodEntry()
        navigationController.viewControllers.append(sut)
        print(navigationController.viewControllers.count)
        sut.tableView(sut.tableView, didSelectRowAtIndexPath: ZeroIndexPath)
        print(navigationController.viewControllers.count)
        let destinationViewController = navigationController.topViewController as! AddAmountViewController
        print(destinationViewController)
        print(destinationViewController.delegate)
        print(destinationViewController.foodItem)
        XCTAssertNotNil(destinationViewController.foodEntry)
        
    }

}
