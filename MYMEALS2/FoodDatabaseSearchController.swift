//
//  FoodDatabaseSearchController.swift
//  MYMEALS2
//
//  Created by Marc Felden on 31.01.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import Foundation
import CoreData

class FoodDatabaseSearchController {
    
    var searchText : String!
    var managedObjectContext: NSManagedObjectContext!
    
    func performSearch(completionHandler: ([CDFoodItem])->()) {
        
        var foodItems = [CDFoodItem]()
        let urlstring   = "http://fddb.mobi/search/?lang=de&cat=mobile-de&search=\(searchText)"
        let url         = NSURL(string: urlstring)
        let data: NSData?
        do {
            data = try NSData(contentsOfURL: url!, options: NSDataReadingOptions())
        } catch let error as NSError {
            fatalError("\(error)")
        }
        
        
        if let data = data {
            
            let answerFromWebpage = NSString(data: data, encoding: NSWindowsCP1250StringEncoding)
            
            if let string = answerFromWebpage as? String {
                
                // jetzt kommt in string die windowslocation mehremls vor.
                
                let stringarray = string.componentsSeparatedByString("window.loc")
                
                for stringSub in stringarray {
                    
                    if let subURL = stringSub.getStringBetweenStrings("ation.href = '", string2: "';\"><table><tr><td") {
                        
                        // now we have the url
                        let url1 = NSURL(string: subURL)
                        let data1: NSData?
                        do {
                            data1 = try NSData(contentsOfURL: url1!, options: NSDataReadingOptions())
                        } catch let error as NSError {
                            fatalError("\(error)")
                        }
                        
                        if let data3 = data1 {
                            let answer2 = NSString(data: data3, encoding: NSWindowsCP1250StringEncoding)
                            if let string3 = answer2 as? String {
                                let name = string3.getStringBetweenStrings("content=\"Kalorien f&uuml;r ", string2: " - Fddb") ?? "not found"
                                let protein = string3.getStringBetweenStrings("Protein</span></td><td>", string2: " g</td></tr><tr><td>") ?? "999"
                                let kcal = string3.getStringBetweenStrings("Kalorien</span></td><td>", string2: " kcal</td></tr><tr style=") ?? "999"
                                let kh = string3.getStringBetweenStrings(">carbs</span></td><td>", string2: " g</td></tr><tr") ?? "999"
                                let fett = string3.getStringBetweenStrings("Fett</span></td><td>", string2: " g</td></tr></table><h4>") ?? "999"
                                let foodItem = generateCDFoodItem(name, kcal: kcal, carbs: kh, protein: protein, fett: fett)
                                foodItems.append(foodItem)
                            }
                        }
                    }
                }
            }
        }


        completionHandler(foodItems)
        
    }
    
    
   
    
    func generateCDFoodItem(name: String, kcal: String, carbs: String, protein: String, fett: String) -> CDFoodItem {
        assert(managedObjectContext != nil)
        let foodItem = NSEntityDescription.insertNewObjectForEntityForName("CDFoodItem", inManagedObjectContext: managedObjectContext) as! CDFoodItem
        foodItem.name = name
        foodItem.kcal = kcal
        foodItem.carbs = carbs
        foodItem.protein = protein
        foodItem.fett = fett
        return foodItem
    }
}
