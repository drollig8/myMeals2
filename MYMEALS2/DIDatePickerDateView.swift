//
//  TKDatePickerDateView.swift
//  TKDatePicker
//
//  Created by Marc Felden on 01.02.16.
//  Copyright © 2016 NoName.com. All rights reserved.
//

import UIKit

let kDIDatepickerItemWidth:CGFloat = 46
let kDIDatepickerSelectionLineWidth:CGFloat = 51

class TKDatepickerCell: UICollectionViewCell {
    var date:NSDate! {
        didSet {
            
            if let dateFormatter = dateFormatter {
            dateFormatter.dateFormat = "dd"
            let dayFormattedString = dateFormatter.stringFromDate(date) as NSString
            let dayInWeekFormattedString = dateFormatter.stringFromDate(date) as NSString
            let monthFormattedString = dateFormatter.stringFromDate(date).uppercaseString as NSString
            let dateString = NSMutableAttributedString(string: "\(dayFormattedString) \(dayInWeekFormattedString)\n\(monthFormattedString)", attributes: nil)
            dateString.addAttributes([NSFontAttributeName : UIFont(name: "HelveticaNeue-Thin", size: 20)!], range: NSMakeRange(0, dayFormattedString.length))
            dateString.addAttributes([NSFontAttributeName : UIFont(name: "HelveticaNeue-Thin", size: 8)!, NSForegroundColorAttributeName : UIColor.blackColor()], range: NSMakeRange(dayFormattedString.length + 1, dayInWeekFormattedString.length))
            dateString.addAttributes([NSFontAttributeName : UIFont(name: "HelveticaNeue-Light", size: 8)!, NSForegroundColorAttributeName : UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)], range: NSMakeRange(dateString.length - monthFormattedString.length, monthFormattedString.length))
            if self.isWeekday(date) {
                dateString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Medium", size: 8)!, range: NSMakeRange(dayFormattedString.length + 1, dayInWeekFormattedString.length))
            }
            self.dateLabekl.attributedText = dateString
            }
        }
    }
    var itemSelectionColor: UIColor! {
        didSet {
            if self.selectionView != nil {
            self.selectionView.backgroundColor = itemSelectionColor
            }
        }
    }
    var dateLabekl: UILabel!
    var selectionView: UIView!
    var dateFormatter: NSDateFormatter?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }

    override func prepareForReuse() {
        self.selected = false
        self.selectionView.alpha = 0
    }
    
   func setHighlightedNeu(highlighted: Bool) {
        super.highlighted = highlighted
        self.selectionView.hidden = false
        if highlighted {
            self.selectionView.alpha = self.selected ? 1 : 0.5
        } else {
            self.selectionView.alpha = self.selected ? 1 : 0.0
        }
    }
  
    func setSelectedNeu(selected: Bool) {
        super.selected = selected
        self.selectionView.hidden = false
        self.selectionView.alpha = self.selected ? 1 : 0.0
    }
    func isWeekday(date: NSDate) -> Bool {
        
        let day = NSCalendar.currentCalendar().components(NSCalendarUnit.Weekday, fromDate: date).weekday
        let kSunday = 1
        let kSaturday = 7
        let isWeekdayResult = day == kSunday || day == kSaturday
        return isWeekdayResult
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}