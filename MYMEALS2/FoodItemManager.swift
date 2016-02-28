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
    
    init(withManagedObjectContext managedObjectContext: NSManagedObjectContext) {
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
    
        return fooditems[index]
    }

    
}
