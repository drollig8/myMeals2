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
    @IBOutlet var amount: UITextField!
    
    @IBOutlet weak var name: UILabel!
    
    var managedObjectContext: NSManagedObjectContext!
    var foodItem : FoodItem!
    var delegate : AddAmountDelegate!
    override func viewDidLoad() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done:")
    }
   
    func done(sender:AnyObject) {
        if amount.text!.isEmpty {
            let alertController = UIAlertController(title: "Error", message: "Entry is empty", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            CoreDataHelper.createFoodEntry(inSection: 0, unit: nil, amount: amount.text!, foodItem: foodItem, inManagedObjectContext: managedObjectContext)
        }
    }
    
}
