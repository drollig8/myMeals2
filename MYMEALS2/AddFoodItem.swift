//
//  AddFoodItemViewController.swift
//  MYMEALS2
//
//  Created by Marc Felden on 31.01.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import UIKit
import CoreData

protocol AddFoodItemDelegate {
    func addCDFoodItemViewController(addCDFoodItemViewController:AddFoodItemViewController, didAddFoodItem foodItem: CDFoodItem?)
}

class AddFoodItemViewController: UITableViewController
{
    var foodItem: CDFoodItem!
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var kcal: UITextField!
    @IBOutlet weak var carbs: UITextField!
    @IBOutlet weak var protein: UITextField!
    @IBOutlet weak var fat: UITextField!
    
    var delegate: AddFoodItemDelegate?
    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad()
    {
        UIFunctions.addCancelButton(self)
        UIFunctions.addDoneButton(self)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        assert(delegate != nil)
    }
    
    func cancel(sender: AnyObject)
    {
        managedObjectContext.deleteObject(foodItem)
        try!managedObjectContext.save()
        delegate?.addCDFoodItemViewController(self, didAddFoodItem: nil)
    }
    
    func done(sender: AnyObject) {
        
        func showAlertWithMessage(message: String) {
            let alertController = UIAlertController(title: "Hinweis", message: message, preferredStyle: .Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertController.addAction(action)
            presentViewController(alertController, animated: false, completion: nil)
        }
        
        if name.text!.isEmpty { showAlertWithMessage("kein Name") }
        
        else if kcal.text!.isEmpty { showAlertWithMessage("keine Kalorien") }

        else if carbs.text!.isEmpty { showAlertWithMessage("keine carbs") }

        else if protein.text!.isEmpty  { showAlertWithMessage("keine Protein") }
        
        else if fat.text!.isEmpty  { showAlertWithMessage("keine Fett") }
        
        else {
            foodItem.kcal = kcal.text
            foodItem.carbs = carbs.text
            foodItem.protein = protein.text
            foodItem.fett = fat.text
            delegate?.addCDFoodItemViewController(self, didAddFoodItem: foodItem)
        }

    }
    
}
