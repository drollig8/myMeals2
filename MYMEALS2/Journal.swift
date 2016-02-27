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
    

    
    

    
    
    private func addCDFoodEntry(amount amount: Double? = nil, inSection section: Int, withCDFoodItemNamed foodName: String) -> CDFoodEntry
    {
        let dateString = NSDate().toDayMonthYear()
        return CoreDataHelper.addCDFoodEntry(dateString: dateString, inSection: section, amount: amount, unit: nil, withCDFoodItemNamed: foodName, inManagedObjectContext: managedObjectContext)
    }


    
    func addCDFoodItem(named name: String, kcal: String, carbs: String, protein: String, fett: String)
    {
        
        CoreDataHelper.createCDFoodItem(name: name, kcal: kcal, carbs: carbs, protein: protein, fat: fett, inManagedObjectContext: managedObjectContext)
        
        /*
        if !hasCDFoodItem(named: name) {
        
            let foodItem = NSEntityDescription.insertNewObjectForEntityForName("CDFoodItem", inManagedObjectContext: managedObjectContext) as! CDFoodItem
            foodItem.name = name
            foodItem.carbs = carbs
            foodItem.protein = protein
            foodItem.fett = fett
            foodItem.kcal = kcal
        
        }
        */
    }
    

    func loadDefaults()
    {

        addCDFoodItem(named: "Kölln - Köln Flocken", kcal: "361", carbs: "55,8", protein: "13,8", fett: "6,7")
        addCDFoodItem(named: "Hy-Pro 85 Vanille", kcal: "351", carbs: "0,8", protein: "84,1", fett: "1,1")
        addCDFoodItem(named: "Heidelbeeren TK", kcal: "32", carbs: "6,1", protein: "0,6", fett: "0,6")
        addCDFoodItem(named: "Nusskernmischung Seeberger", kcal: "634", carbs: "15", protein: "17", fett: "54")
        addCDFoodItem(named: "Körniger Frischkäse Fitline 0,8%", kcal: "63", carbs: "1", protein: "13", fett: "0,8")
        addCDFoodItem(named: "Hänchenbrust Filet", kcal: "99", carbs: "0", protein: "23", fett: "0,8")
        addCDFoodItem(named: "ESN Designer Whey Vanille", kcal: "390", carbs: "5,3", protein: "80", fett: "5,5")
        addCDFoodItem(named: "Bertolli Olivenöl", kcal: "819", carbs: "0", protein: "0", fett: "91")
        addCDFoodItem(named: "Seeberger milde Pinienkerne", kcal: "735", carbs: "5,8", protein: "17", fett: "71")
        addCDFoodItem(named: "Harry Ciabatta", kcal: "249", carbs: "48,7", protein: "8,4", fett: "1,5")
        addCDFoodItem(named: "Weider Casein", kcal: "374", carbs: "3,2", protein: "88", fett: "1")
        addCDFoodEntry(amount: 35, inSection: 0, withCDFoodItemNamed: "Kölln - Köln Flocken" )
        addCDFoodEntry(amount: 35, inSection: 0, withCDFoodItemNamed: "Hy-Pro 85 Vanille" )
        addCDFoodEntry(amount: 100, inSection: 0, withCDFoodItemNamed: "Heidelbeeren TK"  )
        addCDFoodEntry(amount: 30, inSection: 1, withCDFoodItemNamed: "Nusskernmischung Seeberger"   )
        addCDFoodEntry(amount: 30, inSection: 1, withCDFoodItemNamed: "Körniger Frischkäse Fitline 0,8%"  )
        addCDFoodEntry(amount: 200, inSection: 2, withCDFoodItemNamed: "Hänchenbrust Filet" )
        addCDFoodEntry(amount: 40, inSection: 3, withCDFoodItemNamed: "ESN Designer Whey Vanille" )
        addCDFoodEntry(amount: 8, inSection: 4, withCDFoodItemNamed: "Bertolli Olivenöl" )
        addCDFoodEntry(amount: 8, inSection: 4, withCDFoodItemNamed: "Seeberger milde Pinienkerne" )
        addCDFoodEntry(amount: 60, inSection: 4, withCDFoodItemNamed: "Harry Ciabatta" )
        addCDFoodEntry(amount: 40, inSection: 5, withCDFoodItemNamed: "Weider Casein" )
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
            
            let foodEntry = fetchedResultsController.objectAtIndexPath(indexPath) as? CDFoodEntry
            if let foodEntry = foodEntry {
                
                // TODO: Refactorisieren!
                if foodEntry.foodItemRel != nil {
                    let foodItem = foodEntry.foodItemRel! as CDFoodItem
                    let name = foodItem.name
                    
                    let kalories = foodItem.kcal?.toInt() ?? 0
                    let carbs = foodItem.carbs?.toInt() ?? 0
                    let proteins = foodItem.protein?.toInt() ?? 0
                    let fats = foodItem.fett?.toInt() ?? 0
                    
                    let amount = foodEntry.amount?.doubleValue ?? 0
                    let unit = foodEntry.unit
                    let kcalOfEntry = Double(kalories) * amount / 100
                    let kcalOfEntryString = NSString(format: "%0.f", kcalOfEntry) as String
                    let nameString = name ?? ""
                    let unitString = unit ?? ""
                    
                    let amountString = NSString(format: "%0.f", amount) as String
                    
                    cell.name.text = "\(nameString) \(amountString)\(unitString)"
                    cell.kcal.text = "\(kcalOfEntryString) kcal"
                    
                    let carbsOfEntry = Double(carbs) * amount / 100
                    let proteinsOfEntry = Double(proteins) * amount / 100
                    let fatsOfEntry = Double(fats) * amount / 100
                 
                    let text = NSString(format: "KH: %0.fg, Protein: %0.fg, Fett: %0.fg", carbsOfEntry,proteinsOfEntry,fatsOfEntry )

                    cell.details.text = text as String
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
                let editCDFoodItemViewController = storyboard.instantiateViewControllerWithIdentifier("EditFoodItemViewController") as! EditFoodItemViewController
                self.navigationController?.pushViewController(editCDFoodItemViewController, animated: false) // true not possible for unit testing
            }
            
            else {
                let showCDFoodItemViewController = storyboard.instantiateViewControllerWithIdentifier("ShowFoodItemViewController") as! ShowFoodItemViewController
                self.navigationController?.pushViewController(showCDFoodItemViewController, animated: false) // true not possible for unit testing
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
     
            let object = fetchedResultsController.objectAtIndexPath(indexPath) as! CDFoodEntry
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
                let todo = todos[sourceIndexPath.row] as! CDFoodEntry
                todos.removeAtIndex(sourceIndexPath.row)
                todos.insert(todo, atIndex: destinationIndexPath.row)
                
                var idx = 1
                for todo in todos as! [CDFoodEntry] {
                    todo.sortOrder = NSNumber(integer: idx++)
                }
                try!managedObjectContext.save()
            }
        } else {

            if var allObjectInSourceSection = fetchedResultsController.sections![sourceIndexPath.section].objects {
                let object = allObjectInSourceSection[sourceIndexPath.row] as! CDFoodEntry
                allObjectInSourceSection.removeAtIndex(sourceIndexPath.row)

                for (index,object) in (allObjectInSourceSection as! [CDFoodEntry]).enumerate() {
                    object.sortOrder = NSNumber(integer: index)
                }
            
            
                if var allObjectInDestinationSection = fetchedResultsController.sections![destinationIndexPath.section].objects {
                
                    allObjectInDestinationSection.insert(object, atIndex: destinationIndexPath.row)
            
                    for (index,object) in (allObjectInDestinationSection as! [CDFoodEntry]).enumerate() {
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
    
    private func getFoodEntriesForSection(section: Int) -> [CDFoodEntry]
    {
        return CoreDataHelper.getFoodEntries(forDateString: selectedDateString, inSection: section, inmanagedObjectContext: managedObjectContext)
    }
    
    enum NutritinalValue {
        case Calories, Carbs, Protein, Fat
    }
    
    private func getNutritionalValueFromFoodEntries(foodEntries:[CDFoodEntry], withValue nutricionalValue: NutritinalValue)  -> Int
    {
        var totalCalories:Double = 0
        for foodEntry in foodEntries {
            
            let amountInt = foodEntry.amount?.doubleValue ?? 0
            var value = 0
            if nutricionalValue == .Calories {
                value = foodEntry.foodItemRel?.kcal?.toInt() ?? 0
            }
            if nutricionalValue == .Carbs {
                value = foodEntry.foodItemRel?.carbs?.toInt() ?? 0
            }
            if nutricionalValue == .Protein {
                value = foodEntry.foodItemRel?.protein?.toInt() ?? 0
            }
            totalCalories += (amountInt * Double(value))/100
        }
        return Int(totalCalories)
    }
    
    private func getCaloriesFromFoodEntries(foodEntries:[CDFoodEntry]) -> Int
    {
        return getNutritionalValueFromFoodEntries(foodEntries, withValue: .Calories)
    }
    
    private func getCarbsFromFoodEntries(foodEntries:[CDFoodEntry]) -> Int
    {
        return getNutritionalValueFromFoodEntries(foodEntries, withValue: .Carbs)
    }
    
    private func getProteinsFromFoodEntries(foodEntries:[CDFoodEntry]) -> Int
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
        
        let fetchRequest = NSFetchRequest(entityName: "CDFoodEntry")
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
        let foodEntry = CoreDataHelper.addCDFoodEntry(dateString: selectedDateString, inSection: section, inManagedObjectContext: managedObjectContext)
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
    
    func addAmountViewController(addAmountViewController: AddAmountViewController, didAddAmount foodEntry: CDFoodEntry)
    {
        fetch()
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
}

class JournalCell: UITableViewCell
{
    @IBOutlet weak var kcal: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var details: UILabel!
    
}