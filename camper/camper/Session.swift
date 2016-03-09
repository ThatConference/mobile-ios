import UIKit
import CoreData

class Session: NSManagedObject {
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        id = 0
        title = ""
        sessionDescription = ""
        scheduledDateTime = NSDate()
        scheduledRoom = ""
        primaryCategory = ""
        level = "0"
        accepted = false
        cancelled = false
        //isUserFavorite = false
    }
}