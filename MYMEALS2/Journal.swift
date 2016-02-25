//
//  JournalViewController.swift
//  MYMEALS2
//
//  Created by Marc Felden on 02.02.16.
//  Copyright © 2016 Timm Kent. All rights reserved.
//

import UIKit
import CoreData



class JournalViewController: UITableViewController,AddAmountDelegate {
    
    var managedObjectContext    : NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController!
    let cellIdentifier = "Cell"
    var editMode = false
    @IBOutlet var calendar: DIDatepicker!
    var selectedDateString: String! {
        didSet {
            if totalCaloriesValue != nil {
                updateSummaryValues()
            }
        }
    }
    var isMovingItem : Bool = false
    var selectedSection = 0
    
    @IBOutlet var totalProteinLabel: UILabel!
    @IBOutlet var totalFatLabel: UILabel!
    @IBOutlet var totalCarbLabel: UILabel!
    @IBOutlet var totalCaloriesLabel: UILabel!
    
    @IBOutlet var totalProteinValue: UILabel!
    @IBOutlet var totalFatValue: UILabel!
    @IBOutlet var totalCarbValue: UILabel!
    @IBOutlet var totalCaloriesValue: UILabel!
    
    var selectedDateOnDatepicker: NSDate = NSDate()

    private func updateSummaryValues()
    {
        totalCaloriesValue.text = "\(calculateTotalCalories(forselectedDate: selectedDateString))"
        totalCarbValue.text = "\(calculateTotalCarbs(forselectedDate: selectedDateString))"
        totalProteinValue.text = "\(calculateTotalProteins(forselectedDate: selectedDateString))"
    }
    private func setSummaryLabels()
    {
        totalCaloriesLabel?.text = "Kalorien"
        totalCarbLabel?.text = "KH"
        totalProteinLabel?.text = "Protein"
        totalFatLabel?.text = "Fett"
        totalCaloriesValue?.text = " -- "
        totalCarbValue?.text = " -- "
        totalProteinValue?.text = " -- "
        totalFatValue?.text = " -- "
    }
    
