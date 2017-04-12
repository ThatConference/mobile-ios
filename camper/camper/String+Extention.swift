//
//  String+Extention.swift
//  That Conference
//
//  Created by Steven Yang on 4/10/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import Foundation

extension String {
    var stringToDate: Date {
        
        let calendar = Calendar(identifier: .gregorian)
        
        var dateComponents = DateComponents()
        dateComponents.timeZone = TimeZone(abbreviation: "CST")
        let string = self.replacingOccurrences(of: ":", with: " ")
        let string2 = string.replacingOccurrences(of: "-", with: " ")
        let string3 = string2.replacingOccurrences(of: "/", with: " ")
        let array = string3.components(separatedBy: " ")
        
        if let year = Int(array[0]), let month = Int(array[1]), let day = Int(array[2]), let hour = Int(array[3]), let minutes = Int(array[4]), let seconds = Int(array[5]) {
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day
            dateComponents.hour = hour
            dateComponents.minute = minutes
            dateComponents.second = seconds
        }
        
        if let date = calendar.date(from: dateComponents) {
            return date
        }
        
        return Date()
    }
    
    var rideDayFormatter: Date {
        
        let calendar = Calendar(identifier: .gregorian)
        
        var dateComponents = DateComponents()
        dateComponents.timeZone = TimeZone(abbreviation: "CST")
        let mainString = self
        let string = mainString.replacingOccurrences(of: ":", with: " ")
        let string2 = string.replacingOccurrences(of: "-", with: " ")
        let string3 = string2.replacingOccurrences(of: "/", with: " ")
        let array = string3.components(separatedBy: " ")
        
        if let month = Int(array[0]), let day = Int(array[1]), let year = Int(array[2]) {
            dateComponents.day = day
            dateComponents.month = month
            dateComponents.year = year
        }
        
        if let date = calendar.date(from: dateComponents) {
            return date
        }
        
        return Date()
    }
    
    var rideDateFormatter: Date {
        
        let calendar = Calendar(identifier: .gregorian)
        
        var dateComponents = DateComponents()
        dateComponents.timeZone = TimeZone(abbreviation: "CST")
        var mainString = self
        if self.contains("am") {
            mainString = mainString.replacingOccurrences(of: "am", with: " AM")
        } else if self.contains("pm") {
            mainString = mainString.replacingOccurrences(of: "pm", with: " PM")
        }
        let string = mainString.replacingOccurrences(of: ":", with: " ")
        let string2 = string.replacingOccurrences(of: "-", with: " ")
        let string3 = string2.replacingOccurrences(of: "/", with: " ")
        
        let array = string3.components(separatedBy: " ")
        
        if let month = Int(array[0]), let day = Int(array[1]), let year = Int(array[2]), let hour = Int(array[3]), let minutes = Int(array[4]) {
            dateComponents.day = day
            dateComponents.month = month
            dateComponents.year = year
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh mm a"
            let timeString = "\(hour) \(minutes) \(array[5])"
            let convertedTime = dateFormatter.date(from: timeString)
            dateFormatter.dateFormat = "HH mm"
            let mainTime = dateFormatter.string(from: convertedTime!)
            
            let timeArray = mainTime.components(separatedBy: " ")
            if let convertHour = Int(timeArray[0]), let convertMinute = Int(timeArray[1]) {
                dateComponents.hour = convertHour
                dateComponents.minute = convertMinute
            }
        }
        
        if let date = calendar.date(from: dateComponents) {
            return date
        }
        
        return Date()
    }
    
    var dateStringToDate: Date {
        
        //
        // For yyyy MM dd conversions
        
        let calendar = Calendar(identifier: .gregorian)
        
        var dateComponents = DateComponents()
        dateComponents.timeZone = TimeZone(abbreviation: "CST")
        let string = self.replacingOccurrences(of: ":", with: " ")
        let string2 = string.replacingOccurrences(of: "-", with: " ")
        let string3 = string2.replacingOccurrences(of: "/", with: " ")
        let array = string3.components(separatedBy: " ")
        
        if let year = Int(array[0]), let month = Int(array[1]), let day = Int(array[2]) {
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day
        }
        
        if let date = calendar.date(from: dateComponents) {
            return date
        }
        
        return Date()
    }
    
    var shortStringToDate: Date {
        
        //
        //  For DOB or Expiration Dates
        
        let calendar = Calendar(identifier: .gregorian)
        
        var dateComponents = DateComponents()
        dateComponents.timeZone = TimeZone(abbreviation: "CST")
        let string = self.replacingOccurrences(of: ":", with: " ")
        let string2 = string.replacingOccurrences(of: "-", with: " ")
        let string3 = string2.replacingOccurrences(of: "/", with: " ")
        let array = string3.components(separatedBy: " ")
        
        if let year = Int(array[0]), let month = Int(array[1]), let day = Int(array[2]) {
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day
        }
        
        if let date = calendar.date(from: dateComponents) {
            return date
        }
        
        return Date()
    }
    
    var separateString: Array<String> {
        let array = self.components(separatedBy: " ")
        return array
    }
    
    var htmlToAttributedString: NSAttributedString? {
        do {
            let str = try NSAttributedString(data: data(using: String.Encoding.unicode, allowLossyConversion: true)!, options: [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType], documentAttributes: nil)
            
            return str
        } catch {
            print(error)
        }
        return NSAttributedString()
    }
    
    var stringToPhoneString: String {
        let string = self.replacingOccurrences(of: " ", with: "-")
        return string
    }
    
    var stringToInt: Int {
        if let number = Int(self) {
            return number
        } else {
            return 0
        }
    }
    
    var removeSpace: String {
        let string = self.replacingOccurrences(of: " ", with: "")
        return string
        
    }
    
    var hexColor: UIColor {
        let hex = trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return .clear
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
