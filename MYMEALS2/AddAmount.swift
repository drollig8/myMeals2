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
    func addAmountViewController(addAmountViewController:AddAmountViewController, didAddAmount foodEntry: FoodEntry)
}

class AddAmountViewController: UITableViewController {
    
    // TODO: rename amount!
    @IBOutlet var amount: UITextField!
    @IBOutlet weak var name: UILabel!
    

    var managedObjectContext: NSManagedObjectContext!
    var foodItem : FoodItem!
    var delegate : AddAmountDelegate!
    var dateString: String!
    var section : Int!
    
    private func addDoneButton()
    {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done:")
    }
    
    override func viewDidLoad()
    {
        addDoneButton()
        // TODO : Es macht sinn, das nicht hierher übergeben wird und asserted werden muss, sondern dass der foodEntry schon vorher creeiert wird und diese Informationen schon enthält. Das ist eine Reduktion von Schnittstellen !!!
   //     assert(dateString != nil)
   //     assert(section != 0)

    }
   
    func done(sender:AnyObject)
    {
        if amount.text!.isEmpty {
            let alertController = UIAlertController(title: "Error", message: "Entry is empty", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            // TODO DateString und Sectino fehlen !!!
            var foodName = ""
            if foodItem != nil {
                foodName = foodItem.name ?? ""
            }
            let amount1 = amount.text ?? ""
            let unit = "g"
            //CoreDataHelper.addFoodEntry(dateString: dateString, inSection: section, amount: amount1, unit: unit, withFoodItemNamed: foodName, inManagedObjectContext: managedObjectContext)
        }
    }
    
}
