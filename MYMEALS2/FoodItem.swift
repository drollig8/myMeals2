//
//  FoodItem.swift
//  MYMEALS2
//
//  Created by Marc Felden on 26.02.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

struct FoodItem : Equatable
{
    
    let name: String
    let calories: Double?
    let carbs: Double?
    let protein: Double?
    let fat: Double?

    let lastUsed: NSDate
    let barcode: String
    
    init(name: String, calories: Double? = nil, carbs: Double? = nil, protein: Double? = nil, fat: Double? = nil)
    {
        self.name = name
        self.calories = calories
        self.carbs = carbs
        self.protein = protein
        self.fat = fat
        self.lastUsed = NSDate()
        self.barcode = ""
    }
}


func ==(lhs:FoodItem, rhs: FoodItem) -> Bool
{
    if lhs.name != rhs.name {
        return false
    }
    return true
    
}