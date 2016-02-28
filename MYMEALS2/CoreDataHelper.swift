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
    
    
    // MARK: - CDFoodItem
    
    private class func hasCDFoodItem(named name:String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> Bool
    {
        return getCDFoodItem(named: name, inManagedObjectContext: managedObjectContext) != nil
        
    }
    
    class func createCDFoodItem(name name: String? = nil, kcal: String? = nil, carbs: String? = nil, protein: String?=nil, fat:String?=nil, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> CDFoodItem
    {
        
        if let name = name {
            if !hasCDFoodItem(named: name, inManagedObjectContext: managedObjectContext) {
        
                let foodItem = NSEntityDescription.insertNewObjectForEntityForName("CDFoodItem", inManagedObjectContext: managedObjectContext) as! CDFoodItem
                
                    foodItem.name = name
                
                if let kcal = kcal {
                    foodItem.kcal = kcal
                }
                if let carbs = carbs {
                    foodItem.carbs = carbs
                }
                if let protein = protein {
                    foodItem.protein = protein
                }
                if let fat = fat {
                    foodItem.fett = fat
                }
                return foodItem
            } else {
                return getCDFoodItem(named: name, inManagedObjectContext: managedObjectContext)!
            }
        }
        else
        {
            let foodItem = NSEntityDescription.insertNewObjectForEntityForName("CDFoodItem", inManagedObjectContext: managedObjectContext) as! CDFoodItem
            
            foodItem.name = name
            
            if let kcal = kcal {
                foodItem.kcal = kcal
            }
            if let carbs = carbs {
                foodItem.carbs = carbs
            }
            if let protein = protein {
                foodItem.protein = protein
            }
            if let fat = fat {
                foodItem.fett = fat
            }
            return foodItem
        }
        
    }
    
    
    class func getAllCDFoodItems(inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> [CDFoodItem]
    {
        let fetchRequest = NSFetchRequest(entityName: "CDFoodItem")
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [nameSort]
        let foodItems = try!managedObjectContext.executeFetchRequest(fetchRequest) as! [CDFoodItem]
        return foodItems
    }
    
    
    // MARK: - public Helpers
    
    
    class func getLastEntry(dateString dateString: String, inSection section: Int,inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> Int
    {
        let fetchRequest = NSFetchRequest(entityName: "CDFoodEntry")
        let predicate = NSPredicate(format: "section = %d ", section)
        fetchRequest.predicate = predicate
        let foodItems = try!managedObjectContext.executeFetchRequest(fetchRequest) as! [CDFoodEntry]
        return foodItems.count
        
    }
    

    
    
    class func addCDFoodEntry(dateString dateString: String, inSection section: Int, amount: Double? = nil, unit: String? = nil,  withCDFoodItemNamed foodItemName: String? = nil,inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> CDFoodEntry
    {
        
        var foodItem : CDFoodItem?
        if let foodItemName = foodItemName {
            foodItem = getCDFoodItem(named: foodItemName,inManagedObjectContext: managedObjectContext)
        }
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("CDFoodEntry", inManagedObjectContext: managedObjectContext) as! CDFoodEntry
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

    
    class func getFoodEntries(forDateString dateString: String, inSection section: Int? = nil, inmanagedObjectContext managedObjectContext: NSManagedObjectContext)  -> [CDFoodEntry]
    {
        
        let predicate =  section == nil ? NSPredicate(format: "dateString = %@", dateString) :  NSPredicate(format: "dateString = %@ AND section = %d", dateString, section!)
        let fetchRequest = NSFetchRequest(entityName: "CDFoodEntry")
        fetchRequest.predicate = predicate
        let objects = try!managedObjectContext.executeFetchRequest(fetchRequest)
        return objects as! [CDFoodEntry]
    }
    
    // MARK: - Private Classes
    
    private class func getCDFoodItem(named name: String,inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> CDFoodItem? {
        
        let fetchRequest = NSFetchRequest(entityName: "CDFoodItem")
        let predicate = NSPredicate(format: "name =%@", name)
        fetchRequest.predicate = predicate
        let foodItems = try!managedObjectContext.executeFetchRequest(fetchRequest) as! [CDFoodItem]
        return foodItems.first
        
    }

}
