import Foundation

class TimeSlot: NSObject, NSCoding {
    var time: Date!
    var sessions: [Session?] = []
    
    override init() {}
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.time, forKey: "time")
        aCoder.encode(self.sessions, forKey: "sessions")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let time = aDecoder.decodeObject(forKey: "time") as! Date
        let sessions = aDecoder.decodeObject(forKey: "sessions") as! [Session?]
        self.init(time: time, sessions: sessions)
    }
    
    required init(time: Date, sessions: [Session?]) {
        self.time = time
        self.sessions = sessions
    }
}
