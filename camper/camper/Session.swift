import UIKit
import CoreData

class Session: NSManagedObject {
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        id = 0
        title = ""
        sessiondescription = ""
        primaryCategory = ""
        level = 0
        accepted = false
        cancelled = false
        isUserFavorite = false
    }
}

extension Session {
    @NSManaged var id: Int
    @NSManaged var title: String?
    @NSManaged var sessiondescription: String?
    @NSManaged var primaryCategory: String?
    @NSManaged var level: Int
    @NSManaged var accepted: Bool
    @NSManaged var cancelled: Bool
    @NSManaged var isUserFavorite: Bool
}