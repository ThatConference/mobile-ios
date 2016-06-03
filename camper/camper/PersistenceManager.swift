//
//  PersistenceManager.swift
//  That Conference
//
//  Created by Matthew Ridley on 6/2/16.
//  Copyright © 2016 That Conference. All rights reserved.
//

import Foundation

enum Path: String {
    case Schedule = "Schedule"
    case Favorites = "Favorites"
}

class PersistenceManager {
    class private func documentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectory = paths[0] as String
        return documentDirectory
    }
    
    class func saveDailySchedule(saveObject: Dictionary<String, DailySchedule>, path: Path) {
        let file = documentsDirectory().stringByAppendingPathComponent(path.rawValue)
        NSKeyedArchiver.archiveRootObject(saveObject, toFile: file)
    }
    
    class func loadDailySchedule(path: Path) -> Dictionary<String, DailySchedule>? {
        let file = documentsDirectory().stringByAppendingPathComponent(path.rawValue)
        let result = NSKeyedUnarchiver.unarchiveObjectWithFile(file)
        return result as? Dictionary<String, DailySchedule>
    }
}