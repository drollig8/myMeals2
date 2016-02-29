//
//  FoodItemViewController2.swift
//  MYMEALS2
//
//  Created by Marc Felden on 29.02.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import UIKit

class FoodItemViewController2: UIViewController
{
    @IBOutlet var tableView: UITableView!
    @IBOutlet var dataProvider: protocol<UITableViewDataSource,UITableViewDelegate,FoodItemManagerSettable>!

    
    
    // ItemManagerSettable forces us to attach foodItemManager to dataProvider ?
    let foodItemManager = FoodItemManager()
    
    @IBAction func addFoodItem(sender: UIBarButtonItem)
    {
     //   let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
     //   let viewController = storyboard.instantiateViewControllerWithIdentifier("AddFoodItemViewController") as? AddFoodItemViewController
     //   presentViewController(viewController!, animated: true, completion: nil)
        
        // Hauser macht das so:
        
        // present viewcontroller that is created from storyboard !!
        
        if let nextViewController = storyboard?.instantiateViewControllerWithIdentifier("AddFoodItemViewController") as? AddFoodItemViewController
        {
            presentViewController(nextViewController, animated: true, completion: nil) // Error wind hierarchy
        }
    }
    //

    
    override func viewDidLoad()
    {
        tableView.dataSource = dataProvider
        tableView.delegate = dataProvider
        
        //(1)
        dataProvider.foodItemManager = foodItemManager  // TRY TO UNDERSTAND THIS NECESSITY
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showDetails:", name: "ItemSelectedNotification", object: nil)
    }
    
    

    
}
