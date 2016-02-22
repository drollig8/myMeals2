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
    
}
