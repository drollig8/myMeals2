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
    let calories: String?
    let carbs: String?
    let protein: String?
    let fett: String?

    let lastUsed: NSDate
    let barcode: String
    
    init(name: String, calories: String? = nil, carbs: String? = nil, protein: String? = nil, fett: String? = nil)
    {
        self.name = name
        self.calories = calories
        self.carbs = carbs
        self.protein = protein
        self.fett = fett
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