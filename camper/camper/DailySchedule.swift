import Foundation

class DailySchedule: NSObject, NSCoding {
    var date: NSDate!
    var timeSlots: [TimeSlot!] = []
    var timeSaved: NSDate?
    
    override init() {
        timeSaved = NSDate()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.date, forKey: "date")
        aCoder.encodeObject(self.timeSlots, forKey: "timeSlots")
        aCoder.encodeObject(self.timeSaved, forKey: "timeSaved")
    }
    
    func cleanData() {
        date = NSDate()
        timeSlots.removeAll()
        timeSaved = nil
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let date = aDecoder.decodeObjectForKey("date") as! NSDate
        let timeSlots = aDecoder.decodeObjectForKey("timeSlots") as! [TimeSlot!]
        let timeSaved = aDecoder.decodeObjectForKey("timeSaved") as? NSDate
        self.init(date: date, timeSlots: timeSlots, timeSaved: timeSaved)
    }
    
    required init(date: NSDate, timeSlots: [TimeSlot!], timeSaved: NSDate?) {
        self.date = date
        self.timeSlots = timeSlots
        self.timeSaved = timeSaved
    }
}