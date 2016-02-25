//
//  AddFootItemViewControllerTests.swift
//  MYMEALS2
//
//  Created by Marc Felden on 05.02.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import XCTest
import CoreData
@testable import MYMEALS2

class AddFoodItemViewControllerTests: XCTestCase {
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var store: NSPersistentStore!
    var sut:AddFoodItemViewController!
    
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewControllerWithIdentifier("AddFoodItemViewController") as! AddFoodItemViewController
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
    
    func testThatLeftBarButtonItemIsConnected() {
        let _ = sut.view
        XCTAssertNotNil(sut.navigationItem.leftBarButtonItem, "There should be a Cancel Button")
    }
    
    func testThatRightBarButtonItemIsConnected() {
        let _ = sut.view
        XCTAssertNotNil(sut.navigationItem.rightBarButtonItem, "There should be a Done Button")
    }
    
    func testThatLeftBarButtonItemHasAction() {
        let _ = sut.view
        XCTAssertEqual(sut.navigationItem.leftBarButtonItem?.action.description, "cancel:","Cancel Button should have cancel action")
    }
    
    func testThatRightBarButtonItemHasAction() {
        let _ = sut.view
        XCTAssertEqual(sut.navigationItem.rightBarButtonItem?.action.description, "done:","Done Button should have done action")
    }
    
    func testThatCancelActionDeletesItemInDatabase() {
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        try!foodItem.managedObjectContext?.save()
        let _ = sut.view
        let fetchRequest = NSFetchRequest(entityName: "FoodItem")

        let entityDescription = NSEntityDescription.entityForName("FoodItem", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entityDescription
        
        let result = try! self.managedObjectContext.executeFetchRequest(fetchRequest)

        XCTAssertTrue(result.count == 1, "Test")
        class mockDelegate:AddFoodItemDelegate {
            private func addFoodItemViewController(addFoodItemViewController: AddFoodItemViewController, didAddFoodItem foodItem: FoodItem?) {
                //
            }
        }
        sut.delegate = mockDelegate()
        sut.foodItem = foodItem
        sut.cancel(UIBarButtonItem())
        let result1 = try! self.managedObjectContext.executeFetchRequest(fetchRequest)
        XCTAssertTrue(result1.count == 0, "Test")
    }
    
    func testThatCancelActionDelegatesWithNilItem() {
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        try!foodItem.managedObjectContext?.save()
        let _ = sut.view
        class MockDelegate:AddFoodItemDelegate {
            var addFoodItemViewControllerHasBeenCalledReturningNilItem = false
            private func addFoodItemViewController(addFoodItemViewController: AddFoodItemViewController, didAddFoodItem foodItem: FoodItem?) {
                if foodItem == nil {
                    addFoodItemViewControllerHasBeenCalledReturningNilItem = true
                }
            }
        }
        let mockDelegate = MockDelegate()
        sut.delegate = mockDelegate
        sut.foodItem = foodItem
        sut.cancel(UIBarButtonItem())
        XCTAssertTrue(mockDelegate.addFoodItemViewControllerHasBeenCalledReturningNilItem, "The Cacncel Action should call method on delegate")
    }
    
    
    func testThatDoneActionVerifiesNameField() {
        class SutMock:AddFoodItemViewController {
            var actionViewControllerHasBeenCalled = false
            private override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
                if viewControllerToPresent.isKindOfClass(UIAlertController) {
                    actionViewControllerHasBeenCalled = true
                }
            }
        }
        let sut = SutMock()
        sut.managedObjectContext = managedObjectContext
        sut.foodItem = FoodItem(entity: NSEntityDescription.entityForName("FoodItem", inManagedObjectContext: managedObjectContext)!, insertIntoManagedObjectContext: managedObjectContext)
        sut.name = UITextField()
        sut.kcal = UITextField()
        sut.name.text = ""
        sut.done(UIBarButtonItem())
        XCTAssertTrue(sut.actionViewControllerHasBeenCalled, "The name field should contain a value should call method on delegate")
    }
    
