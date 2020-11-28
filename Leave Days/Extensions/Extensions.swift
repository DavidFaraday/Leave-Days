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

}


extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}

enum LeaveType: String, CaseIterable {
    
    case Sick, Annual
}

