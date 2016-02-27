//
//  ViewController.swift
//  MYMEALS2.0
//
//  Created by Marc Felden on 30.01.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import UIKit
import CoreData

class FoodItemsViewController: UITableViewController,AddFoodItemDelegate,AddAmountDelegate, UISearchBarDelegate, NSFetchedResultsControllerDelegate {

    var managedObjectContext    : NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController!
    var foodDatabaseSearchController = FoodDatabaseSearchController()
    var stack                   : CoreDataStack! {
        didSet {
            stack.updateContextWithUbiquitousContentUpdates = true
        }
    }
    var foodDatabaseSearchCDFoodItems: [CDFoodItem]!
    var selectedCDFoodItem: CDFoodItem!
    var foodEntry: CDFoodEntry!
    var addAmountDelegate:AddAmountDelegate!
    
    var performSegueHasBeenCalled = false // because we cannot mock storyboard viewcontrollers that implement a tableview. maybe we want to do it programmatically

    @IBOutlet var searchBar: UISearchBar!  // wegen Unit Test darf das nicht weak sein.
    @IBOutlet var addCDFoodItemBarButton: UIBarButtonItem!
    @IBOutlet weak var scanButton: UIButton!
    
    let cellIdentifier = "Cell"
    
    private func setTitle(title: String)
    {
        self.navigationItem.title = title
    }
    
    func addToolBarButton()
    {
        
        self.toolbarItems = [UIBarButtonItem(title: "addCDFoodItem", style: UIBarButtonItemStyle.Plain, target: self, action: "addCDFoodItem:")]
        self.navigationController?.toolbarHidden = false
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "scan", style: .Plain, target: self, action: "scanCDFoodItem:")
        addToolBarButton()
        searchBar?.delegate = self
        searchBar?.returnKeyType = .Search
        setTitle("Eintrag hinzufügen")
        self.fetch()
    }
    

    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        // TODO ASYNC
        // NETWORK INDICATOR
        foodDatabaseSearchController.searchText = searchBar.text
        foodDatabaseSearchController.managedObjectContext = managedObjectContext
        foodDatabaseSearchController.performSearch { (foodItems) -> () in
            self.foodDatabaseSearchCDFoodItems = foodItems
            self.tableView.reloadData() // wenn das nil ist, werden die lokalen Ergebnisse angezeigt.
        }
        searchBar.resignFirstResponder()
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let foodDatabaseSearchCDFoodItems = foodDatabaseSearchCDFoodItems {
            return foodDatabaseSearchCDFoodItems.count
        } else {
            return fetchedResultsController.sections![section].objects!.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //assert(foodEntry != nil)
        
        let foodItem: CDFoodItem!
        if !fetchedResultsController.hasObjectAtIndexPath(indexPath) {
            fatalError("Object not found.")
        }
        if let foodDatabaseSearchCDFoodItems = foodDatabaseSearchCDFoodItems {
            foodItem = foodDatabaseSearchCDFoodItems[indexPath.row]
        } else {
            foodItem = fetchedResultsController.objectAtIndexPath(indexPath) as! CDFoodItem
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("AddAmountViewController") as! AddAmountViewController
            viewController.foodItem = foodItem
        viewController.foodEntry = foodEntry
        viewController.delegate = self
        self.navigationController?.pushViewController(viewController, animated: false)
        

    }
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        if let foodDatabaseSearchCDFoodItems = foodDatabaseSearchCDFoodItems {
            selectedCDFoodItem = foodDatabaseSearchCDFoodItems[indexPath.row]
        } else {
            selectedCDFoodItem = fetchedResultsController.objectAtIndexPath(indexPath) as! CDFoodItem
        }
        performSegueWithIdentifier(kSegue.ShowDetailsOfFoodItem, sender: self)
    }
    
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        var foodItem: CDFoodItem!
        if let foodDatabaseSearchCDFoodItems = foodDatabaseSearchCDFoodItems {
            foodItem = foodDatabaseSearchCDFoodItems[indexPath.row]
        } else {
            foodItem = fetchedResultsController.objectAtIndexPath(indexPath) as! CDFoodItem
        }
        cell.textLabel?.text = foodItem.name
        if let bodyFont = bodyFont {
             cell.textLabel?.font = bodyFont
        } else {
            fatalError("wrong font.")
        }

    }
    
   



    
    func fetch(searchText:String? = nil) {
        let fetchRequest = NSFetchRequest(entityName: "CDFoodItem")
        let nameSort = NSSortDescriptor(key: "lastUsed", ascending: false)
        fetchRequest.sortDescriptors = [nameSort]
        if let seachText = searchText {
            let predicate = NSPredicate(format: "name = %@", seachText)
            fetchRequest.predicate = predicate
        }
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        try! fetchedResultsController.performFetch()
    }
    
    func addCDFoodItem(sender:AnyObject) {
        performSegueWithIdentifier(kSegue.AddFoodItem, sender: self)
    }
    func scanCDFoodItem(sender:AnyObject) {
        performSegueWithIdentifier(kSegue.ScanFoodItem, sender: self)
    }
    
    // MARK: - Prepare For Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        performSegueHasBeenCalled = true
        if segue.identifier == kSegue.AddFoodItem {
            let navController = segue.destinationViewController as! UINavigationController
            let destVC = navController.topViewController as! AddFoodItemViewController
            destVC.delegate = self
            destVC.foodItem = CoreDataHelper.createCDFoodItem(inManagedObjectContext: managedObjectContext)
            
        }
        if segue.identifier == kSegue.ShowDetailsOfFoodItem {
            if let destVC = segue.destinationViewController as? ShowFoodItemViewController {
                destVC.foodItem = selectedCDFoodItem
            }
        }

        if segue.identifier == kSegue.ScanFoodItem {
            if let destVC = segue.destinationViewController as? ScanFoodItemViewController {
                destVC.foodItem = selectedCDFoodItem
                destVC.delegate = self // der scanner ruft ja dann wiederum addAdmount auf. Dafür braucht er uns.
            }
        }
    }
    
    // MARK: - Searchbar
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        fetch(searchText)
    }
    
    // MARK: - Delegates
    
    func addCDFoodItemViewController(addCDFoodItemViewController: AddFoodItemViewController, didAddFoodItem foodItem: CDFoodItem?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addAmountViewController(addAmountViewController: AddAmountViewController, didAddAmount foodEntry: CDFoodEntry) {
        addAmountDelegate.addAmountViewController(addAmountViewController, didAddAmount: foodEntry)
    }

    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
}

extension NSFetchedResultsController {

    func hasObjectAtIndexPath(indexPath: NSIndexPath) -> Bool {
        if self.sections?.count > indexPath.section {
            if self.sections![indexPath.section].objects?.count > indexPath.row {
                return true
            }
        }
        return false
    }
}


