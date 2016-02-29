//
//  FoodItemManager.swift
//  MYMEALS2
//
//  Created by Marc Felden on 26.02.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import CoreData

class FoodItemManager:NSObject
{
    
    let managedObjectContext : NSManagedObjectContext!
    
    var itemCount: Int {
        assert(managedObjectContext != nil)
        let cdFoodItems = CoreDataHelper.getAllCDFoodItems(inManagedObjectContext: managedObjectContext)
        return cdFoodItems.count
    }
    
    // we need to force the setting of the managedObjectContext
    
    init(var withManagedObjectContext managedObjectContext: NSManagedObjectContext? = nil)
    {
        if managedObjectContext == nil {
            managedObjectContext = AppDelegate().coreDataStack.context
        }
        self.managedObjectContext = managedObjectContext
    }
    
    private var fooditems = [FoodItem]()
    
    
    func addItem(foodItem: FoodItem)
    {
        if !fooditems.contains(foodItem) {
            
            CoreDataHelper.createCDFoodItem(name: foodItem.name, inManagedObjectContext: managedObjectContext)
            try!managedObjectContext.save()
            fooditems.append(foodItem)
        }
       
    }
    
    func itemAtIndex(index: Int) -> FoodItem
    {
        
        let fetchRequest = NSFetchRequest(entityName: "CDFoodItem")
        let nameSort = NSSortDescriptor(key: "lastUsed", ascending: false)
        fetchRequest.sortDescriptors = [nameSort]
        let cdFoodItems = try!managedObjectContext.executeFetchRequest(fetchRequest) as! [CDFoodItem]
       
        let cdFoodItem = cdFoodItems[index]
        
        let foodItem = FoodItem(name: cdFoodItem.name!, calories: cdFoodItem.kcal?.toDouble(), carbs: cdFoodItem.carbs?.toDouble(), protein: cdFoodItem.protein?.toDouble(), fat: cdFoodItem.fett?.toDouble())
        return foodItem

    }

    
}
