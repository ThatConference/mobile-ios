import Foundation

enum Path: String {
    case Schedule = "Schedule"
    case FamilyEvents = "FamilyEvents"
    case Favorites = "Favorites"
    case OpenSpaces = "OpenSpaces"
    case OfflineFavorites = "OfflineFavorites"
}

class PersistenceManager {
    class fileprivate func documentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = paths[0] as String
        return documentDirectory as NSString
    }
    
    class func saveDailySchedule(_ saveObject: Dictionary<String, DailySchedule>, path: Path) {
        let file = documentsDirectory().appendingPathComponent(path.rawValue)
        NSKeyedArchiver.archiveRootObject(saveObject, toFile: file)
    }
    
    class func loadDailySchedule(_ path: Path) -> Dictionary<String, DailySchedule>? {
        let file = documentsDirectory().appendingPathComponent(path.rawValue)
        let result = NSKeyedUnarchiver.unarchiveObject(withFile: file)
        return result as? Dictionary<String, DailySchedule>
    }
    
    class func deleteDailySchedule(_ path: Path) -> Bool{
        let exists = FileManager.default.fileExists(atPath: path.rawValue)
        if exists {
            do {
                try FileManager.default.removeItem(atPath: path.rawValue)
            }catch let error as NSError {
                print("error: \(error.localizedDescription)")
                return false
            }
        }
        return exists
    }
    
    class func saveOfflineFavorites(_ saveObject: Sessions, path: Path) {
        let file = documentsDirectory().appendingPathComponent(path.rawValue)
        NSKeyedArchiver.archiveRootObject(saveObject, toFile: file)
    }
    
    class func loadOfflineFavorites(_ path: Path) -> Sessions? {
        let file = documentsDirectory().appendingPathComponent(path.rawValue)
        let result = NSKeyedUnarchiver.unarchiveObject(withFile: file)
        return result as? Sessions
    }
}
