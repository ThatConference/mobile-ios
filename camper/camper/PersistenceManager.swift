import Foundation

enum Path: String {
    case Schedule = "Schedule"
    case Favorites = "Favorites"
    case OpenSpaces = "OpenSpaces"
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
    
    class func deleteDailySchedule(path: Path) -> Bool{
        let exists = NSFileManager.defaultManager().fileExistsAtPath(path.rawValue)
        if exists {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path.rawValue)
            }catch let error as NSError {
                print("error: \(error.localizedDescription)")
                return false
            }
        }
        return exists
    }
}