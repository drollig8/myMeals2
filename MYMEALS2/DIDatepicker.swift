//
//  TKDatepicker.swift
//  TKDatePicker
//
//  Created by Marc Felden on 01.02.16.
//  Copyright © 2016 NoName.com. All rights reserved.
//

import UIKit




extension DIDatepicker:UICollectionViewDataSource {
    
    

    
    func selectDate1(var date: NSDate?) {
        NSCalendar.currentCalendar().rangeOfUnit(.Day, startDate: &date, interval: nil, forDate: date!)
        self.selectedDate = date
        
    }

    internal func setupViews() {
        self.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        self.backgroundColor = UIColor.whiteColor()
        self.bottomLineColor = UIColor(white: 0.816, alpha: 1.000)
        self.selectedDateBottomLineColor = self.tintColor;
    }
  
    
    override internal func drawRect(rect: CGRect) {
        super.drawRect(rect)
        // draw bottom line
        let context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, self.bottomLineColor.CGColor);
        CGContextSetLineWidth(context, 0.5);
        CGContextMoveToPoint(context, 0, rect.size.height - 0.5);
        CGContextAddLineToPoint(context, rect.size.width, rect.size.height - 0.5);
        CGContextStrokePath(context);
        
       
    }
    
    func fillDatesFromDate(fromDate: NSDate, toDate: NSDate) {
        var dates = [NSDate]()
        let days = NSDateComponents()
        let calendar = NSCalendar.currentCalendar()
        var dayCount = 0
        while (true)
        {
            days.day = dayCount++
            let date = calendar.dateByAddingComponents(days, toDate: fromDate, options: NSCalendarOptions())
            if date?.compare(toDate) == NSComparisonResult.OrderedDescending {
                break;
            }
            dates.append(date!)
        }
        print(dates.count)
        self.dates = dates
    }
    
    func fillCurrentWeek1() {
        let today = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let weekdayComponents = calendar.components(.Weekday, fromDate: today)
        let componentsToSubtract = NSDateComponents()
        componentsToSubtract.day = ((weekdayComponents.weekday - calendar.firstWeekday) + 7 ) % 7
        let beginningOfWeek = calendar.dateByAddingComponents(componentsToSubtract, toDate: today, options: NSCalendarOptions())
        let componentsToAdd = NSDateComponents()
        componentsToAdd.day = 6
        let endOfWeek = calendar.dateByAddingComponents(componentsToAdd, toDate: beginningOfWeek!, options: NSCalendarOptions())
        self.fillDatesFromDate(beginningOfWeek!, toDate: endOfWeek!)
    }
    
    func fillCurrentMonth1() {
        self.fillDatesWithCalendarUnit(.Month)
    }
    
    func fillCurrentYear1() {
        self.fillDatesWithCalendarUnit(.Year)
    }

    func fillDatesWithCalendarUnit(unit: NSCalendarUnit) {
        let today = NSDate()
        let calendar = NSCalendar.currentCalendar()
        var beginning: NSDate? = nil
        var length: NSTimeInterval = 0
        calendar.rangeOfUnit(unit, startDate: &beginning, interval: &length, forDate: today)
        let end = beginning?.dateByAddingTimeInterval(length - 1)
        self.fillDatesFromDate(beginning!, toDate: end!)
        
    }
    

    
    // MARK: - Collection View Delegate
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.dates.count)
        return self.dates.count
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("kDIDatepickerCellIndentifier", forIndexPath: indexPath) as! DIDatepickerCell
        cell.date = self.dates[indexPath.item] as! NSDate
        cell.itemSelectionColor = self.selectedDateBottomLineColor
        return cell
    }
    
}



extension DIDatepicker: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !indexPath.isEqual(self.selectedIndexPath)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.datesCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        selectedDate = (self.dates[indexPath.item] as! NSDate)
        if selectedIndexPath != nil {
 //           collectionView.deselectItemAtIndexPath(selectedIndexPath!, animated: true)
        }
        selectedIndexPath = indexPath
        self.sendActionsForControlEvents(.ValueChanged)
    }
}

class DIDatepicker: UIControl {

    lazy var datesCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.itemSize = CGSizeMake(kDIDatepickerItemWidth, CGRectGetHeight(self.bounds))
        collectionViewLayout.scrollDirection = .Horizontal
        collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15)
        collectionViewLayout.minimumLineSpacing = 15
        let datesCollectionView = UICollectionView(frame: self.bounds, collectionViewLayout: collectionViewLayout)
        datesCollectionView.registerClass(DIDatepickerCell.self, forCellWithReuseIdentifier: "kDIDatepickerCellIndentifier")
        datesCollectionView.backgroundColor = UIColor.clearColor()
        datesCollectionView.showsHorizontalScrollIndicator = false
        datesCollectionView.allowsMultipleSelection = true
        datesCollectionView.dataSource = self
        datesCollectionView.delegate = self
        self.addSubview(datesCollectionView)
        return datesCollectionView
    }()
    
    var selectedDateBottomLineColor:UIColor? {
        didSet {
            let items = self.datesCollectionView.indexPathsForSelectedItems()
            if let items = items {
                for item in items {
                    if let selectedCell = self.datesCollectionView.cellForItemAtIndexPath(item) as? DIDatepickerCell {
                        selectedCell.itemSelectionColor = selectedDateBottomLineColor
                    }
                }
            }
        }
    }

    
    var dates: NSArray! {
        didSet {
            self.datesCollectionView.reloadData()
            self.selectedDate = nil
        }
    }
    var selectedIndexPath: NSIndexPath?
    

    


    var selectedDate: NSDate? {
        didSet {
            print("Setting Date to \(selectedDate)")
            if let selectedDate = selectedDate {
                let index = self.dates.indexOfObject(selectedDate)
                let selectedCellIndexPath = NSIndexPath(forItem: index, inSection: 0)
                    if let selectedIndexPath = self.selectedIndexPath {
                        self.datesCollectionView.deselectItemAtIndexPath(selectedIndexPath, animated: true)
                        self.datesCollectionView.selectItemAtIndexPath(selectedCellIndexPath, animated: true, scrollPosition: .CenteredHorizontally)
                        self.selectedIndexPath = selectedCellIndexPath
                        self.sendActionsForControlEvents(.ValueChanged)
                    }
                }
            
            }

        }
    var bottomLineColor: UIColor!

    
  
    
    
    /*
    let now = NSDate()
    var startDate: NSDate? = nil
    var duration: NSTimeInterval = 0
    let cal = NSCalendar.currentCalendar()
    
    cal.rangeOfUnit(NSCalendarUnit.WeekCalendarUnit, startDate: &startDate,
    interval: &duration, forDate: now)
    */
    

    
    func selectedDateAtIndex(index: Int) {
        self.selectedDate = (self.dates[index] as! NSDate)
    }
    func fillDatesFromDate(fromDate: NSDate, numberOfDays: Int) {
        let days = NSDateComponents()
        days.day = numberOfDays
        abort()
    }
    override func awakeFromNib() {
        setupViews()
    }

    override init(frame: CGRect) {
        self.dates = [NSDate()]
        super.init(frame: frame)
        setupViews()
    }
    init(_ coder: NSCoder? = nil) {
        if let coder = coder {
            super.init(coder: coder)!
        } else {
            super.init(frame: CGRectZero)
          //  super.init(nibName: nil, bundle:nil)
        }
    }
    required convenience init(coder: NSCoder) {
        self.init(coder)
    }
}