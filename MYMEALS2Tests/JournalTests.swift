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
    
    override func setUp()
    {
        super.setUp()
    
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewControllerWithIdentifier("JournalViewController") as! JournalViewController
        
        managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        store = try? storeCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
        sut.managedObjectContext = managedObjectContext
        sut.selectedDateString = "22.02.16"
    }
    
    override func tearDown()
    {
        super.tearDown()
        managedObjectContext = nil
    }
    
    // MARK: - UITableView Tests
    
    func testThatTableViewHasDataSource()
    {
        XCTAssertNotNil(sut.tableView)
        XCTAssertNotNil(sut.tableView.dataSource)
        XCTAssertNotNil(sut.tableView.delegate)
    }
    
    func testThatgetNumberOfFoodEntriesInSection()
    {
        sut.loadDefaults()
        XCTAssertEqual(sut.getNumberOfFoodEntries(inSection: 0), 3)
        XCTAssertEqual(sut.getNumberOfFoodEntries(inSection: 1), 2)
        XCTAssertEqual(sut.getNumberOfFoodEntries(inSection: 2), 1)
        XCTAssertEqual(sut.getNumberOfFoodEntries(inSection: 3), 1)
    }
    
    // MARK: - Anforderung 1 (Verschieben von Einträgen)
    
    // http://lattejed.com/a-simple-todo-app-in-swift
    
    func testThatAddEntryRowCanNotBeMovedOnEmptySection()
    {
        sut.editMode = true
        initSut()
        XCTAssertFalse(sut.tableView(sut.tableView, canMoveRowAtIndexPath: ZeroIndexPath))
    }

   
    
    func testThatAddEntryRowCanNotBeMovedOnNotEmptySection()
    {
        createSampleFoodEntry()
        sut.editMode = true
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        sut.selectedDateString = todayDateString
        XCTAssertTrue(sut.tableView(sut.tableView, canMoveRowAtIndexPath: ZeroIndexPath))
        XCTAssertFalse(sut.tableView(sut.tableView, canMoveRowAtIndexPath: indexPath))
    }
    
    func testThatMovingEntryChangesSortOrder()
    {
        
        let entryAt0 = CoreDataHelper.addFoodEntry(dateString: todayDateString, inSection: 0, inManagedObjectContext: managedObjectContext)
        let entryAt1 = CoreDataHelper.addFoodEntry(dateString: todayDateString, inSection: 0, inManagedObjectContext: managedObjectContext)
        let startIndexPath = NSIndexPath(forRow: 1, inSection: 0)
        let endIndexPath = ZeroIndexPath
        
        XCTAssertEqual(entryAt0.sortOrder, NSNumber(integer: 1))
        XCTAssertEqual(entryAt1.sortOrder, NSNumber(integer: 2))
        
        sut.tableView(sut.tableView, moveRowAtIndexPath: startIndexPath, toIndexPath: endIndexPath)
        
        XCTAssertEqual(entryAt0.sortOrder, NSNumber(integer: 2))
        XCTAssertEqual(entryAt1.sortOrder, NSNumber(integer: 1))
    }


    private func getFoodItemInFoodEntryTable(atIndexPath indexPatch: NSIndexPath)  -> FoodItem
    {
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(indexPatch) as! FoodEntry
        return foodEntry.foodItemRel! as FoodItem
    }
    
   
    func testThatMovingExampleDataChangesSortOrder() {
        
        sut.loadDefaults()
        let startIndexPath = NSIndexPath(forRow: 2, inSection: 0)
        let endIndexPath = NSIndexPath(forRow: 1, inSection: 0)

        XCTAssertEqual(getFoodItemInFoodEntryTable(atIndexPath: startIndexPath).name, "Heidelbeeren TK")

        sut.tableView(sut.tableView, moveRowAtIndexPath: startIndexPath, toIndexPath: endIndexPath)
        
        XCTAssertEqual(getFoodItemInFoodEntryTable(atIndexPath: endIndexPath).name, "Heidelbeeren TK")
    }
    
    func testThatMovingOntoAddSectionIsInhibited()
    {
        sut.loadDefaults()
        let startIndexPath = NSIndexPath(forRow: 2, inSection: 0)
        let endIndexPath = NSIndexPath(forRow: 3, inSection: 0)
        
        XCTAssertEqual(getFoodItemInFoodEntryTable(atIndexPath: startIndexPath).name, "Heidelbeeren TK")
        
        sut.tableView(sut.tableView, moveRowAtIndexPath: startIndexPath, toIndexPath: endIndexPath)

        XCTAssertEqual(getFoodItemInFoodEntryTable(atIndexPath: startIndexPath).name, "Heidelbeeren TK")
    }
    
    func testThatMovingExampleAcrossSection()
    {
        sut.loadDefaults()
        let startIndexPath = NSIndexPath(forRow: 2, inSection: 0)
        let endIndexPath = NSIndexPath(forRow: 1, inSection: 1)
        
        XCTAssertEqual(getFoodItemInFoodEntryTable(atIndexPath: startIndexPath).name, "Heidelbeeren TK")
        
        sut.tableView(sut.tableView, moveRowAtIndexPath: startIndexPath, toIndexPath: endIndexPath)
        
        XCTAssertEqual(getFoodItemInFoodEntryTable(atIndexPath: endIndexPath).name, "Heidelbeeren TK")
    }
    
    // MARK: - Anforderung 2 (Im EditMode können Einträge gelöscht werden)
    
    func testThatCallsCanCommitEditingStyleDelete() {
        createTwoFoodEntriesInSectionZero()

        XCTAssertTrue(sut.tableView(sut.tableView, canEditRowAtIndexPath: ZeroIndexPath))
        sut.editMode = true
        XCTAssertTrue(sut.tableView(sut.tableView, editingStyleForRowAtIndexPath: ZeroIndexPath) == .Delete)
    }
    
    
    func testThatCellsCanBeDeleted()
    {
        createTwoFoodEntriesInSectionZero()
        sut.editMode = true
        
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0),2,"There should be two row in this test")

        sut.tableView(sut.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))

        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0),1,"There should be one row in this test")
    }
    
    func testThatCellsCannotCommitEditingStyleDeleteInEditModeFalse()
    {
        createTwoFoodEntriesInSectionZero()
        
        XCTAssertTrue(sut.tableView(sut.tableView, canEditRowAtIndexPath: ZeroIndexPath))
        sut.editMode = false
        XCTAssertFalse(sut.tableView(sut.tableView, editingStyleForRowAtIndexPath: ZeroIndexPath) == .Delete)
    }

    private func getTotalNumberOfFoodEntries() -> Int {
        return sut.fetchedResultsController.fetchedObjects!.count
    }
    


    func testThatAllEntriesInOneSectionCanBeDeleted()
    {
        
        sut.fetch()
        sut.editMode = false
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 1)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 1), 1)

        createTwoFoodEntriesInSectionZero()
        
        sut.fetch()
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 3)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 1), 1)

        sut.tableView(sut.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        
        sut.fetch()
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 2)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 1), 1)
        
        sut.editMode = true
        
        sut.fetch()
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 1)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 1), 0)
    }

 


    func testThatDefaultValuesAreCorrectlyInSections() {
        sut.loadDefaults()
        sut.editMode = true
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 3)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 1), 2)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 2), 1)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 3), 1)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 4), 3)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 5), 1)
        
        XCTAssertEqual(getTotalNumberOfFoodEntries(), 11)
    }
    
    func testThatDeletinginFirstSectionRemovesOneEntryInFirstSectionOnly() {
        sut.loadDefaults()
        sut.editMode = true
        sut.tableView(sut.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 2)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 1), 2)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 2), 1)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 3), 1)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 4), 3)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 5), 1)
        
        XCTAssertEqual(getTotalNumberOfFoodEntries(), 10)
    }
    
    func testThatDeletingTWOinFirstSectionRemovesOneEntryInFirstSectionOnly() {
        sut.loadDefaults()
        sut.editMode = true
        sut.tableView(sut.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        sut.tableView(sut.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 1)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 1), 2)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 2), 1)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 3), 1)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 4), 3)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 5), 1)
        
        XCTAssertEqual(getTotalNumberOfFoodEntries(), 9)
    }
    
    func testThatAllEntriesInSectionZeroCanBeDeleted() {
        sut.loadDefaults()
        sut.editMode = true
        sut.tableView(sut.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        sut.tableView(sut.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        sut.tableView(sut.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
    
        XCTAssertEqual(getTotalNumberOfFoodEntries(), 8)

        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 0)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 1), 2)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 2), 1)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 3), 1)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 4), 3)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 5), 1)
        
        
        // Problem erkannt:
        
        // Ich darf die Sections nicht aus der CoreDatenbank löschen. Es muss immer ergebnisse für die Section geben. 
        // Es gibt ja keine leeren Sections. dann würde einfach die darauffolgende Nachrücken!
        // Wir müssen sagen: Wenn es section nicht gibt, dann gib nur zurück. Ich habe aber nur die Gesamtzahld er Seciton uns weiß nicht, ob 2 oder 3 oder 1 "fehlt". Ich weiß NUR, dass ich 5 statt 6 sections habe!
    }

    // MARK: - Anforderung 3 (Im EditMode können keine Einträge hinzugefügt werden)
    
    func testThatInEditingModeAddRowDisappears()
    {
        createTwoFoodEntriesInSectionZero()
        
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 3)
        sut.editMode = true
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 2)
        
    }
    
    // MARK: - Anforderung 4 (Es gibt SummaryLabels KCAL, KH, PROTEIN und FETT in HelveticaNeue-Light 12)
    
    func testThatViewContainsTotalCaloriesLabel()
    {
        initSut()
        XCTAssertNotNil(sut.totalCaloriesLabel)
    }
    
    func testThatViewContainsTotalCarbsLabel()
    {
        initSut()
        XCTAssertNotNil(sut.totalCarbLabel)
    }
    
    func testThatViewContainsTotalProteinLabel()
    {
        initSut()
        XCTAssertNotNil(sut.totalProteinLabel)
    }
    
    func testThatViewContainsTotalFatsLabel()
    {
        initSut()
        XCTAssertNotNil(sut.totalFatLabel)
    }
    
    func testThatTotalCaloriesLabelHasCorrectText()
    {
        initSut()
        XCTAssertEqual(sut.totalCaloriesLabel.text,"Kalorien")
    }
    
    func testThatTotalCarbLabelHasCorrectText()
    {
        initSut()
        XCTAssertEqual(sut.totalCarbLabel.text,"KH")
    }
    
    func testThatTotalProteinLabelHasCorrectText()
    {
        initSut()
        XCTAssertEqual(sut.totalProteinLabel.text,"Protein")
    }
    
    func testThatTotalFatLabelHasCorrectText()
    {
        initSut()
        XCTAssertEqual(sut.totalFatLabel.text,"Fett")
    }
    
    func testThatTotalLabelHasCorrectFont()
    {
        initSut()
        XCTAssertEqual(sut.totalCaloriesLabel.font, UIFont.customSummaryLabels())
        XCTAssertEqual(sut.totalCarbLabel.font, UIFont.customSummaryLabels())
        XCTAssertEqual(sut.totalProteinLabel.font, UIFont.customSummaryLabels())
        XCTAssertEqual(sut.totalFatLabel.font, UIFont.customSummaryLabels())
    }
    
    
    // MARK: Anforderung 5: Über den Summary Labels wird die Summe der Tageswerte angezeigt in HelveticaNeue-Light 12, Farbe 000000
    
    func testThatTotalValueFieldsExists()
    {
        initSut()
        XCTAssertNotNil(sut.totalCaloriesValue)
        XCTAssertNotNil(sut.totalCarbValue)
        XCTAssertNotNil(sut.totalProteinValue)
        XCTAssertNotNil(sut.totalFatValue)
    }
    
    func testThatTotalValuesHaveCorrectFont()
    {
        initSut()
        XCTAssertEqual(sut.totalCaloriesValue.font, UIFont.customSummaryValues())
        XCTAssertEqual(sut.totalCarbValue.font, UIFont.customSummaryValues())
        XCTAssertEqual(sut.totalProteinValue.font, UIFont.customSummaryValues())
        XCTAssertEqual(sut.totalFatValue.font, UIFont.customSummaryValues())

    }
    
    private func initAndLoad()
    {
        initSut()
        sut.loadDefaults()
        sut.selectedDateString = todayDateString
    }
    func testThatTotalCalorieValueIsCorrect()
    {
        initAndLoad()
        XCTAssertEqual(sut.totalCaloriesValue.text,"1267")
    }
    
    func testThatTotalCarbsValueIsCorrect()
    {
        initAndLoad()
        XCTAssertEqual(sut.totalCarbValue.text,"4")
    }
    
    func testThatTotalProteinsValueIsCorrect()
    {
        initAndLoad()
        XCTAssertEqual(sut.totalProteinValue.text,"123")
    }
    
    // MARK: Debug Test that we might not need
    
    func testThatCarbsAndProteinsAreShownInCell()
    {
        createSampleFoodEntry()
        initSut()
        sut.tableView.reloadData()
        let cell = sut.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! JournalCell
        let name = cell.details?.text
        XCTAssertEqual(name,"KH: 5g, Protein: 20g, Fett: 4g","Cell should return formatted content.")
    }
    
    // MARK: other Tests
    
    // TODO ARBEITE MEHR MIT OBSERVERN, DAMIT SICH ZUM BEISPIEL DIE SUMMENZEILE AUTOMATISCH AKTUALISIERT
    // TODO AU?ERDEM GIBT ES UNSAUBERKEINTEN IN TDER HELPER METHODE COREDATA

    
    func testThatOneFoodEntryReturnsOneRow()
    {
        createSampleFoodEntry()
        sut.selectedDateString = todayDateString
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0),2,"There should be one two Rows (add Item) in this test")
    }
    

    func testThatTwoFoodEntrysReturnTwoRows()
    {
        createTwoFoodEntriesInSectionZero()
        initSut()
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0),3,"There should be one row in this test")
    }
    
    private func createSampleFoodEntry()
    {
        CoreDataHelper.createFoodItem(name: "TestName", kcal: "150", carbs: "10", protein: "40", fat: "8", inManagedObjectContext: managedObjectContext)
        CoreDataHelper.addFoodEntry(dateString: todayDateString, inSection: 0, amount: 50, unit: "g",  withFoodItemNamed: "TestName", inManagedObjectContext: managedObjectContext)
        
    }

    func testThatTableViewCellReturnsNameUnitOfFoodItem()
    {
        createSampleFoodEntry()
        initSut()
        sut.tableView.reloadData()
        let cell = sut.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! JournalCell
        let name = cell.name.text
        XCTAssertEqual(name,"TestName 50g","Cell should return formatted content.")
    }
    
    func testThatTableViewCellReturnsCaloriesOfFoodItem()
    {
        createSampleFoodEntry()
        initSut()
        sut.tableView.reloadData()
        let cell = sut.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! JournalCell
        let name = cell.kcal.text
        XCTAssertEqual(name,"75 kcal","Cell should return formatted content.")
    }
    
    // TODO How to we test presenting a viewcontroller?
