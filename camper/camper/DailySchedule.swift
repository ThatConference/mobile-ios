import Foundation

class DailySchedule: NSObject, NSCoding {
    var date: Date!
    var timeSlots: [TimeSlot?] = []
    var timeSaved: Date?
    
    override init() {
        timeSaved = Date()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.date, forKey: "date")
        aCoder.encode(self.timeSlots, forKey: "timeSlots")
        aCoder.encode(self.timeSaved, forKey: "timeSaved")
    }
    
    func cleanData() {
        date = Date()
        timeSlots.removeAll()
        timeSaved = nil
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let date = aDecoder.decodeObject(forKey: "date") as! Date
        
        var timeSlots: [TimeSlot] = []
        if (aDecoder.decodeObject(forKey: "timeSlots") as? [TimeSlot]) != nil {
            timeSlots = aDecoder.decodeObject(forKey: "timeSlots") as! [TimeSlot]
        }
        
        let timeSaved = aDecoder.decodeObject(forKey: "timeSaved") as? Date
        
        self.init(date: date, timeSlots: timeSlots, timeSaved: timeSaved)
    }
    
    required init(date: Date, timeSlots: [TimeSlot?], timeSaved: Date?) {
        self.date = date
        self.timeSlots = timeSlots
        self.timeSaved = timeSaved
    }
}
