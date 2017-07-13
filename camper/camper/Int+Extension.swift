//
//  Int+Extension.swift
//  That Conference
//
//  Created by Steven Yang on 7/5/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import Foundation

extension Int {
    func intToDate() -> Date {
        let timeInterval = Double(self)
        
        return Date(timeIntervalSince1970: timeInterval)
    }
    
    func intToString() -> String {
        return String(self)
    }
    
}

extension UInt16 {
    func uInt16ToInt() -> Int {
        let nsNumber = NSNumber(value: self)
        return Int(nsNumber)
    }
}
