//
//  CoreDataStack.swift
//  PasswordSafe
//
//  Created by Marc Felden on 15.01.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import CoreData

class CoreDataStack {
    
    var modelName   : String
    var storeName   : String
    var options     : [String : AnyObject]?
    var store       : NSPersistentStore?
    
    init(modelName:String, storeName:String, options: [String : AnyObject]? = nil) {
        self.modelName = modelName
        self.storeName = storeName
        self.options = options
    }
    
    var modelURL : NSURL {
        return NSBundle.mainBundle().URLForResource(self.modelName, withExtension: "momd")!
    }
    
    var storeURL : NSURL {
        var storePaths = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true) as [String]
        let storePath = String(storePaths[0]) as NSString
        let fileManager = NSFileManager.defaultManager()
        
        do {
            try fileManager.createDirectoryAtPath(storePath as String, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Error creating storePath \(storePath): \(error)")
        }
        let sqliteFilePath = storePath.stringByAppendingPathComponent(storeName + ".sqlite")
        return NSURL(fileURLWithPath: sqliteFilePath)
    }
    
    private lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var model : NSManagedObjectModel = NSManagedObjectModel(contentsOfURL: self.modelURL)!
    
    lazy var coordinator : NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        do {
            self.store = try coordinator.addPersistentStoreWithType(
                NSSQLiteStoreType,
                configuration: nil,
                URL: self.storeURL,
                options: self.options)
        } catch var error as NSError {
            print("Store Error: \(error)")
            self.store = nil
        } catch {
            fatalError()
        }
        return coordinator
    }()
    
    lazy var context : NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.coordinator
        return context
    }()
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
                abort()
            }
        }
    }
    
    // Responding to iCloud changes
    
    var updateContextWithUbiquitousContentUpdates: Bool = false {
        willSet {
            print("Listening to notifications")
            ubiquitousChangesObserver = newValue ? NSNotificationCenter.defaultCenter() : nil
        }
    }
    
    
    
    private var ubiquitousChangesObserver : NSNotificationCenter? {
        didSet {
            oldValue?.removeObserver(self, name: NSPersistentStoreDidImportUbiquitousContentChangesNotification,
            object: coordinator);
            ubiquitousChangesObserver?.addObserver(self,
            selector: "persistentStoreDidImportUbiquitousContentChanges:",
            name: NSPersistentStoreDidImportUbiquitousContentChangesNotification,
            object:coordinator)
        }
    }
    
    @objc func persistentStoreDidImportUbiquitousContentChanges( notification: NSNotification){
                NSLog("Merging ubiquitous content changes")
                context.performBlock {
                self.context.mergeChangesFromContextDidSaveNotification( notification)
                }
    }

}
