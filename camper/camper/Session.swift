import UIKit
import CoreData

class Session: NSObject {
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
    
    override init() {}
    
    required init(cancelled: Bool,
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
    
    required convenience init?(coder aDecoder: NSCoder) {
        let cancelled = aDecoder.decodeObject(forKey: "cancelled") as! Bool
        let accepted = aDecoder.decodeObject(forKey: "accepted") as! Bool
        let id = aDecoder.decodeObject(forKey: "id") as? NSNumber
        let title = aDecoder.decodeObject(forKey: "title") as? String
        let sessionDescription = aDecoder.decodeObject(forKey: "sessionDescription") as? String
        let scheduledDateTime = aDecoder.decodeObject(forKey: "scheduledDateTime") as? Date
        let scheduledRoom = aDecoder.decodeObject(forKey: "scheduledRoom") as? String
        let primaryCategory = aDecoder.decodeObject(forKey: "primaryCategory") as? String
        let level = aDecoder.decodeObject(forKey: "level") as? String
        let speakers = aDecoder.decodeObject(forKey: "speakers") as! [Speaker]
        let isFamilyApproved = aDecoder.decodeObject(forKey: "isFamilyApproved") as! Bool
        let isUserFavorite = aDecoder.decodeObject(forKey: "isUserFavorite") as! Bool
        let updated = aDecoder.decodeObject(forKey: "updated") as! Bool
        self.init(cancelled: cancelled,
                  accepted: accepted,
                  id: id,
                  title: title,
                  sessionDescription: sessionDescription,
                  scheduledDateTime: scheduledDateTime,
                  scheduledRoom: scheduledRoom,
                  primaryCategory: primaryCategory,
                  level: level,
                  speakers: speakers,
                  isFamilyApproved: isFamilyApproved,
                  isUserFavorite: isUserFavorite,
                  updated: updated)
    }

    func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(self.cancelled, forKey: "cancelled")
        aCoder.encode(self.accepted, forKey: "accepted")
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.sessionDescription, forKey: "sessionDescription")
        aCoder.encode(self.scheduledDateTime, forKey: "scheduledDateTime")
        aCoder.encode(self.scheduledRoom, forKey: "scheduledRoom")
        aCoder.encode(self.primaryCategory, forKey: "primaryCategory")
        aCoder.encode(self.level, forKey: "level")
        aCoder.encode(self.speakers, forKey: "speakers")
        aCoder.encode(self.isFamilyApproved, forKey: "isFamilyApproved")
        aCoder.encode(self.isUserFavorite, forKey: "isUserFavorite")
        aCoder.encode(self.updated, forKey: "updated")
    }
}
