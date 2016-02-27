//
//  ScanFoodItemViewController.swift
//  MYMEALS2
//
//  Created by Marc Felden on 31.01.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import UIKit
import CoreData

class ScanFoodItemViewController: UIViewController {
    var foodItem: CDFoodItem?
    var delegate: AddFoodItemDelegate?
    override func viewDidLoad() {
        print("ViewDidLoad ScanFoodItemViewController")
    }
}
