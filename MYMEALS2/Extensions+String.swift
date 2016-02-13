//
//  Extensions.swift
//  PlantivoSwift
//
//  Created by Marc Felden on 24.02.15.
//  Copyright (c) 2015 Timm Kent. All rights reserved.
//

import UIKit

extension String {
    func toDateWithDayMonthYear() -> NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter.dateFromString(self)
    }
    
    func toDateWithDayMonthYearWithTime() -> NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd.MM.yy HH:mm"
        return formatter.dateFromString(self)
    }
    
    func getStringBetweenStrings(string1:String,string2:String) -> String? {
        let string3 = self
        let restString = ""
        if let foundStringRange = string3.rangeOfString(string1) {
            let restString2 = string3[foundStringRange.endIndex.advancedBy(0)...string3.endIndex.advancedBy(-1)]
            if let foundStringRange2 = restString2.rangeOfString(string2) {
                let endIndex = foundStringRange2.startIndex.advancedBy(-1)
                return restString2[restString.startIndex...endIndex]
            }
        }
        return nil
    }
    func toDouble() -> Double?
    {
        let newString = self.stringByReplacingOccurrencesOfString(".", withString: ",")
        return NSNumberFormatter().numberFromString(newString)?.doubleValue
    }
    
    func toFloat() -> Float?
    {
        let newString = self.stringByReplacingOccurrencesOfString(".", withString: ",")
        return NSNumberFormatter().numberFromString(newString)?.floatValue
    }
    
    func toInt() -> Int?
    {
        let intValue = Int(self)
        return intValue
    }
}

