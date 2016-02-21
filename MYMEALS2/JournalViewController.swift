//
//  JournalViewController.swift
//  MYMEALS2
//
//  Created by Marc Felden on 02.02.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import UIKit
import CoreData

class JournalViewController: UITableViewController {
    
    var managedObjectContext    : NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController!
    let cellIdentifier = "Cell"
    
    @IBOutlet weak var calendar: DIDatepicker!
    var selectedDateOnDatepicker: NSDate = NSDate() {
        didSet {
            calendar?.selectDate(selectedDateOnDatepicker)
        }
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "Ernährungs-Tagebuch"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "edit:")
        calendar.fillCurrentYear()
        calendar.selectDate(selectedDateOnDatepicker)
        fetch()
        addToolBarButton()

    }
    
    // MARK: Helper Methods
    
    func addToolBarButton() {

        self.toolbarItems = [UIBarButtonItem(title: "Load Default", style: UIBarButtonItemStyle.Plain, target: self, action: "loadDefaults:")]
        self.navigationController?.toolbarHidden = false
    }
    
    private func getFoodItem(named name: String) -> FoodItem? {
        
        let fetchRequest = NSFetchRequest(entityName: "FoodItem")
        let predicate = NSPredicate(format: "name =%@", name)
        fetchRequest.predicate = predicate
        let foodItems = try!managedObjectContext.executeFetchRequest(fetchRequest) as! [FoodItem]
        return foodItems.first
        
    }
    func addFoodEntry(named name: String, amount: String? = nil, inSection section: Int, withFoodItemNamed foodItemName: String?=nil) -> FoodEntry {

        var foodItem : FoodItem?
        
        if let foodItemName = foodItemName {
            
            foodItem = getFoodItem(named: foodItemName)
            
        }
        
        let foodEntry = NSEntityDescription.insertNewObjectForEntityForName("FoodEntry", inManagedObjectContext: managedObjectContext) as! FoodEntry
        
        foodEntry.name = name
        
        if let amount = amount {
            
            foodEntry.amount = amount
            foodEntry.section = NSNumber(integer: section)
            foodEntry.foodItemRel = foodItem
            
        }
        
        return foodEntry
        
    }
    
    private func hasFoodItem(named name:String) -> Bool {
        
        if getFoodItem(named: name) != nil {
            return true
        }
        return false
        
    }
    
    func addFoodItem(named name: String, kcal: String, kohlenhydrate: String, protein: String, fett: String) {
        
        if !hasFoodItem(named: name) {
        
            let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
            foodItem.name = name
            foodItem.kohlenhydrate = kohlenhydrate
            foodItem.protein = protein
            foodItem.fett = fett
        
        }
    }
    

    func loadDefaults(sender: AnyObject) {

        addFoodItem(named: "Kölln - Köln Flocken", kcal: "361", kohlenhydrate: "55.8", protein: "13.8", fett: "6.7")
        addFoodItem(named: "Hy-Pro 85 Vanille", kcal: "351", kohlenhydrate: "0.8", protein: "84.1", fett: "1.1")
        addFoodItem(named: "Heidelbeeren TK", kcal: "32", kohlenhydrate: "6.1", protein: "0.6", fett: "0.6")
        addFoodItem(named: "Nusskernmischung Seeberger", kcal: "634", kohlenhydrate: "15", protein: "17", fett: "54")
        addFoodItem(named: "Körniger Frischkäse Fitline 0.8%", kcal: "63", kohlenhydrate: "1", protein: "13", fett: "0,8")
        addFoodItem(named: "Hänchenbrust Filet", kcal: "99", kohlenhydrate: "0", protein: "23", fett: "0,8")
        addFoodItem(named: "ESN Designer Whey Vanille", kcal: "390", kohlenhydrate: "5,3", protein: "80", fett: "5,5")
        addFoodItem(named: "Bertolli Olivenöl", kcal: "819", kohlenhydrate: "0", protein: "0", fett: "91")
        addFoodItem(named: "Seeberger milde Pinienkerne", kcal: "735", kohlenhydrate: "5,8", protein: "17", fett: "71")
        addFoodItem(named: "Harry Ciabatta", kcal: "249", kohlenhydrate: "48,7", protein: "8,4", fett: "1,5")
        addFoodItem(named: "Weider Casein", kcal: "374", kohlenhydrate: "3,2", protein: "88", fett: "1")
        addFoodEntry(named: "Test", amount: "35", inSection: 0, withFoodItemNamed: "Kölln - Köln Flocken" )
        addFoodEntry(named: "Test", amount: "", inSection: 1  )
        addFoodEntry(named: "Test", amount: "", inSection: 1  )
        addFoodEntry(named: "Test", amount: "", inSection: 1  )
        addFoodEntry(named: "Test", amount: "", inSection: 1 )

        try!self.managedObjectContext.save()
        
        self.tableView.reloadData()
    }
    

    // MARK: - UITableView
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return  fetchedResultsController.sections!.count + 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == fetchedResultsController.sections!.count {
            return 1  // + section
        }
        return fetchedResultsController.sections![section].objects!.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == fetchedResultsController.sections!.count {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! JournalCell
            cell.name.text = "                  add Entry" // TODO das ist nicht schön so !!!
            cell.kcal.text = ""
            cell.imageView?.image = UIImage(named: "add-icon")
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! JournalCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: JournalCell, atIndexPath indexPath: NSIndexPath) {
        let foodEntry = fetchedResultsController.objectAtIndexPath(indexPath) as! FoodEntry
        let foodItem = foodEntry.foodItemRel! as FoodItem
        let name = foodItem.name
        let kalories = foodItem.kcal?.toInt() ?? 0
        let amount = foodEntry.amount?.toInt() ?? 0
        let unit = foodEntry.unit
        let kcalOfEntry = kalories * amount / 100
        let kcalOfEntryString = "\(kcalOfEntry)"

        let nameString = name ?? ""
        let unitString = unit ?? ""
        
        cell.name.text = "\(nameString) \(amount)\(unitString)"
        cell.kcal.text = "\(kcalOfEntryString) kcal"
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == fetchedResultsController.sections?.count {
            return false
        }
        return true
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == fetchedResultsController.sections?.count {
            return false
        }
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == fetchedResultsController.sections?.count {
            addEntry(self)
        } else {
    
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if self.editing {
                let editFoodItemViewController = storyboard.instantiateViewControllerWithIdentifier("EditFoodItemViewController") as! EditFoodItemViewController
                self.navigationController?.pushViewController(editFoodItemViewController, animated: false) // true not possible for unit testing
            }
            
            else {
                let showFoodItemViewController = storyboard.instantiateViewControllerWithIdentifier("ShowFoodItemViewController") as! ShowFoodItemViewController
                self.navigationController?.pushViewController(showFoodItemViewController, animated: false) // true not possible for unit testing
            }
        }

    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let object = fetchedResultsController.objectAtIndexPath(indexPath) as! FoodEntry
            managedObjectContext?.deleteObject(object)
            try!object.managedObjectContext?.save()
            self.fetch()
        }
    }
    

    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        // es wird in eine andere Section gezogen
        if sourceIndexPath.section != destinationIndexPath.section {
            let destinationSection = destinationIndexPath.section
            let objectInDestinationSection = fetchedResultsController.sections![destinationSection].objects![0] as! FoodEntry
            let newSection = objectInDestinationSection.section
            let movedObject = fetchedResultsController.objectAtIndexPath(sourceIndexPath) as! FoodEntry
            movedObject.section = newSection
            try!managedObjectContext.save()
            fetch()
            print(fetchedResultsController.sections?.count)
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Frühstück"
        case 1: return "2. Frühstück"
        case 2: return "Mittagessen"
        case 3: return "Post-Workout-Shake"
        case 4: return "Abendbrot"
        case 5: return "Nachtisch"
        default: return ""
        }
        
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == fetchedResultsController.sections!.count {
            return nil
        }
        let entriesInSection = fetchedResultsController.sections![section].objects as! [FoodEntry]
        var calories = 0
        for entryInSection in entriesInSection {
            let amountInt = entryInSection.amount?.toInt() ?? 0
            let kcalOfEntry = entryInSection.foodItemRel?.kcal?.toInt() ?? 0
            calories = calories + (amountInt * kcalOfEntry)/100
        }
        return "Summe: \(calories) kcal"
    }


    
    
    // MARK: - Actions
    
    func fetch() {
        let fetchRequest = NSFetchRequest(entityName: "FoodEntry")
        let sectionSort = NSSortDescriptor(key: "section", ascending: true)
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [nameSort, sectionSort]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "section", cacheName: nil)
        try! fetchedResultsController.performFetch()
    }
    
    func addEntry(sender:AnyObject) {
        print("Adding Entry")
        print(self.navigationController?.viewControllers.count)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("FoodItemsViewController") as! FoodItemsViewController
        viewController.managedObjectContext = managedObjectContext
        self.navigationController?.pushViewController(viewController, animated: false)
        print(self.navigationController?.viewControllers.count)
    }
    
    func edit(sender:AnyObject)  {
        if self.editing {
            self.editing = false
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "edit:")
        } else {
            self.editing = true
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "edit:")
        }
    }
}

class JournalCell: UITableViewCell {
    @IBOutlet weak var kcal: UILabel!
    @IBOutlet weak var name: UILabel!
    
}