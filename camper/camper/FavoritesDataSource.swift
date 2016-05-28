import UIKit

class FavoritesDataSource: NSObject, UITableViewDataSource {
    var dailySchedule: DailySchedule!
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FavoritesTableViewCell") as! FavoritesTableViewCell
        
        if let schedule = dailySchedule {
            let timeSlots = schedule.timeSlots[indexPath.section]
            let session  = timeSlots.sessions[indexPath.row]
            cell.session = session
            cell.sessionTitle.text = session.title
            cell.sessionTitle.sizeToFit()
            cell.category.text = session.primaryCategory
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
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let sessionStore = SessionStore()
            
            sessionStore.removeFavorite(dailySchedule.timeSlots[indexPath.section].sessions[indexPath.row], completion:{(sessionsResult) -> Void in
                switch sessionsResult {
                case .Success(_):
                    dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                        self.dailySchedule.timeSlots[indexPath.section].sessions.removeAtIndex(indexPath.row)
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        
                        if (self.dailySchedule.timeSlots[indexPath.section].sessions.count == 0) {
                            self.dailySchedule.timeSlots.removeAtIndex(indexPath.section)
                            let indexSet = NSMutableIndexSet()
                            indexSet.addIndex(indexPath.section)
                            tableView.deleteSections(indexSet, withRowAnimation: UITableViewRowAnimation.Automatic)
                        }
                    }
                    break
                case .Failure(_):
                    break
                }
            })
        }
    }
}