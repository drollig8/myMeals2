//
//  CDFoodItem+CoreDataProperties.swift
//  MYMEALS2
//
//  Created by Marc Felden on 31.01.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CDFoodItem {
    @NSManaged var lastUsed: NSDate?
    @NSManaged var name: String?
    @NSManaged var barcode: String?
    @NSManaged var fett: String?
    @NSManaged var protein: String?
    @NSManaged var kcal: String?
    @NSManaged var carbs: String?
    @NSManaged var foodEntriesRel: NSSet?

}
