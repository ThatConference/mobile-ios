import UIKit
import CoreData

class Session: NSObject {
    var cancelled: Bool = false
    var accepted: Bool = false
    var id: NSNumber?
    var title: String?
    var sessionDescription: String?
    var scheduledDateTime: NSDate?
    var scheduledRoom: String?
    var primaryCategory: String?
    var level: String?
    var speakers: [Speaker] = []
    var isFamilyApproved: Bool = false
    var isUserFavorite: Bool = false
    
    override init() {}
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.cancelled, forKey: "cancelled")
        aCoder.encodeObject(self.accepted, forKey: "accepted")
        aCoder.encodeObject(self.id, forKey: "id")
        aCoder.encodeObject(self.title, forKey: "title")
        aCoder.encodeObject(self.sessionDescription, forKey: "sessionDescription")
        aCoder.encodeObject(self.scheduledDateTime, forKey: "scheduledDateTime")
        aCoder.encodeObject(self.scheduledRoom, forKey: "scheduledRoom")
        aCoder.encodeObject(self.primaryCategory, forKey: "primaryCategory")
        aCoder.encodeObject(self.level, forKey: "level")
        aCoder.encodeObject(self.speakers, forKey: "speakers")
        aCoder.encodeObject(self.isFamilyApproved, forKey: "isFamilyApproved")
        aCoder.encodeObject(self.isUserFavorite, forKey: "isUserFavorite")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let cancelled = aDecoder.decodeObjectForKey("cancelled") as! Bool
        let accepted = aDecoder.decodeObjectForKey("accepted") as! Bool
        let id = aDecoder.decodeObjectForKey("id") as? NSNumber
        let title = aDecoder.decodeObjectForKey("title") as? String
        let sessionDescription = aDecoder.decodeObjectForKey("sessionDescription") as? String
        let scheduledDateTime = aDecoder.decodeObjectForKey("scheduledDateTime") as? NSDate
        let scheduledRoom = aDecoder.decodeObjectForKey("scheduledRoom") as? String
        let primaryCategory = aDecoder.decodeObjectForKey("primaryCategory") as? String
        let level = aDecoder.decodeObjectForKey("level") as? String
        let speakers = aDecoder.decodeObjectForKey("speakers") as! [Speaker]
        let isFamilyApproved = aDecoder.decodeObjectForKey("isFamilyApproved") as! Bool
        let isUserFavorite = aDecoder.decodeObjectForKey("isUserFavorite") as! Bool
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
                  isUserFavorite: isUserFavorite)
    }
    
    required init(cancelled: Bool,
                  accepted: Bool,
                  id: NSNumber?,
                  title: String?,
                  sessionDescription: String?,
                  scheduledDateTime: NSDate?,
                  scheduledRoom: String?,
                  primaryCategory: String?,
                  level: String?,
                  speakers: [Speaker],
                  isFamilyApproved: Bool,
                  isUserFavorite: Bool) {
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
    }
}