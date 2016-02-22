//
//  CoreDataHelper.swift
//  MYMEALS2
//
//  Created by Marc Felden on 22.02.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import Foundation
import CoreData

class CoreDataHelper {
    
    
    class func test() {
        print("Test")
    }
    
    class func createFoodItem(name name: String? = nil, kcal: String? = nil, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> FoodItem {
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        if let name = name {
            foodItem.name = name
        }
        if let kcal = kcal {
            foodItem.kcal = kcal
        }
        
        return foodItem
    }
    
    class func getAllFoodItems(inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> [FoodItem] {
        
        let fetchRequest = NSFetchRequest(entityName: "FoodItem")
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [nameSort]
        let foodItems = try!managedObjectContext.executeFetchRequest(fetchRequest) as! [FoodItem]
        return foodItems
        
    }
    
    class func getAllFoodEntries(inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> [FoodEntry] {
        
        let fetchRequest = NSFetchRequest(entityName: "FoodEntry")
        
        let foodItems = try!managedObjectContext.executeFetchRequest(fetchRequest) as! [FoodEntry]
        return foodItems
        
    }
    
    class func createFoodEntry(inSection section: Int? = 0, unit: String? = nil, amount: String? = nil, foodItem: FoodItem? = nil,inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> FoodEntry {
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
    
    // TODO search for todo / dublicate
}
