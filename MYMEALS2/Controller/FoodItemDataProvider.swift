//
//  FoodItemDataProvider.swift
//  MYMEALS2
//
//  Created by Marc Felden on 27.02.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import UIKit

class FoodItemDataProvider: NSObject, UITableViewDataSource, UITableViewDelegate
{
    var foodItemManager: FoodItemManager?
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return foodItemManager?.itemCount ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FoodItemCell
        return cell
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 6
    }

}
