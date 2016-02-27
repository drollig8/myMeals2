//
//  CDFoodEntry+CoreDataProperties.swift
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

extension CDFoodEntry {

    @NSManaged var date: NSDate?
    @NSManaged var unit: String?
    @NSManaged var amount: NSNumber?
    @NSManaged var dateString: String?
    @NSManaged var timeString: String?
    @NSManaged var section: NSNumber?
    @NSManaged var sortOrder: NSNumber?
    @NSManaged var foodItemRel: CDFoodItem?
    

}
