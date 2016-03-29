import UIKit

class SessionDataSource: NSObject, UITableViewDataSource {
    var dailySchedule: DailySchedule!
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ScheduleTableViewCell") as! ScheduleTableViewCell
        
        if let schedule = dailySchedule {
            let timeSlots = schedule.timeSlots[indexPath.section]
            let session  = timeSlots.sessions[indexPath.row]
            cell.sessionTitle.text = session.title
            cell.sessionTitle.sizeToFit()
            //cell.speakerLabel.text = self.sessionDataSource.sessions[indexPath.row].
            cell.roomLabel.text = session.scheduledRoom
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        
        if dailySchedule.timeSlots[section].sessions.count > 0 {
            return dailySchedule.timeSlots[section].sessions.count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dailySchedule.timeSlots[section].time
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dailySchedule.timeSlots.count
    }
    
}