/* ViewController gets presented.
    func testThatTableViewCellInLastSectionPushesAddEntry()
    {
        createTwoFoodEntriesInTwoSections()
        let navController = initSutWithNavigationController()
        XCTAssertTrue(navController.viewControllers.count == 1, "Should push viewcontroller")
        sut.tableView(sut.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2))
        XCTAssertTrue(navController.viewControllers.count == 1, "Should present viewcontroller")
        XCTAssertNotNil((navController.topViewController as? FoodItemsViewController)?.managedObjectContext, "Should set MOC")
    }
    
    func testThatSelectionPlusSymbolAddsEntry()
    {
        createTwoFoodEntriesInTwoSections()
        let navController = initSutWithNavigationController()
        XCTAssertTrue(navController.viewControllers.count == 1, "Should push viewcontroller")
        
        let indexPath =  NSIndexPath(forRow: 0, inSection: 2)
        sut.tableView(sut.tableView, commitEditingStyle: .Insert, forRowAtIndexPath: indexPath)
        XCTAssertTrue(navController.viewControllers.count == 2, "Should push viewcontroller")
        
        XCTAssertNotNil((navController.viewControllers.last as? FoodItemsViewController)?.managedObjectContext, "Should set MOC")
    }
*/
    func testThatTableViewhasEditButton()
    {
        initSut()
        XCTAssertNotNil(sut.navigationItem.rightBarButtonItem, "There should be a button")
    }
    
    func testThatTableViewsEditButtonHasEditAction()
    {
        initSut()
        XCTAssertEqual(sut.navigationItem.rightBarButtonItem?.action.description, "edit:","We should have an edit button")
    }

    func testThatTableViewCanBeSetIntoEditingMode()
    {
        initSut()
        sut.edit(UIBarButtonItem())
        XCTAssertTrue(sut.editMode, "TableView Should now be in editing mode.")
    }
    

    


    

    
    private func navigationControllerWithSut() -> UINavigationController
    {
        let navController = UINavigationController()
        navController.viewControllers = [sut]
        return navController
    }
    
    func testThatSelectingAnEntryInEditModePushesEditEntry() {
        let navController = navigationControllerWithSut()
        createTwoFoodEntriesInTwoSections()
        initSut()
        
        // TODO uses editing! That is FALSCH
        sut.editing = true
        XCTAssertTrue(navController.viewControllers.count == 1, "Should be only one viewcontroller")
        sut.tableView(sut.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        
        XCTAssertTrue(navController.viewControllers.count == 2, "Should push viewcontroller")
    }
    
    func testThatSelectingAnEntryInNotEditModePushesShowEntry()
    {
        let navController = navigationControllerWithSut()
        createTwoFoodEntriesInTwoSections()
        initSut()
        sut.editing = false
        
        XCTAssertTrue(navController.viewControllers.count == 1, "Should be only one viewcontroller")
        sut.tableView(sut.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        
        XCTAssertTrue(navController.viewControllers.count == 2, "Should push viewcontroller")
    }
    
    private func createTestFoodEntryWithAmount(amount:Double) -> FoodEntry
    {
        return CoreDataHelper.addFoodEntry(dateString: todayDateString, inSection: 0, amount: amount, unit: "g", withFoodItemNamed: "Test", inManagedObjectContext: managedObjectContext)

    }
    
    
    
    func testThatFooterContainsSumOfCalories()
    {
        CoreDataHelper.createFoodItem(name: "Test", kcal: "100", inManagedObjectContext: managedObjectContext)
        createTestFoodEntryWithAmount(80)
        createTestFoodEntryWithAmount(90)
        initSut()
        let footer = sut.tableView(sut.tableView, titleForFooterInSection:  0)
        XCTAssertEqual(footer,"Summe: 170 kcal", "Summe: 170 kcal should be footer of first section")
    }
    
    func testThatFooterCopesWithNilValues()
    {
        CoreDataHelper.createFoodItem(name: nil, kcal: "100", inManagedObjectContext: managedObjectContext)
        createTestFoodEntryWithAmount(0)
        createTestFoodEntryWithAmount(0)
        initSut()
        let footer = sut.tableView(sut.tableView, titleForFooterInSection:  0)
        XCTAssertEqual(footer,"Summe: 0 kcal", "Summe: 0 kcal should be footer of first section")
    }
    
    func testThatViewControllerHasTitle()
    {
        initSut()
        XCTAssertEqual(sut.navigationItem.title, "Ernährungs-Tagebuch","Titel vom Viewcontroller should be Ernährungs-Tagebuch")
    }
    
    func testThatCalendarIsConnected()
    {
        initSut()
        XCTAssertNotNil(sut.calendar, "Calendar View Should not be nil.")
    }
    
    func testThatCalendarViewIsOfTypeDIDatepicker()
    {
        initSut()
        XCTAssertTrue(sut.calendar.isKindOfClass(DIDatepicker))
    }
    
    private func titleInSection(section: Int) -> String
    {
        return sut.tableView(sut.tableView, titleForHeaderInSection: section)!
    }
    
    func testThatFirstSectionContaisFrühstück()
    {
        XCTAssertEqual(titleInSection(0),"Frühstück","First Section should contain Frühstück")
    }
    
    func testThatFirstSectionContaisZweitesFrühstück()
    {
        XCTAssertEqual(titleInSection(1),"2. Frühstück","First Section should contain 2. Frühstück")
    }
    
    func testThatFirstSectionContaisMittagessen()
    {
        XCTAssertEqual(titleInSection(2),"Mittagessen","First Section should contain Mittagessen")
    }
    
    func testThatFirstSectionContaispostworkoutShaje()
    {
        XCTAssertEqual(titleInSection(3),"Post-Workout-Shake","First Section should contain PostworkoutShake")
    }
    
    func testThatFirstSectionContainsAbendbrot()
    {
        XCTAssertEqual(titleInSection(4),"Abendbrot","First Section should contain Abendbrot")
    }
    
    func testThatFirstSectionContainsNachtisch()
    {
        XCTAssertEqual(titleInSection(5),"Nachtisch","First Section should contain Nachtisch")
    }
    
    private func initSutWithNavigationController() ->  UINavigationController
    {
        let navigationController = UINavigationController()
        navigationController.viewControllers = [sut]
        initSut()
        return navigationController
    }

    
    func testThatButtomLineExists() {
        let navigationController = initSutWithNavigationController()
        XCTAssertFalse(navigationController.toolbarHidden, "Show Toolbar")
    }
    
    private func initSutWithNavigationControllerAndGetButton() -> UIBarButtonItem
    {
        initSutWithNavigationController()
        let button = sut.toolbarItems!.first! as UIBarButtonItem
        return button
    }
    
    func testThatToolbarButtonHasTitle()
    {
        let button = initSutWithNavigationControllerAndGetButton()
        XCTAssertEqual(button.title, "Load Default", "There should be one Button in Toolbar with title Load Default")
    }
    
    func testThatToolbarButtonHasAction()
    {
        let button = initSutWithNavigationControllerAndGetButton()
        XCTAssertEqual(button.action.description, "loadDefaults", "There should be one Button in Toolbar with action Load Default")
    }
    
    private func getAllFoodItems() -> [FoodItem]
    {
        return CoreDataHelper.getAllFoodItems(inManagedObjectContext: managedObjectContext)
    }
    
    func testThatFoodItemsCanBeCreated()
    {
        sut.addFoodItem(named: "Test", kcal: "100", carbs: "100", protein: "100", fett: "10")
        let foodItems = getAllFoodItems()
        let foodItem = foodItems.first
        XCTAssertEqual(foodItem?.name, "Test")
        XCTAssertEqual(foodItem?.carbs, "100")
        XCTAssertEqual(foodItem?.protein, "100")
        XCTAssertEqual(foodItem?.fett, "10")
        
    }
    
    func testThatNoDublicateFoodItemsCanBeCreated()
    {
        
        sut.addFoodItem(named: "Test", kcal: "100", carbs: "100", protein: "100", fett: "10")
        sut.addFoodItem(named: "Test", kcal: "100", carbs: "100", protein: "100", fett: "10")
        let foodItems = getAllFoodItems()
        XCTAssertTrue(foodItems.count == 1)
        
    }
    
    func testThatWeHaveAllFoodItems()
    {
        sut.loadDefaults()
        let fetchRequest = NSFetchRequest(entityName: "FoodItem")
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [nameSort]
        let foodItems = try!managedObjectContext.executeFetchRequest(fetchRequest) as! [FoodItem]
        XCTAssertTrue(foodItems.count > 0)
        
    }


    
    func testThatFirstItemInSectionGetsSortOrderZero()
    {
        XCTAssertEqual(CoreDataHelper.getLastEntry(dateString: todayDateString, inSection: 0, inManagedObjectContext: managedObjectContext),0)
    }
    
    
    func testThatSecondItemInSectionGetsSortOrderOne() {
        createSampleFoodEntry()
        XCTAssertEqual(CoreDataHelper.getLastEntry(dateString: todayDateString, inSection: 0, inManagedObjectContext: managedObjectContext),1)
    }
    
    func testThatSortOrderWorks()
    {
        let foodEntry1 = createTestFoodEntryWithAmount(10)
        
        foodEntry1.sortOrder = NSNumber(integer: 0)
        let foodEntry2 =  createTestFoodEntryWithAmount(20)
        foodEntry2.sortOrder = NSNumber(integer: 1)
        sut.fetch()
        let result = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertEqual(result.amount, 10)
    }
    
    func testThatFoodEntryFrühstück1HasCorrectValues()
    {
        sut.loadDefaults()
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,35)
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "Kölln - Köln Flocken")
    }

    func testThatFoodEntryFrühstück2HasCorrectValues()
    {
        sut.loadDefaults()
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,35)
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "Hy-Pro 85 Vanille")
    }
    
    func testThatFoodEntryFrühstück3HasCorrectValues()
    {
        sut.loadDefaults()
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,100)
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "Heidelbeeren TK")
    }
    
    func testThatFoodEntry2Frühstück1HasCorrectValues()
    {
        sut.loadDefaults()
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,30)
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "Nusskernmischung Seeberger")
    }
    
    func testThatFoodEntry2Frühstück2HasCorrectValues()
    {
        sut.loadDefaults()
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,30)
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "Körniger Frischkäse Fitline 0,8%")
    }
    
    func testThatFoodEntryMittag1HasCorrectValues()
    {
        sut.loadDefaults()
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 2)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,200)
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "Hänchenbrust Filet")
    }
    
    func testThatFoodEntryPWS1HasCorrectValues()
    {
        sut.loadDefaults()
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 3)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,40)
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "ESN Designer Whey Vanille")
    }
    
    func testThatFoodEntryAbendbrot1HasCorrectValues()
    {
        sut.loadDefaults()
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 4)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,8)
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "Bertolli Olivenöl")
    }
    
    func testThatFoodEntryAbendbrot2HasCorrectValues()
    {
        sut.loadDefaults()
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 1, inSection: 4)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,8)
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "Seeberger milde Pinienkerne")
    }
    
    func testThatFoodEntryAbendbrot3HasCorrectValues()
    {
        sut.loadDefaults()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 2, inSection: 4)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,60)
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "Harry Ciabatta")
    }
    
    func testThatFoodEntryNachtisch1HasCorrectValues()
    {
        sut.loadDefaults()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 5)) as! FoodEntry
        XCTAssertEqual(foodEntry.amount,40)
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.name, "Weider Casein")
    }
    
    func initSut() {
        let _ = sut.view
    }
    func testThatSectionsHaveAddEntry()
    {
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 1)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 1), 1)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 2), 1)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 3), 1)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 4), 1)
    }
    
    func testThatAddEntryOnyShowsWhenNotEditMode()
    {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        sut.editMode = false
        XCTAssertTrue(sut.tableView(sut.tableView, editingStyleForRowAtIndexPath: indexPath) == UITableViewCellEditingStyle.Insert)
        sut.editMode = true
        XCTAssertFalse(sut.tableView(sut.tableView, editingStyleForRowAtIndexPath: indexPath) == UITableViewCellEditingStyle.Insert)
    }
    
    func testThatCanMoveRowDoesNotAppearInNotEditMode()
    {
        createTwoFoodEntriesInSectionZero()
        sut.editMode = false
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        
        XCTAssertFalse(sut.tableView(sut.tableView, canMoveRowAtIndexPath: indexPath))

    }
    func testThatAddEntrySectionHasInsertAction()
    {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        initSut()
        let editingStyle = sut.tableView(sut.tableView, editingStyleForRowAtIndexPath: indexPath)
        
        XCTAssertTrue(editingStyle == UITableViewCellEditingStyle.Insert)
    }
    
    func testThatTableStartsInEditingMode()
    {
        initSut()
        XCTAssertTrue(sut.tableView.editing)
    }
    
    func testThatTableStartsInEditModeFalse()
    {
        initSut()
        XCTAssertFalse(sut.editMode)
    }
    
    func testThatSelectingAddEntryPushesFoodItemsViewController()
    {
        
    }
    
    func testThatEintragHinzufügenDisappearsInEditMode()
    {
        
    }

    func testThatAllowsSelectionDuringEditingIsSet()
    {
        initSut()
        XCTAssertTrue(sut.tableView.allowsSelectionDuringEditing)
        
    }
    

    func testThatIndexPath00ContainsPlusSymbol()
    {
        initSut()
        let editingStyle = sut.tableView(sut.tableView, editingStyleForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertTrue(editingStyle == UITableViewCellEditingStyle.Insert)
    }
    
    func testThatSelectingDateUpdateViewControllersSelectedDateString()
    {
        let date = "01.01.16".toDateWithDayMonthYear()
        initSut()
        sut.calendar.selectDate(date)
        XCTAssertEqual(sut.selectedDateString, "01.01.16")
    }
    
    func DIStestThatSelectingDatePerformsFetchWithSelectedDate() {
        class JournalMock:JournalViewController
        {
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
    
    
    func testThatFetchingForDateReturnsCorrectValue()
    {
        createSampleFoodEntry()
        sut.selectedDateString = todayDateString
        initSut()
        XCTAssertTrue(sut.fetchedResultsController.hasObjectAtIndexPath(ZeroIndexPath))
        sut.selectedDateString = "02.01.16"
        sut.fetch()
        XCTAssertFalse(sut.fetchedResultsController.hasObjectAtIndexPath(ZeroIndexPath))
    }
    
    func testThatTestDataIsForDate010116()
    {
        sut.loadDefaults()
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! FoodEntry
        XCTAssertEqual(foodEntry.dateString,todayDateString)
    }
    
    func testThatFoodItemKaloriesNotNil()
    {
        sut.loadDefaults()
        sut.fetch()
        let foodEntry = sut.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! FoodEntry
        let foodItem = foodEntry.foodItemRel! as FoodItem
        XCTAssertEqual(foodItem.kcal,"361")
    }
    
    // MARK: - Helper Methods
    
    private func createTwoFoodEntriesInTwoSections()
    {
        CoreDataHelper.addFoodEntry(dateString: todayDateString, inSection: 0, inManagedObjectContext: managedObjectContext)
        CoreDataHelper.addFoodEntry(dateString: todayDateString, inSection: 1, inManagedObjectContext: managedObjectContext)
        
        
    }
    
    private func createTwoFoodEntriesInSectionZero()
    {
        CoreDataHelper.addFoodEntry(dateString: todayDateString, inSection: 0, inManagedObjectContext: managedObjectContext)
        CoreDataHelper.addFoodEntry(dateString: todayDateString, inSection: 0, inManagedObjectContext: managedObjectContext)
    }
    
    
    // MARK: Anforderung: 12 Beim Hinzufügen eines Items wird ein FoodEntry in der Datenbank angelegt. FoodSelection ViewController arbeitet über ein Protocoll. Wird Kein Eintrag zurückgegeben. Wird der angelegte FoodEntry vom FoodSelection Viewcontroller gelöscht.
    
    func testThatfoodEntryIsCreatedWhenSelectionAddEntry()
    {
        sut.selectedDateString = "01.01.15"
        sut.addEntry(0)
        XCTAssertEqual(CoreDataHelper.getFoodEntries(forDateString: "01.01.15", inmanagedObjectContext: managedObjectContext).count, 1)
    }
    
    func testThatSectionGetsTransferredToAddEntry()
    {
        /*
        class sutMock: JournalViewController
        {
            var section = 0
            private override func addEntry(section: Int) {
                section = section
            }
        }
        let sut = sutMock()
        */
        sut.selectedDateString = "01.01.15"
        sut.tableView(sut.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
        XCTAssertEqual(sut.selectedSection, 1)
    }

    // MARK: Delegation Stuff
    
    
    func testThatJournalSetsItselfAsDelegateToFoodItems()
    {
        //CoreDataHelper.createFoodItem(inManagedObjectContext: managedObjectContext)
        //sut.tableView(sut.tableView, didSelectRowAtIndexPath: ZeroIndexPath)
        sut.addEntry(0)
        //AppDelegate().window?.rootViewController.pr
    }
    
    func testThatJournalAddAmountDelegateDismissesViewController()
    {
        class sutMock:JournalViewController
        {
            var didCallDismissViewController = false
            private override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
                didCallDismissViewController = true
            }
            
        }
        let sut = sutMock()
        sut.calendar = DIDatepicker()
        sut.managedObjectContext = managedObjectContext
  //      sut.addAmountViewController(AddAmountViewController(), didAddAmount: FoodEntry())
  //      XCTAssertTrue(sut.didCallDismissViewController)
    }
}

