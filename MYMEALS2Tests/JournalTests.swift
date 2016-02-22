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
    
    // TODO DUBLICATE MOVE TO CoreDataHelper
    private func createFoodEntry(inSection section: Int? = 0, unit: String? = nil, amount: String? = nil, foodItem: FoodItem? = nil) -> FoodEntry {
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry

        foodEntry.section = section!
        
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
    
    private func createFoodEntry(atDateString dateString: String) -> FoodEntry {
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        
        foodEntry.dateString = dateString
        return foodEntry
    }
    
    // TODO: User CoreDataHelper
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
        createFoodEntry(inSection: 0)
        createFoodEntry(inSection: 1)
    }
    
    private func createTwoFoodEntriesInSectionZero() {
        createFoodEntry(inSection: 0)
        createFoodEntry(inSection: 0)
    }
    
    // MARK: Tests
    
    func testThatOneFoodEntryReturnsOneRow() {
        createFoodEntry(inSection: 0)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0),2,"There should be one two Rows (add Item) in this test")
    }
    
    func testThatTwoFoodEntrysReturnTwoRows() {
        createTwoFoodEntriesInSectionZero()
        let _ = sut.view
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0),3,"There should be one row in this test")
    }
    
    func testThatTableViewCellReturnsNameUnitOfFoodItem() {
        
        let foodItem = createFoodItem(name: "TestName", kcal: "150")
        createFoodEntry(inSection: 0, unit: "g", amount: "50", foodItem: foodItem)
        let _ = sut.view
        sut.tableView.reloadData()
        let cell = sut.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! JournalCell
        let name = cell.name.text
        XCTAssertEqual(name,"TestName 50g","Cell should return formatted content.")
    }
    
    func testThatTableViewCellReturnsCaloriesOfFoodItem() {

        let foodItem = createFoodItem(name: "TestName", kcal: "150")
        let _ = createFoodEntry(inSection: 0, unit: "g", amount: "50", foodItem: foodItem)
        let _ = sut.view
        sut.tableView.reloadData()
        let cell = sut.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! JournalCell
        let name = cell.kcal.text
        XCTAssertEqual(name,"75 kcal","Cell should return formatted content.")
    }
    

    func testThatTableViewCellInLastSectionPushesAddEntry() {
        createTwoFoodEntriesInTwoSections()
        let navController = initSutWithNavigationController()
        XCTAssertTrue(navController.viewControllers.count == 1, "Should push viewcontroller")
        sut.tableView(sut.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2))
        XCTAssertTrue(navController.viewControllers.count == 2, "Should push viewcontroller")
        XCTAssertNotNil((navController.viewControllers.last as? FoodItemsViewController)?.managedObjectContext, "Should set MOC")
    }
    
    func testThatSelectionPlusSymbolAddsEntry() {
        createTwoFoodEntriesInTwoSections()
        let navController = initSutWithNavigationController()
        XCTAssertTrue(navController.viewControllers.count == 1, "Should push viewcontroller")
        let indexPath =  NSIndexPath(forRow: 0, inSection: 2)
        sut.tableView(sut.tableView, commitEditingStyle: .Insert, forRowAtIndexPath: indexPath)
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
        XCTAssertTrue(sut.editMode, "TableView Should now be in editing mode.")
    }
    
    func testThatCellsCanBeDeleted() {
        createTwoFoodEntriesInSectionZero()
        let _ = sut.view
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0),3,"There should be two row in this test")
        sut.edit(UIBarButtonItem())
        sut.tableView(sut.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0),2,"There should be one row in this test")
    }
    

    func testThatAddSectionEntryCannotBeMoved() {
        createTwoFoodEntriesInTwoSections()
        XCTAssertFalse(sut.tableView(sut.tableView, canMoveRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)),"Add Section should not be movable")
    }
    

    
    private func navigationControllerWithSut() -> UINavigationController {
        let navController = UINavigationController()
        navController.viewControllers = [sut]
        return navController
    }
    
    func testThatSelectingAnEntryInEditModePushesEditEntry() {
        let navController = navigationControllerWithSut()
        createTwoFoodEntriesInTwoSections()
        let _ = sut.view
        
        // TODO uses editing! That is FALSCH
        sut.editing = true
        XCTAssertTrue(navController.viewControllers.count == 1, "Should be only one viewcontroller")
        sut.tableView(sut.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertTrue(navController.viewControllers.count == 2, "Should push viewcontroller")
    }
    
    func testThatSelectingAnEntryInNotEditModePushesShowEntry() {
        let navController = navigationControllerWithSut()
        createTwoFoodEntriesInTwoSections()
        let _ = sut.view
        sut.editing = false
        XCTAssertTrue(navController.viewControllers.count == 1, "Should be only one viewcontroller")
        sut.tableView(sut.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertTrue(navController.viewControllers.count == 2, "Should push viewcontroller")
    }
    
    
    func testThatFooterContainsSumOfCalories() {
        let foodItem = createFoodItem(name: nil, kcal: "100")
        createFoodEntry(inSection: 0, unit: nil, amount: "80", foodItem: foodItem)
        createFoodEntry(inSection: 0, unit: nil, amount: "90", foodItem: foodItem)
        let _ = sut.view
        let footer = sut.tableView(sut.tableView, titleForFooterInSection:  0)
        XCTAssertEqual(footer,"Summe: 170 kcal", "Summe: 170 kcal should be footer of first section")
    }
    func testThatFooterCopesWithNilValues() {
        let foodItem = createFoodItem(name: nil, kcal: "100")
        createFoodEntry(inSection: 0, unit: nil, amount: "0", foodItem: foodItem)
        createFoodEntry(inSection: 0, unit: nil, amount: "0", foodItem: foodItem)
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
        initSutWithNavigationController()
        let button = sut.toolbarItems!.first! as UIBarButtonItem
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
    
    //DUBLICATE
    private func getAllFoodItems() -> [FoodItem] {
        
        let fetchRequest = NSFetchRequest(entityName: "FoodItem")
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [nameSort]
        let foodItems = try!managedObjectContext.executeFetchRequest(fetchRequest) as! [FoodItem]
        return foodItems
        
    }
    
    func testThatFoodItemsCanBeCreated() {
        
        sut.addFoodItem(named: "Test", kcal: "100", kohlenhydrate: "100", protein: "100", fett: "10")
        let foodItems = getAllFoodItems()
        let foodItem = foodItems.first
        XCTAssertEqual(foodItem?.name, "Test")
        XCTAssertEqual(foodItem?.kohlenhydrate, "100")
        XCTAssertEqual(foodItem?.protein, "100")
        XCTAssertEqual(foodItem?.fett, "10")
        
    }
    
    func testThatNoDublicateFoodItemsCanBeCreated() {
        
        sut.addFoodItem(named: "Test", kcal: "100", kohlenhydrate: "100", protein: "100", fett: "10")
        sut.addFoodItem(named: "Test", kcal: "100", kohlenhydrate: "100", protein: "100", fett: "10")
        let foodItems = getAllFoodItems()
        XCTAssertTrue(foodItems.count == 1)
        
    }
    
    func testThatWeHaveAllFoodItems() {
        
        sut.loadDefaults(self)
        let fetchRequest = NSFetchRequest(entityName: "FoodItem")
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [nameSort]
        let foodItems = try!managedObjectContext.executeFetchRequest(fetchRequest) as! [FoodItem]
        XCTAssertTrue(foodItems.count > 0)
        
    }


    
    func testThatFirstItemInSectionGetsSortOrderZero() {
        XCTAssertEqual(sut.getLastSortOrderForSection(0), 0)
    }
    
    func testThatSecondItemInSectionGetsSortOrderOne() {
        createFoodEntry(inSection: 0)
        XCTAssertEqual(sut.getLastSortOrderForSection(0), 1)
    }
    
    func testThatSortOrderWorks() {
        let foodEntry1 = createFoodEntry(inSection: 0, unit: nil, amount: "10", foodItem: nil)
        foodEntry1.sortOrder = NSNumber(integer: 0)
        let foodEntry2 =  createFoodEntry(inSection: 0, unit: nil, amount: "20", foodItem: nil)
        foodEntry2.sortOrder = NSNumber(integer: 1)
        sut.fetch()
        let result = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertEqual(result.amount, "10")
    }
    
    func testThatFoodEntryFrühstück1HasCorrectValues() {
        sut.loadDefaults(self)
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,"35")
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "Kölln - Köln Flocken")
    }

    func testThatFoodEntryFrühstück2HasCorrectValues() {
        sut.loadDefaults(self)
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,"35")
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "Hy-Pro 85 Vanille")
    }
    
    func testThatFoodEntryFrühstück3HasCorrectValues() {
        sut.loadDefaults(self)
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,"100")
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "Heidelbeeren TK")
    }
    
    func testThatFoodEntry2Frühstück1HasCorrectValues() {
        sut.loadDefaults(self)
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,"30")
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "Nusskernmischung Seeberger")
    }
    
    func testThatFoodEntry2Frühstück2HasCorrectValues() {
        sut.loadDefaults(self)
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,"30")
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "Körniger Frischkäse Fitline 0.8%")
    }
    
    func testThatFoodEntryMittag1HasCorrectValues() {
        sut.loadDefaults(self)
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 2)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,"200")
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "Hänchenbrust Filet")
    }
    
    func testThatFoodEntryPWS1HasCorrectValues() {
        sut.loadDefaults(self)
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 3)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,"40")
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "ESN Designer Whey Vanille")
    }
    
    func testThatFoodEntryAbendbrot1HasCorrectValues() {
        sut.loadDefaults(self)
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 4)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,"8")
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "Bertolli Olivenöl")
    }
    
    func testThatFoodEntryAbendbrot2HasCorrectValues() {
        sut.loadDefaults(self)
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 1, inSection: 4)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,"8")
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "Seeberger milde Pinienkerne")
    }
    
    func testThatFoodEntryAbendbrot3HasCorrectValues() {
        sut.loadDefaults(self)
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 2, inSection: 4)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,"60")
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "Harry Ciabatta")
    }
    
    func testThatFoodEntryNachtisch1HasCorrectValues() {
        sut.loadDefaults(self)
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 5)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,"40")
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "Weider Casein")
    }
    
    func sutInitView() {
        let _ = sut.view
    }
    func testThatSectionsHaveAddEntry() {
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 1)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 1), 1)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 2), 1)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 3), 1)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 4), 1)
    }
    
    func testThatAddEntryOnyShowsWhenNotEditMode() {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        sut.editMode = false
        XCTAssertTrue(sut.tableView(sut.tableView, editingStyleForRowAtIndexPath: indexPath) == UITableViewCellEditingStyle.Insert)
        sut.editMode = true
        let editingStyle = sut.tableView(sut.tableView, editingStyleForRowAtIndexPath: indexPath)
        XCTAssertFalse(sut.tableView(sut.tableView, editingStyleForRowAtIndexPath: indexPath) == UITableViewCellEditingStyle.Insert)
    }
    
    func testThatCanMoveRowDoesNotAppearInNotEditMode() {
        createTwoFoodEntriesInSectionZero()
        sut.editMode = false
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        XCTAssertFalse(sut.tableView(sut.tableView, canMoveRowAtIndexPath: indexPath))

    }
    func testThatAddEntrySectionHasInsertAction() {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let _ = sut.view
        let editingStyle = sut.tableView(sut.tableView, editingStyleForRowAtIndexPath: indexPath)
        XCTAssertTrue(editingStyle == UITableViewCellEditingStyle.Insert)
    }
    
    func testThatTableStartsInEditingMode() {
        let _ = sut.view
        XCTAssertTrue(sut.tableView.editing)
    }
    
    func testThatTableStartsInEditModeFalse() {
        let _ = sut.view
        XCTAssertFalse(sut.editMode)
    }
    
    func testThatSelectingAddEntryPushesFoodItemsViewController() {
        
    }
    
    func testThatEintragHinzufügenDisappearsInEditMode() {
        
    }

    func testThatAllowsSelectionDuringEditingIsSet() {
        let _ = sut.view
        XCTAssertTrue(sut.tableView.allowsSelectionDuringEditing)
        
    }
    
    private func initSut() {
        let _ = sut.view
    }
    func testThatIndexPath00ContainsPlusSymbol() {
        initSut()
        let editingStyle = sut.tableView(sut.tableView, editingStyleForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertTrue(editingStyle == UITableViewCellEditingStyle.Insert)
    }
    
    func testThatSelectingDateUpdateViewControllersSelectedDateString() {
        let date = "01.01.16".toDateWithDayMonthYear()
        initSut()
        sut.calendar.selectDate(date)
        XCTAssertEqual(sut.selectedDateString, "01.01.16")
    }
    
    func DIStestThatSelectingDatePerformsFetchWithSelectedDate() {
        class JournalMock:JournalViewController {
            var dateString : String?
            private override func fetch(forDateString dateString: String? = nil) {
                self.dateString = dateString
            }
        }
        let sut = JournalMock()
        sut.calendar = DIDatepicker()
        sut.managedObjectContext = managedObjectContext
        let date = "01.01.16".toDateWithDayMonthYear()
        sut.calendar.selectDate(date)
         XCTAssertEqual(sut.dateString, "01.01.16")
        
    }
    
    let ZeroIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    func testThatFetchingForDateReturnsCorrectValue() {
        createFoodEntry(atDateString: "01.01.16")
        sut.selectedDateString = "01.01.16"
        initSut()
        XCTAssertTrue(sut.fetchedResultsController.hasObjectAtIndexPath(ZeroIndexPath))
        sut.selectedDateString = "02.01.16"
        sut.fetch()
        XCTAssertFalse(sut.fetchedResultsController.hasObjectAtIndexPath(ZeroIndexPath))
    }
    
    func testThatTestDataIsForDate010116() {
        sut.loadDefaults(self)
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! FoodEntry
        XCTAssertEqual(foodEntry.dateString,"22.02.16")
    }
    
    func testThatFoodItemKaloriesNotNil() {
        sut.loadDefaults(self)
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! FoodEntry
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.kcal,"361")
    }


}

