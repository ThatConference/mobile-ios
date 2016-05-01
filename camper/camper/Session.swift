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
}