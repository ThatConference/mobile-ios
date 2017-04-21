import UIKit

class Session: NSObject, NSCoding {
    struct Keys {
        static let cancelled = "cancelled"
        static let accepted = "accepted"
        static let id = "id"
        static let title = "title"
        static let sessionDescription = "sessionDescription"
        static let scheduleDateTime = "scheduledDateTime"
        static let scheduledRoom = "scheduledRoom"
        static let primaryCategory = "primaryCategory"
        static let level = "level"
        static let speakers = "speakers"
        static let isFamilyApproved = "isFamilyApproved"
        static let isUserFavorite = "isUserFavorite"
        static let updated = "updated"
    }
    
    var cancelled: Bool = false
    var accepted: Bool = false
    var id: NSNumber?
    var title: String?
    var sessionDescription: String?
    var scheduledDateTime: Date?
    var scheduledRoom: String?
    var primaryCategory: String?
    var level: String?
    var speakers: [Speaker] = []
    var isFamilyApproved: Bool = false
    var isUserFavorite: Bool = false
    var updated: Bool = false
    
    init(dictionary: [String: AnyObject]) {
        cancelled = dictionary[Keys.cancelled] as! Bool
        accepted = dictionary[Keys.accepted] as! Bool
        id = dictionary[Keys.id] as? NSNumber
        title = dictionary[Keys.title] as? String
        sessionDescription = dictionary[Keys.sessionDescription] as? String
        scheduledDateTime = dictionary[Keys.scheduleDateTime] as? Date
        scheduledRoom = dictionary[Keys.scheduledRoom] as? String
        primaryCategory = dictionary[Keys.primaryCategory] as? String
        level = dictionary[Keys.level] as? String
        speakers = dictionary[Keys.speakers] as! [Speaker]
        isFamilyApproved = dictionary[Keys.isFamilyApproved] as! Bool
        isUserFavorite = dictionary[Keys.isUserFavorite] as! Bool
        updated = dictionary[Keys.updated] as! Bool
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.cancelled, forKey: Keys.cancelled)
        aCoder.encode(self.accepted, forKey: Keys.accepted)
        aCoder.encode(self.id, forKey: Keys.id)
        aCoder.encode(self.title, forKey: Keys.title)
        aCoder.encode(self.sessionDescription, forKey: Keys.sessionDescription)
        aCoder.encode(self.scheduledDateTime, forKey: Keys.scheduleDateTime)
        aCoder.encode(self.scheduledRoom, forKey: Keys.scheduledRoom)
        aCoder.encode(self.primaryCategory, forKey: Keys.primaryCategory)
        aCoder.encode(self.level, forKey: Keys.level)
        aCoder.encode(self.speakers, forKey: Keys.speakers)
        aCoder.encode(self.isFamilyApproved, forKey: Keys.isFamilyApproved)
        aCoder.encode(self.isUserFavorite, forKey: Keys.isUserFavorite)
        aCoder.encode(self.updated, forKey: Keys.updated)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        cancelled = aDecoder.decodeBool(forKey: Keys.cancelled)
        accepted = aDecoder.decodeBool(forKey: Keys.accepted)
        id = aDecoder.decodeObject(forKey: Keys.id) as? NSNumber
        title = aDecoder.decodeObject(forKey: Keys.title) as? String
        sessionDescription = aDecoder.decodeObject(forKey: Keys.sessionDescription) as? String
        scheduledDateTime = aDecoder.decodeObject(forKey: Keys.scheduleDateTime) as? Date
        scheduledRoom = aDecoder.decodeObject(forKey: Keys.scheduledRoom) as? String
        primaryCategory = aDecoder.decodeObject(forKey: Keys.primaryCategory) as? String
        level = aDecoder.decodeObject(forKey: Keys.level) as? String
        speakers = aDecoder.decodeObject(forKey: Keys.speakers) as! [Speaker]
        isFamilyApproved = aDecoder.decodeBool(forKey: Keys.isFamilyApproved)
        isUserFavorite = aDecoder.decodeBool(forKey: Keys.isUserFavorite)
        updated = aDecoder.decodeBool(forKey: Keys.updated)
    }
    
    init(cancelled: Bool,
                  accepted: Bool,
                  id: NSNumber?,
                  title: String?,
                  sessionDescription: String?,
                  scheduledDateTime: Date?,
                  scheduledRoom: String?,
                  primaryCategory: String?,
                  level: String?,
                  speakers: [Speaker],
                  isFamilyApproved: Bool,
                  isUserFavorite: Bool,
                  updated: Bool) {
        self.cancelled = cancelled
        self.accepted = accepted
        self.id = id
        self.title = title
        self.sessionDescription = sessionDescription
        self.scheduledDateTime = scheduledDateTime
        self.scheduledRoom = scheduledRoom
        self.primaryCategory = primaryCategory
        self.level = level
        self.speakers = speakers
        self.isFamilyApproved = isFamilyApproved
        self.isUserFavorite = isUserFavorite
        self.updated = updated
    }
    
}
