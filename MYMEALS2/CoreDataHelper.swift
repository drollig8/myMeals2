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
    

    
    private class func getFoodItem(named name: String,inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> FoodItem? {
        
        let fetchRequest = NSFetchRequest(entityName: "FoodItem")
        let predicate = NSPredicate(format: "name =%@", name)
        fetchRequest.predicate = predicate
        let foodItems = try!managedObjectContext.executeFetchRequest(fetchRequest) as! [FoodItem]
        return foodItems.first
        
    }
    
    class func getLastSortOrderForSection(section: Int,inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> Int {
        
        let fetchRequest = NSFetchRequest(entityName: "FoodEntry")
        let predicate = NSPredicate(format: "section = %d ", section)
        fetchRequest.predicate = predicate
        let foodItems = try!managedObjectContext.executeFetchRequest(fetchRequest) as! [FoodEntry]
        return foodItems.count
        
    }
    
    class func addFoodEntry(dateString dateString: String, amount: String? = nil, inSection section: Int, withFoodItemNamed foodItemName: String?=nil,inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> FoodEntry {
        
        var foodItem : FoodItem?
        if let foodItemName = foodItemName {
            foodItem = getFoodItem(named: foodItemName,inManagedObjectContext: managedObjectContext)
        }
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        foodEntry.dateString = dateString
        if let amount = amount {
            foodEntry.amount = amount
            foodEntry.section = NSNumber(integer: section)
            foodEntry.foodItemRel = foodItem
            foodEntry.sortOrder = NSNumber(integer: getLastSortOrderForSection(section,inManagedObjectContext: managedObjectContext))
        }
        return foodEntry
    }
    
    // CONSOLIDIEREN mit ADD FOOD ENTRY
    class func createFoodEntry(inSection section: Int? = 0, atDateString dateString: String? = nil, unit: String? = nil, amount: String? = nil, foodItem: FoodItem? = nil,inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> FoodEntry {
        
        
  //      var foodItem : FoodItem?
        /*
        if let foodItemName = foodItem?.name {
            foodItem = getFoodItem(named: foodItemName,inManagedObjectContext: managedObjectContext)
        }
*/
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        foodEntry.dateString = dateString
       
            foodEntry.amount = amount
        foodEntry.unit = unit
            foodEntry.section = NSNumber(integer: section!)
            foodEntry.foodItemRel = foodItem
            foodEntry.sortOrder = NSNumber(integer: getLastSortOrderForSection(section!,inManagedObjectContext: managedObjectContext))
        
        return foodEntry
    }
    
    // TODO search for todo / dublicate
}
