import UIKit

class ScheduleDataSource: NSObject, UITableViewDataSource {
    var dailySchedule: DailySchedule!
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ScheduleTableViewCell") as! ScheduleTableViewCell
        
        if let schedule = dailySchedule {
            let timeSlots = schedule.timeSlots[indexPath.section]
            let session  = timeSlots.sessions[indexPath.row]
            cell.session = session
            cell.sessionTitle.text = session.title
            cell.sessionTitle.sizeToFit()
        
            if !session.isFamilyApproved {
                cell.circleView.hidden = true
                //cell.circleViewHeightConstraint.constant = 0
            }
            else {
                cell.circleView.hidden = false
            }
            
            //set up speaker text
            var speakerString: String = ""
            var firstSpeaker: Bool = true
            for speaker in session.speakers {
                if !firstSpeaker {
                    speakerString.appendContentsOf(", ")
                } else {
                    firstSpeaker = false
                }

                speakerString.appendContentsOf("\(speaker.firstName) \(speaker.lastName)")                
            }
            
            cell.speakerLabel.text = speakerString
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
        return SessionStore.getFormattedTime(dailySchedule.timeSlots[section].time)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dailySchedule.timeSlots.count
    }
}