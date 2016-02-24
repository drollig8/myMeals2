//
//  Extension+NSDate
//  DMV
//
//  Created by Marc Felden on 14.10.15.
//  Copyright © 2015 Marc Felden. All rights reserved.
//

import Foundation

public func >(l: NSDate, r: NSDate) -> Bool {
    return l.compare(r) == NSComparisonResult.OrderedDescending
}
public func >=(l: NSDate, r: NSDate) -> Bool {
    return l.compare(r) == NSComparisonResult.OrderedDescending || l == r
}
public func <(l: NSDate, r: NSDate) -> Bool {
    return l.compare(r) == NSComparisonResult.OrderedAscending
}
public func <=(l: NSDate, r: NSDate) -> Bool {
    return l.compare(r) == NSComparisonResult.OrderedAscending || l == r
}


struct DateRange : SequenceType {
    
    var calendar: NSCalendar
    var startDate: NSDate
    var endDate: NSDate
    var stepUnits: NSCalendarUnit
    var stepValue: Int
    
    func generate() -> Generator {
        return Generator(range: self)
    }
    
    struct Generator: GeneratorType {
        
        var range: DateRange
        
        mutating func next() -> NSDate? {
            let nextDate = range.calendar.dateByAddingUnit(range.stepUnits,
                value: range.stepValue,
                toDate: range.startDate,
                options: NSCalendarOptions())
            if range.endDate < nextDate! {
                return nil
            }
            else {
                range.startDate = nextDate!
                return nextDate
            }
        }
    }
}

extension NSDate {
    
    func toDayMonthYear1() -> String {
        
        struct Statics {
            static var formatter : NSDateFormatter = {
                let fmt = NSDateFormatter()
                fmt.dateFormat = "dd.MM.yy"
                return fmt
            }()
        }
        
        return Statics.formatter.stringFromDate(self)
    }
}

extension NSDate {
    func toDayMonthYear() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter.stringFromDate(self)
    }
    
    func toMonthYear() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM.yy"
        return formatter.stringFromDate(self)
    }
    
    func toDayMonth() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter.stringFromDate(self)
    }
    
    func getDayFromDate(date:NSDate) -> String {
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(.Weekday, fromDate: self)
        let weekDay = myComponents.weekday
        var dayDay = ""
        switch weekDay {
        case 0: dayDay = "Sa"
        case 1: dayDay = "So"
        case 2: dayDay = "Mo"
        case 3: dayDay = "Di"
        case 4: dayDay = "Mi"
        case 5: dayDay = "Do"
        case 6: dayDay = "Fr"
        case 7: dayDay = "Sa"
        default: dayDay = "XX"
        }
        return dayDay
    }
    
    func getDayFromDateLong(date:NSDate) -> String {
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(.Weekday, fromDate: self)
        let weekDay = myComponents.weekday
        var dayDay = ""
        switch weekDay {
        case 0: dayDay = "Samstag"
        case 1: dayDay = "Sonntag"
        case 2: dayDay = "Montag"
        case 3: dayDay = "Dienstag"
        case 4: dayDay = "Mittwoch"
        case 5: dayDay = "Donnerstag"
        case 6: dayDay = "Freitag"
        case 7: dayDay = "Samstag"
        default: dayDay = "XX"
        }
        return dayDay
    }
    
    // get Mo., 15.09.2015 from NSDate
    func toDayWithLeadingZero() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd"
        return formatter.stringFromDate(self)
    }
    
    func toMonthThreeCiphers() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.stringFromDate(self)
    }
    
    // get Mo., 15.09.2015 from NSDate
    func toDayDayMonthYear() -> String {
        
        let dayDay = getDayFromDate(self)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return dayDay + "., "+formatter.stringFromDate(self)
    }
    
    // get Mo., 15.09.2015 16:15 from NSDate
    func toDayDayMonthYearHourMinute() -> String {
        let dayDay = getDayFromDate(self)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd.MM.yy HH:mm"
        return dayDay + "., "+formatter.stringFromDate(self)
    }
    
    func toDayDayMonthYearHourMinuteLong() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd. MMMM yyyy, HH:mm"
        return formatter.stringFromDate(self)
    }

    
    func toHourMinute() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.stringFromDate(self)
    }
    
    func toMillisecondsSince1970000() -> String? {
        let seconds = self.timeIntervalSince1970
        let string = "\(Int64(seconds))000"
        return string
    }
    func toMillisecondsSince1970() -> String? {
        let seconds = self.timeIntervalSince1970
        let intSeconds = Int(seconds)
        let str:String = "\(intSeconds)"
        return str
    }
    

    func toJSONDate() -> String {
        if let datePart = self.toMillisecondsSince1970() {
            return "/Date(\(datePart)+0000)/"
        } else {
            print("Error: Could not convert toJSONDate returning /Date(00000+0000)/")
            return "/Date(00000+0000)/"
        }
    }
}


extension NSDate {
    
    var day: Int                { return NSCalendar.currentCalendar().components(NSCalendarUnit.Day, fromDate: self).day }
    
    func xDays(x:Int) -> NSDate { return NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: x, toDate: self, options: [])! }
    
    func last7days() -> [Int]   { return {var result:[Int] = []; for index in 1...7 { result.append(self.xDays(-index).day) }; return result}() }

    func nearXdays(days:Int) -> [Int] { return days == 0 ? [self.day] : { var result:[Int] = []; for index in 1...abs(days) { result.append(self.xDays((index * (days>=0 ? 1 : -1))).day) }; return result }() }
}

