import Foundation

class TimeSlot: NSObject, NSCoding {
    var time: NSDate!
    var sessions: [Session!] = []
    
    override init() {}
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.time, forKey: "time")
        aCoder.encodeObject(self.sessions, forKey: "sessions")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let time = aDecoder.decodeObjectForKey("time") as! NSDate
        let sessions = aDecoder.decodeObjectForKey("sessions") as! [Session!]
        self.init(time: time, sessions: sessions)
    }
    
    required init(time: NSDate, sessions: [Session!]) {
        self.time = time
        self.sessions = sessions
    }
}