//
//  Extensions.swift
//  Leave Days
//
//  Created by David Kababyan on 20/11/2020.
//

import Foundation
import UIKit
import AVFoundation


extension Date {
    
    func dayMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        return dateFormatter.string(from: self)
    }
    
    func dateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MMM/yyyy HH:mm"
        return dateFormatter.string(from: self)
    }
    
    func stringDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMyyyyHHmmss"
        return dateFormatter.string(from: self)
    }
    
    func time() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }

    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Float {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0}
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0}

        return Float(start - end)
    }
    
    func nextDay(in calendar: Calendar) -> Date? {
        return calendar.date(byAdding: .day, value: 1, to: self)
    }

    func daysCount(until endDate: Date) -> (workingDays: Int, weekends: Int) {
        
        let calendar = Calendar.current
        var weekends = 0
        var workingDays = 0
        var date = self

        while date <= endDate {

            if calendar.isDateInWeekend(date) {
                weekends += 1
            } else {
                workingDays += 1
            }

            guard let nextDay = date.nextDay(in: calendar) else {
                fatalError("Failed to instantiate a next day")
            }

            date = nextDay
        }

        return (workingDays, weekends)
    }

}


extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}

enum LeaveType: String, CaseIterable {
    
    case Annual, Sick
}


extension Calendar {
    //returns number of days including today, good for hotel booking
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        
        return numberOfDays.day! + 1
    }
}