    func testThatDoneActionVerifiesCalorieField() {
        class SutMock:AddFoodItemViewController {
            var actionViewControllerHasBeenCalled = false
            private override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
                if viewControllerToPresent.isKindOfClass(UIAlertController) {
                    actionViewControllerHasBeenCalled = true
                }
            }
        }
        let sut = SutMock()
        sut.managedObjectContext = managedObjectContext
        sut.foodItem = FoodItem(entity: NSEntityDescription.entityForName("FoodItem", inManagedObjectContext: managedObjectContext)!, insertIntoManagedObjectContext: managedObjectContext)
        sut.name = UITextField()
        sut.kcal = UITextField()
        sut.name.text = "Test"
        sut.kcal.text = ""
        sut.done(UIBarButtonItem())
        XCTAssertTrue(sut.actionViewControllerHasBeenCalled, "The Cacncel Action should call method on delegate")
    }
    
    func testThatNameFieldIsConnected() {
        let _ = sut.view
        XCTAssertNotNil(sut.name, "Name field should be connected")
    }
    func testThatCalorieFieldIsConnected() {
        let _ = sut.view
        XCTAssertNotNil(sut.kcal, "Calorie field should be connected")
    }
    func testThatCarbFieldIsConnected() {
        let _ = sut.view
        XCTAssertNotNil(sut.carbs, "carbs field should be connected")
    }
    func testThatProteinFieldIsConnected() {
        let _ = sut.view
        XCTAssertNotNil(sut.protein, "Protein field should be connected")
    }
    func testThatFatFieldIsConnected() {
        let _ = sut.view
        XCTAssertNotNil(sut.fat, "Fat field should be connected")
    }

    func testThatDoneActionVerifiesCarbField() {
        class SutMock:AddFoodItemViewController {
            var actionViewControllerHasBeenCalled = false
            private override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
                if viewControllerToPresent.isKindOfClass(UIAlertController) {
                    actionViewControllerHasBeenCalled = true
                }
            }
        }
        let sut = SutMock()
        sut.managedObjectContext = managedObjectContext
        sut.foodItem = FoodItem(entity: NSEntityDescription.entityForName("FoodItem", inManagedObjectContext: managedObjectContext)!, insertIntoManagedObjectContext: managedObjectContext)
        sut.name = UITextField()
        sut.kcal = UITextField()
        sut.carbs = UITextField()
        sut.kcal.text = "Test"
        sut.name.text = "Test"
        sut.carbs.text = ""
        sut.done(UIBarButtonItem())
        XCTAssertTrue(sut.actionViewControllerHasBeenCalled,"User must enter carbs")
    }
    func testThatDoneActionVerifiesProteinField() {
        class SutMock:AddFoodItemViewController {
            var actionViewControllerHasBeenCalled = false
            private override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
                if viewControllerToPresent.isKindOfClass(UIAlertController) {
                    actionViewControllerHasBeenCalled = true
                }
            }
        }
        let sut = SutMock()
        sut.managedObjectContext = managedObjectContext
        sut.foodItem = FoodItem(entity: NSEntityDescription.entityForName("FoodItem", inManagedObjectContext: managedObjectContext)!, insertIntoManagedObjectContext: managedObjectContext)
        sut.name = UITextField()
        sut.kcal = UITextField()
        sut.carbs = UITextField()
        sut.protein = UITextField()
        sut.carbs = UITextField()
        sut.kcal.text = "Test"
        sut.name.text = "Test"
        sut.carbs.text = "Test"
        sut.protein.text = ""
        sut.done(UIBarButtonItem())
        XCTAssertTrue(sut.actionViewControllerHasBeenCalled, "User must enter Protein")
    }
    
    func testThatDoneActionVerifiesFatField() {
        class SutMock:AddFoodItemViewController {
            var actionViewControllerHasBeenCalled = false
            private override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
                if viewControllerToPresent.isKindOfClass(UIAlertController) {
                    actionViewControllerHasBeenCalled = true
                }
            }
        }
        let sut = SutMock()
        sut.managedObjectContext = managedObjectContext
        sut.foodItem = FoodItem(entity: NSEntityDescription.entityForName("FoodItem", inManagedObjectContext: managedObjectContext)!, insertIntoManagedObjectContext: managedObjectContext)
        sut.name = UITextField()
        sut.kcal = UITextField()
        sut.carbs = UITextField()
        sut.protein = UITextField()
        sut.carbs = UITextField()
        sut.fat = UITextField()
        sut.kcal.text = "Test"
        sut.name.text = "Test"
        sut.carbs.text = "Test"
        sut.protein.text = "Test"
        sut.fat.text = ""
        sut.done(UIBarButtonItem())
        XCTAssertTrue(sut.actionViewControllerHasBeenCalled, "User must enter Fat")
    }
    
    func testThatDoneActionPutsAllValuesToItem() {
        class AddDelegate:AddFoodItemDelegate {
            var foodItem : FoodItem!
            private func addFoodItemViewController(addFoodItemViewController: AddFoodItemViewController, didAddFoodItem foodItem: FoodItem?) {
               // try!foodItem?.managedObjectContext?.save() ist nicht nötig, um den Test zu bestehen, weil du es im memory lässt.
                self.foodItem = foodItem!
            }
        }
        let delegate = AddDelegate()
        sut.managedObjectContext = managedObjectContext
        sut.delegate = delegate
        sut.foodItem = FoodItem(entity: NSEntityDescription.entityForName("FoodItem", inManagedObjectContext: managedObjectContext)!, insertIntoManagedObjectContext: managedObjectContext)
        sut.name = UITextField()
        sut.kcal = UITextField()
        sut.carbs = UITextField()
        sut.protein = UITextField()
        sut.carbs = UITextField()
        sut.fat = UITextField()
        sut.kcal.text = "kcal"
        sut.name.text = "name"
        sut.carbs.text = "carbs"
        sut.protein.text = "protein"
        sut.fat.text = "fat"
        sut.done(UIBarButtonItem())
        let foodItem = delegate.foodItem
        XCTAssertEqual(foodItem.kcal, "kcal", "FoodItem should contain value")
        XCTAssertEqual(foodItem.carbs, "carbs", "FoodItem should contain value")
        XCTAssertEqual(foodItem.protein, "protein", "FoodItem should contain value")
        XCTAssertEqual(foodItem.fett, "fat", "FoodItem should contain value")
    }
    
    func testThatSetionHeaderIsName() {
        let _ = sut.view
        let sectionHeader = sut.tableView(sut.tableView, titleForHeaderInSection: 0)
        XCTAssertEqual(sectionHeader, "Name", "Seaction Header should be Name")
    }
    
    func testThatSetionHeaderIsNährwerteFür100g() {
        let _ = sut.view
        let sectionHeader = sut.tableView(sut.tableView, titleForHeaderInSection: 1)
        XCTAssertEqual(sectionHeader, "Nährwerte für 100g", "Seaction Header should be Name 'Nährwerte für 100g'")
    }

    
}
