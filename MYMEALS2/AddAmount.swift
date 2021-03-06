//
//  AddAmountViewController.swift
//  MYMEALS2
//
//  Created by Marc Felden on 31.01.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import UIKit
import CoreData

protocol AddAmountDelegate {
    func addAmountViewController(addAmountViewController:AddAmountViewController, didAddAmount foodEntry: CDFoodEntry)
}

class AddAmountViewController: UITableViewController {
    
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var nameTextLabel: UILabel!
    
    @IBOutlet var totalProteinLabel: UILabel!
    @IBOutlet var totalFatLabel: UILabel!
    @IBOutlet var totalCarbLabel: UILabel!
    @IBOutlet var totalCaloriesLabel: UILabel!
    
    @IBOutlet var totalProteinValue: UILabel!
    @IBOutlet var totalFatValue: UILabel!
    @IBOutlet var totalCarbValue: UILabel!
    @IBOutlet var totalCaloriesValue: UILabel!

    var managedObjectContext: NSManagedObjectContext!
    var foodItem : CDFoodItem!
    var foodEntry: CDFoodEntry!
    var delegate : AddAmountDelegate!

    private func setSummaryLabels()
    {
        totalCaloriesLabel?.text = "Kalorien"
        totalCarbLabel?.text = "KH"
        totalProteinLabel?.text = "Protein"
        totalFatLabel?.text = "Fett"
        totalCaloriesValue?.text = " -- "
        totalCarbValue?.text = " -- "
        totalProteinValue?.text = " -- "
        totalFatValue?.text = " -- "
    }
    
    private func setCDFoodItemsNutricionalValues()
    {
        totalCaloriesValue?.text = foodItem.kcal
        totalCarbValue?.text = foodItem.carbs
        totalProteinValue?.text = foodItem.protein
        totalFatValue?.text = foodItem.fett
        
    }
    override func viewDidLoad()
    {
        UIFunctions.addDoneButton(self)
        setSummaryLabels()
        setCDFoodItemsNutricionalValues()
        nameTextLabel.font = UIFont.customSummaryValues()
        nameTextLabel.text = foodItem.name
    }
   
    func done(sender:AnyObject)
    {
        if amountTextField.text!.isEmpty {
            let alertController = UIAlertController(title: "Error", message: "Entry is empty", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
        }
        else {

            assert(foodEntry != nil)
            let amount = amountTextField.text?.toDouble() ?? 0
            let unit = "g"
            
            foodEntry.amount = amount
            foodEntry.unit = unit
            foodEntry.foodItemRel = foodItem
            delegate.addAmountViewController(self, didAddAmount: foodEntry)
        }
    }
    
}
