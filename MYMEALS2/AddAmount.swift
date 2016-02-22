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
    @IBOutlet weak var amount: UITextField!
    var foodItem : FoodItem!
    var delegate : AddAmountDelegate!
    override func viewDidLoad() {
        print("ViewDidLoad AddAmountViewController")

    }
   
}
