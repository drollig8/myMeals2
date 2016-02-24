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
    
    class func getLastSortOrderForSection(section: Int,inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> Int
    {
        
        let fetchRequest = NSFetchRequest(entityName: "FoodEntry")
        let predicate = NSPredicate(format: "section = %d ", section)
        fetchRequest.predicate = predicate
        let foodItems = try!managedObjectContext.executeFetchRequest(fetchRequest) as! [FoodEntry]
        return foodItems.count
        
    }
    
    class func addFoodEntry(dateString dateString: String, amount: String? = nil, unit: String? = nil, inSection section: Int, withFoodItemNamed foodItemName: String?=nil,inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> FoodEntry
    {
        
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

        }
        if let unit = unit {
            foodEntry.unit = unit
        }
        foodEntry.sortOrder = NSNumber(integer: getLastSortOrderForSection(section,inManagedObjectContext: managedObjectContext))
        print(foodEntry.sortOrder)
        return foodEntry
    }
    
    

    
    
    
    // CONSOLIDIEREN mit ADD FOOD ENTRY
    
    class func createFoodEntry(var inSection section: Int? = 0, var atDateString dateString: String? = nil, unit: String? = nil, amount: String? = nil, foodItemName: String? = nil, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> FoodEntry
    {
        if section == nil {
            section = 0
        }

        if dateString == nil {
            dateString = todayDateString
        }

        return addFoodEntry(dateString: dateString!, amount: amount, unit: unit, inSection: section!, withFoodItemNamed: foodItemName, inManagedObjectContext: managedObjectContext)

        
    }
    
    
    
    
    
    
    class func getFoodEntries(forDateString dateString: String, inSection section: Int? = nil, inmanagedObjectContext managedObjectContext: NSManagedObjectContext)  -> [FoodEntry]
    {
        
        let predicate =  section == nil ? NSPredicate(format: "dateString = %@", dateString) :  NSPredicate(format: "dateString = %@ AND section = %d", dateString, section!)
        let fetchRequest = NSFetchRequest(entityName: "FoodEntry")
        fetchRequest.predicate = predicate
        let objects = try!managedObjectContext.executeFetchRequest(fetchRequest)
        return objects as! [FoodEntry]
    }
}