    override func viewDidLoad()
    {
        
        self.navigationItem.title = "Ernährungs-Tagebuch"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "edit:")
        calendar.fillCurrentYear()
        calendar.selectDate(NSDate())
        selectedDateString = NSDate().toDayMonthYear()
        fetch(forDateString: selectedDateString)
        addToolBarButton()
        self.tableView.editing = true
        self.tableView.allowsSelectionDuringEditing = true
        self.calendar.addTarget(self, action: "updateSelectedDate", forControlEvents: UIControlEvents.ValueChanged)
        setSummaryLabels()

    }
    
    func updateSelectedDate()
    {
        let date = calendar.selectedDate
        selectedDateString = "\(date.toDayMonthYear())"
        self.fetch(forDateString: selectedDateString)
    }
    
    // MARK: Helper Methods
    
    func addToolBarButton()
    {
        self.toolbarItems = [UIBarButtonItem(title: "Load Default", style: UIBarButtonItemStyle.Plain, target: self, action: "loadDefaults")]
        self.navigationController?.toolbarHidden = false
    }
    
    // OBSOLET so etwas gehört hier definitiv nicht hin 
    // TODO:
    private func getFoodItem(named name: String) -> FoodItem?
    {
        
        let fetchRequest = NSFetchRequest(entityName: "FoodItem")
        let predicate = NSPredicate(format: "name =%@", name)
        fetchRequest.predicate = predicate
        let foodItems = try!managedObjectContext.executeFetchRequest(fetchRequest) as! [FoodItem]
        return foodItems.first
        
    }
    
    

    
    
    private func addFoodEntry(amount amount: String? = nil, inSection section: Int, withFoodItemNamed foodName: String) -> FoodEntry
    {
        let dateString = NSDate().toDayMonthYear()
        return CoreDataHelper.addFoodEntry(dateString: dateString, inSection: section, amount: amount, unit: nil, withFoodItemNamed: foodName, inManagedObjectContext: managedObjectContext)
    }

    private func hasFoodItem(named name:String) -> Bool
    {
        return getFoodItem(named: name) != nil
        
    }
    
    func addFoodItem(named name: String, kcal: String, kohlenhydrate: String, protein: String, fett: String)
    {
        
        if !hasFoodItem(named: name) {
        
            let foodItem = NSEntityDescription.insertNewObjectForEntityForName("FoodItem", inManagedObjectContext: managedObjectContext) as! FoodItem
            foodItem.name = name
            foodItem.kohlenhydrate = kohlenhydrate
            foodItem.protein = protein
            foodItem.fett = fett
            foodItem.kcal = kcal
        
        }
    }
    

    func loadDefaults()
    {

        addFoodItem(named: "Kölln - Köln Flocken", kcal: "361", kohlenhydrate: "55,8", protein: "13,8", fett: "6,7")
        addFoodItem(named: "Hy-Pro 85 Vanille", kcal: "351", kohlenhydrate: "0,8", protein: "84,1", fett: "1,1")
        addFoodItem(named: "Heidelbeeren TK", kcal: "32", kohlenhydrate: "6,1", protein: "0,6", fett: "0,6")
        addFoodItem(named: "Nusskernmischung Seeberger", kcal: "634", kohlenhydrate: "15", protein: "17", fett: "54")
        addFoodItem(named: "Körniger Frischkäse Fitline 0,8%", kcal: "63", kohlenhydrate: "1", protein: "13", fett: "0,8")
        addFoodItem(named: "Hänchenbrust Filet", kcal: "99", kohlenhydrate: "0", protein: "23", fett: "0,8")
        addFoodItem(named: "ESN Designer Whey Vanille", kcal: "390", kohlenhydrate: "5,3", protein: "80", fett: "5,5")
        addFoodItem(named: "Bertolli Olivenöl", kcal: "819", kohlenhydrate: "0", protein: "0", fett: "91")
        addFoodItem(named: "Seeberger milde Pinienkerne", kcal: "735", kohlenhydrate: "5,8", protein: "17", fett: "71")
        addFoodItem(named: "Harry Ciabatta", kcal: "249", kohlenhydrate: "48,7", protein: "8,4", fett: "1,5")
        addFoodItem(named: "Weider Casein", kcal: "374", kohlenhydrate: "3,2", protein: "88", fett: "1")
        addFoodEntry(amount: "35", inSection: 0, withFoodItemNamed: "Kölln - Köln Flocken" )
        addFoodEntry(amount: "35", inSection: 0, withFoodItemNamed: "Hy-Pro 85 Vanille" )
        addFoodEntry(amount: "100", inSection: 0, withFoodItemNamed: "Heidelbeeren TK"  )
        addFoodEntry(amount: "30", inSection: 1, withFoodItemNamed: "Nusskernmischung Seeberger"   )
        addFoodEntry(amount: "30", inSection: 1, withFoodItemNamed: "Körniger Frischkäse Fitline 0,8%"  )
        addFoodEntry(amount: "200", inSection: 2, withFoodItemNamed: "Hänchenbrust Filet" )
        addFoodEntry(amount: "40", inSection: 3, withFoodItemNamed: "ESN Designer Whey Vanille" )
        addFoodEntry(amount: "8", inSection: 4, withFoodItemNamed: "Bertolli Olivenöl" )
        addFoodEntry(amount: "8", inSection: 4, withFoodItemNamed: "Seeberger milde Pinienkerne" )
        addFoodEntry(amount: "60", inSection: 4, withFoodItemNamed: "Harry Ciabatta" )
        addFoodEntry(amount: "40", inSection: 5, withFoodItemNamed: "Weider Casein" )
        try!self.managedObjectContext.save()
        self.fetch()

    }
    

    // MARK: - UITableView
    
    let kNumberOfSection = 6
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return  kNumberOfSection
    }
    
    func getNumberOfFoodEntries(inSection section: Int) -> Int
    {
        let foodEntries = CoreDataHelper.getFoodEntries(forDateString: selectedDateString, inSection: section, inmanagedObjectContext: managedObjectContext)
        return foodEntries.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
     
        let numberOfRowsInSection = getNumberOfFoodEntries(inSection: section)
        if editMode {
            return numberOfRowsInSection }
        else {
            return numberOfRowsInSection + 1
        }

    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! JournalCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    
    

    
    func configureCell(cell: JournalCell, atIndexPath indexPath: NSIndexPath)
    {
        let numberOfRowsInSection = getNumberOfFoodEntries(inSection: indexPath.section)

        if indexPath.row == numberOfRowsInSection {
            
            cell.name.text = "Eintrag hinzufügen"
            cell.kcal.text = ""
            
        } else {
            
            let foodEntry = fetchedResultsController.objectAtIndexPath(indexPath) as? FoodEntry
            if let foodEntry = foodEntry {
                
                // TODO: Diesen Teil hier raus nehmen
                if foodEntry.foodItemRel != nil {
                    let foodItem = foodEntry.foodItemRel! as FoodItem
                    let name = foodItem.name
                    
                    let kalories = foodItem.kcal?.toInt() ?? 0
                    let carbs = foodItem.kohlenhydrate?.toInt() ?? 0
                    let proteins = foodItem.protein?.toInt() ?? 0
                    let fats = foodItem.fett?.toInt() ?? 0
                    
                    let amount = foodEntry.amount?.toInt() ?? 0
                    let unit = foodEntry.unit
                    let kcalOfEntry = kalories * amount / 100
                    let kcalOfEntryString = "\(kcalOfEntry)"
                    let nameString = name ?? ""
                    let unitString = unit ?? ""
                    
                    cell.name.text = "\(nameString) \(amount)\(unitString)"
                    cell.kcal.text = "\(kcalOfEntryString) kcal"
                    
                    let carbsOfEntry = carbs * amount / 100
                    let proteinsOfEntry = proteins * amount / 100
                    let fatsOfEntry = fats * amount / 100
                    
                    cell.details.text = "KH: \(carbsOfEntry)g, Protein: \(proteinsOfEntry)g, Fett: \(fatsOfEntry)g"
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        if isAddEntry(indexPath) {
            return false
        }
        if !self.editMode { return false }
        return true
    }
    
    private func isAddEntry(indexPath:NSIndexPath) -> Bool
    {
        return indexPath.row == getNumberOfFoodEntries(inSection: indexPath.section)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        if isAddEntry(indexPath) {
            addEntry(indexPath.section)
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
    
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
        let numberOfRowsInSection = getNumberOfFoodEntries(inSection: indexPath.section)
        
        if indexPath.row == numberOfRowsInSection && !self.editMode {
            return UITableViewCellEditingStyle.Insert
        }

        if editMode {
            return UITableViewCellEditingStyle.Delete
        }
        return UITableViewCellEditingStyle.None
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        
        if editingStyle == .Delete {
     
            let object = fetchedResultsController.objectAtIndexPath(indexPath) as! FoodEntry
            managedObjectContext?.deleteObject(object)
            try!managedObjectContext?.save()
            self.fetch()
        }
        
        if editingStyle == .Insert {
            addEntry(0)
        }
        
        updateSummaryValues()
        
    }
    

    
 
    private func indexIsOutOfRange(indexPath:NSIndexPath) -> Bool
    {
        if indexPath.section > self.fetchedResultsController.sections!.count - 1 {
            return true
        }
        if indexPath.row > self.fetchedResultsController.sections![indexPath.section].objects!.count - 1 {
            return true
        }
        return false
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
    {
        if indexIsOutOfRange(destinationIndexPath) {
            return
        }

        isMovingItem = true
        
        
        if sourceIndexPath.section == destinationIndexPath.section {
            if var todos = self.fetchedResultsController.sections![sourceIndexPath.section].objects {
                let todo = todos[sourceIndexPath.row] as! FoodEntry
                todos.removeAtIndex(sourceIndexPath.row)
                todos.insert(todo, atIndex: destinationIndexPath.row)
                
                var idx = 1
                for todo in todos as! [FoodEntry] {
                    todo.sortOrder = NSNumber(integer: idx++)
                }
                try!managedObjectContext.save()
            }
        } else {

            if var allObjectInSourceSection = fetchedResultsController.sections![sourceIndexPath.section].objects {
                let object = allObjectInSourceSection[sourceIndexPath.row] as! FoodEntry
                allObjectInSourceSection.removeAtIndex(sourceIndexPath.row)

                for (index,object) in (allObjectInSourceSection as! [FoodEntry]).enumerate() {
                    object.sortOrder = NSNumber(integer: index)
                }
            
            
                if var allObjectInDestinationSection = fetchedResultsController.sections![destinationIndexPath.section].objects {
                
                    allObjectInDestinationSection.insert(object, atIndex: destinationIndexPath.row)
            
                    for (index,object) in (allObjectInDestinationSection as! [FoodEntry]).enumerate() {
                        object.sortOrder = NSNumber(integer: index)
                        object.section = NSNumber(integer: destinationIndexPath.section)
                    }
                }
            }
            
        }

        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            tableView.reloadRowsAtIndexPaths(tableView.indexPathsForVisibleRows!, withRowAnimation: .Fade)
        })
        
        isMovingItem = false
        
        try!managedObjectContext.save()
        
        fetch()
        
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
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
    
    private func getFoodEntriesForSection(section: Int) -> [FoodEntry]
    {
        return CoreDataHelper.getFoodEntries(forDateString: selectedDateString, inSection: section, inmanagedObjectContext: managedObjectContext)
    }
    
    enum NutritinalValue {
        case Calories, Carbs, Protein, Fat
    }
    
    private func getNutritionalValueFromFoodEntries(foodEntries:[FoodEntry], withValue nutricionalValue: NutritinalValue)  -> Int
    {
        var totalCalories = 0
        for foodEntry in foodEntries {
            
            let amountInt = foodEntry.amount?.toInt() ?? 0
            var value = 0
            if nutricionalValue == .Calories {
                value = foodEntry.foodItemRel?.kcal?.toInt() ?? 0
            }
            if nutricionalValue == .Carbs {
                value = foodEntry.foodItemRel?.kohlenhydrate?.toInt() ?? 0
            }
            if nutricionalValue == .Protein {
                value = foodEntry.foodItemRel?.protein?.toInt() ?? 0
            }
            totalCalories += (amountInt * value)/100
        }
        return totalCalories
    }
    
    private func getCaloriesFromFoodEntries(foodEntries:[FoodEntry]) -> Int
    {
        return getNutritionalValueFromFoodEntries(foodEntries, withValue: .Calories)
    }
    
    private func getCarbsFromFoodEntries(foodEntries:[FoodEntry]) -> Int
    {
        return getNutritionalValueFromFoodEntries(foodEntries, withValue: .Carbs)
    }
    
    private func getProteinsFromFoodEntries(foodEntries:[FoodEntry]) -> Int
    {
        return getNutritionalValueFromFoodEntries(foodEntries, withValue: .Protein)
    }
    
    

    private func calculateTotalCalories(forselectedDate selectedDateString: String) -> Int
    {
        
        let foodEntries = CoreDataHelper.getFoodEntries(forDateString: selectedDateString, inmanagedObjectContext: managedObjectContext)
        let result = getCaloriesFromFoodEntries(foodEntries)
        return result
    }
    
    private func calculateTotalCarbs(forselectedDate selectedDateString: String) -> Int
    {
        
        let foodEntries = CoreDataHelper.getFoodEntries(forDateString: selectedDateString, inmanagedObjectContext: managedObjectContext)
        let result = getCarbsFromFoodEntries(foodEntries)
        return result
    }
    
    private func calculateTotalProteins(forselectedDate selectedDateString: String) -> Int
    {
        
        let foodEntries = CoreDataHelper.getFoodEntries(forDateString: selectedDateString, inmanagedObjectContext: managedObjectContext)
        let result = getProteinsFromFoodEntries(foodEntries)
        return result
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String?
    {
        let foodEntries = getFoodEntriesForSection(section)
        let totalCalories = getCaloriesFromFoodEntries(foodEntries)
        return "Summe: \(totalCalories) kcal"
    }

   
    // MARK: - Actions
    
    func fetch(forDateString dateString: String? = nil)
    {
        
        let fetchRequest = NSFetchRequest(entityName: "FoodEntry")
        let sectionSort = NSSortDescriptor(key: "section", ascending: true)
        let sortOrder = NSSortDescriptor(key: "sortOrder", ascending: true)
        fetchRequest.sortDescriptors = [sectionSort, sortOrder]
        if let dateString = selectedDateString {
            let predicate = NSPredicate(format: "dateString == %@", dateString)
            fetchRequest.predicate = predicate
        }
        assert(managedObjectContext != nil)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "section", cacheName: nil)
        try! fetchedResultsController.performFetch()
        self.tableView.reloadData()
    }
    
    func addEntry(section:Int)
    {
        self.selectedSection = section
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("FoodItemsViewController") as! FoodItemsViewController
        let foodEntry = CoreDataHelper.addFoodEntry(dateString: selectedDateString, inSection: section, inManagedObjectContext: managedObjectContext)
        viewController.foodEntry = foodEntry
        viewController.managedObjectContext = managedObjectContext
        viewController.addAmountDelegate = self
      //  self.navigationController?.pushViewController(viewController, animated: false)
        // UNTESTED
        let navigationController = UINavigationController()
        navigationController.viewControllers.append(viewController)
        self.presentViewController(navigationController, animated: false, completion: nil)
        
    }
    
    func edit(sender:AnyObject)
    {
        if self.editMode {
            self.editMode = false
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "edit:")
        } else {
            self.editMode = true
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "edit:")
        }
        tableView.reloadData()
    }
    
    // MARK: - Delegate Methods
    
    func addAmountViewController(addAmountViewController: AddAmountViewController, didAddAmount foodEntry: FoodEntry)
    {
        fetch()
        tableView.reloadData()
        assert(foodEntry.name != nil)
        dismissViewControllerAnimated(true, completion: nil)
    }
}

class JournalCell: UITableViewCell
{
    @IBOutlet weak var kcal: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var details: UILabel!
    
}