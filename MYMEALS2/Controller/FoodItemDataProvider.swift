//
//  FoodItemDataProvider.swift
//  MYMEALS2
//
//  Created by Marc Felden on 27.02.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import UIKit

// we force that the manager gets set !

@objc protocol FoodItemManagerSettable {
    var foodItemManager: FoodItemManager? { get set }
}

class FoodItemDataProvider: NSObject, UITableViewDataSource, UITableViewDelegate
{
    var foodItemManager: FoodItemManager?
    
    // MARK: - TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 6
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return foodItemManager?.itemCount ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        guard let itemManager = foodItemManager else { fatalError() }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FoodItemCell
        
        let foodItem = itemManager.itemAtIndex(indexPath.row)
        cell.configureCelWithItem(foodItem)
    
        return cell
    }
    
    // MARK: - TableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        NSNotificationCenter.defaultCenter().postNotificationName(kFoodItemSelectedNotification, object: self, userInfo: ["index":indexPath.row])
    }



}
