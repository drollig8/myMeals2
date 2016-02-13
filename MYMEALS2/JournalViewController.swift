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
    
    
    override func viewDidLoad() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "edit:")
        fetch()
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
            let newTimeString = objectInDestinationSection.timeString
            let movedObject = fetchedResultsController.objectAtIndexPath(sourceIndexPath) as! FoodEntry
            movedObject.timeString = newTimeString
            try!managedObjectContext.save()
            fetch()
            print(fetchedResultsController.sections?.count)
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == fetchedResultsController.sections!.count {
            return nil
        }
        return "Mahlzeit von " + fetchedResultsController.sections![section].name + " Uhr"// fetchedResultsController.sectionNameKeyPath  // == timeString
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
        return "Summe: \(calories) kcal"// fetchedResultsController.sectionNameKeyPath  // == timeString
    }

    // not used
    /*
    func createAttributedStringForCell(name: String, amount: String, kcal:String) -> NSAttributedString {
        
        let nameNS = name as NSString
        let amountNS = amount as NSString
        let kcalNS = kcal as NSString
        
        let resultString = NSMutableAttributedString(string: "\(nameNS) \(amountNS)\(kcalNS) kcal", attributes: nil)

        
        
        let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.Right

        let font2 = UIFont(name: "HelveticaNeue-Thin", size: 20)
        let textFontAttributes = [NSFontAttributeName: font2!, NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: textStyle]
        
        
        resultString.addAttributes([NSFontAttributeName : UIFont(name: "HelveticaNeue-Light", size: 34)!], range: NSMakeRange(0, nameNS.length))
        resultString.addAttributes([NSFontAttributeName : UIFont(name: "HelveticaNeue-Thin", size: 20)!, NSForegroundColorAttributeName : UIColor.blackColor()], range: NSMakeRange(nameNS.length + 1, amountNS.length))
        resultString.addAttributes(textFontAttributes, range: NSMakeRange(nameNS.length + amountNS.length + 1, kcalNS.length))
        return resultString
    }
    */
    
    
    // MARK: - Actions
    
    func fetch() {
        let fetchRequest = NSFetchRequest(entityName: "FoodEntry")
        let sectionSort = NSSortDescriptor(key: "timeString", ascending: true)
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [nameSort, sectionSort]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "timeString", cacheName: nil)
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