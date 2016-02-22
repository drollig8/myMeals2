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

class AddAmountViewControllerTests: XCTestCase {
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var store: NSPersistentStore!
    var sut:AddAmountViewController!
    
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewControllerWithIdentifier("AddAmountViewController") as! AddAmountViewController
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
    
    private func initSut() {
        let _ = sut.view
    }
    func testThatWeHaveDoneButton() {
        initSut()
        print(sut.navigationItem.rightBarButtonItem)
        XCTAssertNotNil(sut.navigationItem.rightBarButtonItem)
    }
    
    func testThatDoneActionVerifiesEntry() {
        class Mock: AddAmountViewController {
            var someThingWasPresented = false
            private override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
                someThingWasPresented = true
            }
        }
        let sut = Mock()
        sut.amount = UITextField()
        sut.amount.text = ""
        sut.done(self)
        XCTAssertTrue(sut.someThingWasPresented)
        
    }
    
    func testThatDoneCreatesNewEntry() {
        initSut()
        sut.amount.text = "127"
        sut.done(self)
        let objects = CoreDataHelper.getAllFoodEntries(inManagedObjectContext: managedObjectContext)
        XCTAssertTrue(objects.count != 0)
    }
}
