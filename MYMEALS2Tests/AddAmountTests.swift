//
//  AddAmountViewControllerTests.swift
//  MYMEALS2
//
//  Created by Marc Felden on 22.02.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import XCTest
import CoreData
@testable import MYMEALS2

class AddAmountViewControllerTests: XCTestCase
{
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var store: NSPersistentStore!
    var sut:AddAmountViewController!
    
    override func setUp()
    {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewControllerWithIdentifier("AddAmountViewController") as! AddAmountViewController
        managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        store = try? storeCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
        sut.managedObjectContext = managedObjectContext
        
        let foodItem = CoreDataHelper.createFoodItem(name: "Test Haferflocken", kcal: "100", carbs: "10", protein: "50", fat: "20", inManagedObjectContext: managedObjectContext)
        let foodEntry = CoreDataHelper.addFoodEntry(dateString: "01.01.15", inSection: 0, amount: 100, unit: "g", withFoodItemNamed: "Test Haferflocken", inManagedObjectContext: managedObjectContext)
        sut.foodItem = foodItem
        sut.foodEntry = foodEntry
    }
    
    override func tearDown()
    {
        super.tearDown()
        managedObjectContext = nil
    }
    
    private func initSut()
    {
        let _ = sut.view
    }
    
    // MARK: Anforderung 1: Seite enthält Cancel und Done Button.
    
    func testThatWeHaveDoneButton()
    {
        initSut()
        XCTAssertNotNil(sut.navigationItem.rightBarButtonItem)
    }
    
    // MARK: Anforderung 2: Seite enthält Food-Namen in Helvetica Grau 16 
    
    func testThatNameLabelIsConnected()
    {
        initSut()
        XCTAssertNotNil(sut.nameTextLabel)
    }
    
    func testThatnameLabelIsHelveticaFont()
    {
        initSut()
        XCTAssertEqual(sut.nameTextLabel.font, UIFont.customSummaryValues())
    }
    
    // MARK: Anforderung 3: Seite enthält 100g Nährwerte

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
    
    func testThatTotalLabelHaveCorrectTexts()
    {
        initSut()
        XCTAssertEqual(sut.totalCaloriesLabel.text,"Kalorien")
        XCTAssertEqual(sut.totalCarbLabel.text,"KH")
        XCTAssertEqual(sut.totalProteinLabel.text,"Protein")
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
    

    func testThatNameIsCorrect()
    {
        initSut()
        XCTAssertEqual(sut.nameTextLabel.text,"Test Haferflocken")
    }
    
    
    func testThatCaloriesValueIsCorrect()
    {
        initSut()
        XCTAssertEqual(sut.totalCaloriesValue.text,"100")
    }
    
    
    func testThatCarbsValueIsCorrect()
    {
        initSut()
        XCTAssertEqual(sut.totalCarbValue.text,"10")
    }
    
    func testThatProteinsValueIsCorrect()
    {
        initSut()
        XCTAssertEqual(sut.totalProteinValue.text,"50")
    }
    
    func testThatFatsValueIsCorrect()
    {
        initSut()
        XCTAssertEqual(sut.totalFatValue.text,"20")
    }

    
    func testThatDoneActionVerifiesEntry() {
        class Mock: AddAmountViewController {
            var someThingWasPresented = false
            private override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
                someThingWasPresented = true
            }
        }
        let sut = Mock()
        sut.amountTextField = UITextField()
        sut.amountTextField.text = ""
        sut.done(self)
        XCTAssertTrue(sut.someThingWasPresented)
        
    }
    
    private func dummyFoodEntry() -> FoodEntry
    {
        return CoreDataHelper.addFoodEntry(dateString: todayDateString, inSection: 0, inManagedObjectContext: managedObjectContext)
    }
    
    class dummyDelegate:AddAmountDelegate
    {
        var delegateWasCalled = false
        func addAmountViewController(addAmountViewController: AddAmountViewController, didAddAmount foodEntry: FoodEntry) {
            delegateWasCalled = true
        }
    }
    
    
    // TODO UNIT Auswahl ermöglichen.
    func testThatDoneAttachesAmountAndUnitToEntry()
    {
        let delegate = dummyDelegate()
        sut.amountTextField = UITextField()
        sut.amountTextField.text = "1234"
        sut.foodEntry = dummyFoodEntry()
        sut.delegate = delegate
        sut.done(self)
        XCTAssertEqual(sut.foodEntry.unit, "g")
        XCTAssertEqual(sut.foodEntry.amount, 1234)
    }
    
    // MARK: Anforderung 4.	Seite enthält zwei Sections Menge und Einheit.
    
    // nicht zu testen, da im Storyboard gesetzt?

    

}
