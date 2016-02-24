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
    
    
    // MARK: - FoodItem
    
    class func createFoodItem(name name: String? = nil, kcal: String? = nil, carbs: String? = nil, protein: String?=nil, fat:String?=nil, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> FoodItem
    {
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
        if let name = name {
            foodItem.name = name
        }
        if let kcal = kcal {
            foodItem.kcal = kcal
        }
        if let carbs = carbs {
            foodItem.kohlenhydrate = carbs
        }
        if let protein = protein {
            foodItem.protein = protein
        }
        if let fat = fat {
            foodItem.fett = fat
        }
        return foodItem
    }
    
    
    class func getAllFoodItems(inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> [FoodItem]
    {
        let fetchRequest = NSFetchRequest(entityName: "FoodItem")
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [nameSort]
        let foodItems = try!managedObjectContext.executeFetchRequest(fetchRequest) as! [FoodItem]
        return foodItems
    }
    
    
    // MARK: - public Helpers
    
    
    class func getLastEntry(dateString dateString: String, inSection section: Int,inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> Int
    {
        let fetchRequest = NSFetchRequest(entityName: "FoodEntry")
        let predicate = NSPredicate(format: "section = %d ", section)
        fetchRequest.predicate = predicate
        let foodItems = try!managedObjectContext.executeFetchRequest(fetchRequest) as! [FoodEntry]
        return foodItems.count
        
    }
    
    //TODO: Sinnvoll, aber inSection umpositionieren an den Anfang.
    //TODO: Ist das sinnvoll, dass der Amount ein String ist?
    class func addFoodEntryMussWeg(dateString dateString: String, amount: String? = nil, unit: String? = nil, inSection section: Int, withFoodItemNamed foodItemName: String?=nil,inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> FoodEntry
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
        foodEntry.sortOrder = NSNumber(integer: getLastEntry(dateString: dateString, inSection: section, inManagedObjectContext: managedObjectContext))
        return foodEntry
    }
    
    
    class func addFoodEntry(dateString dateString: String, inSection section: Int, amount: String? = nil, unit: String? = nil,  withFoodItemNamed foodItemName: String? = nil,inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> FoodEntry
    {
        
        var foodItem : FoodItem?
        if let foodItemName = foodItemName {
            foodItem = getFoodItem(named: foodItemName,inManagedObjectContext: managedObjectContext)
        }
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        foodEntry.dateString = dateString
        foodEntry.section = NSNumber(integer: section)
        foodEntry.foodItemRel = foodItem
        if let amount = amount {
            foodEntry.amount = amount
        }
        if let unit = unit {
            foodEntry.unit = unit
        }
        foodEntry.sortOrder = NSNumber(integer: getLastEntry(dateString: dateString, inSection: section, inManagedObjectContext: managedObjectContext))
        return foodEntry
    }

    
    class func getFoodEntries(forDateString dateString: String, inSection section: Int? = nil, inmanagedObjectContext managedObjectContext: NSManagedObjectContext)  -> [FoodEntry]
    {
        
        let predicate =  section == nil ? NSPredicate(format: "dateString = %@", dateString) :  NSPredicate(format: "dateString = %@ AND section = %d", dateString, section!)
        let fetchRequest = NSFetchRequest(entityName: "FoodEntry")
        fetchRequest.predicate = predicate
        let objects = try!managedObjectContext.executeFetchRequest(fetchRequest)
        return objects as! [FoodEntry]
    }
    
    // MARK: - Private Classes
    
    private class func getFoodItem(named name: String,inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> FoodItem? {
        
        let fetchRequest = NSFetchRequest(entityName: "FoodItem")
        let predicate = NSPredicate(format: "name =%@", name)
        fetchRequest.predicate = predicate
        let foodItems = try!managedObjectContext.executeFetchRequest(fetchRequest) as! [FoodItem]
        return foodItems.first
        
    }

}
