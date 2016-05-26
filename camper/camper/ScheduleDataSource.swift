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
            }
            else {
                cell.circleView.hidden = false
            }
            
            if Authentication.isLoggedIn() {
                cell.favoriteIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScheduleDataSource.SessionFavorited(_:))))
                setFavoriteIcon(cell, animated: false)
            }
            else {
                cell.favoriteIcon!.image = nil;
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
    
    func SessionFavorited(sender: UITapGestureRecognizer) {
        if let cell = sender.view?.superview?.superview as? ScheduleTableViewCell {
            let sessionStore = SessionStore()
            if cell.session.isUserFavorite {
                sessionStore.removeFavorite(cell.session, completion:{(sessionsResult) -> Void in
                    switch sessionsResult {
                    case .Success(let sessions):
                        cell.session = sessions.first
                        self.setFavoriteIcon(cell, animated: true)
                        break
                    case .Failure(_):
                        break
                    }
                })

            }
            else {
                CATransaction.begin()
                CATransaction.setAnimationDuration(1.5)
                let transition = CATransition()
                transition.type = kCATransitionFade
                cell.favoriteIcon!.layer.addAnimation(transition, forKey: kCATransitionFade)
                CATransaction.commit()
                cell.favoriteIcon!.image = UIImage(named:"likeadded")
                sessionStore.addFavorite(cell.session, completion:{(sessionsResult) -> Void in
                    switch sessionsResult {
                    case .Success(let sessions):
                        cell.session = sessions.first
                        self.setFavoriteIcon(cell, animated: true)
                        break
                    case .Failure(_):
                        break
                    }
                })

            }
            
        }
    }
    
    private func setFavoriteIcon(cell: ScheduleTableViewCell, animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            if animated {
                CATransaction.begin()
                CATransaction.setAnimationDuration(1.5)
                let transition = CATransition()
                transition.type = kCATransitionFade
                cell.favoriteIcon!.layer.addAnimation(transition, forKey: kCATransitionFade)
                CATransaction.commit()
            }
            if cell.session.isUserFavorite {
                cell.favoriteIcon!.image = UIImage(named:"like-remove")
            }
            else {
                    //cell.favoriteIcon!.image = UIImage(named:"likeadded")
                
                    cell.favoriteIcon!.image = UIImage(named:"like-1")
            }
        })        
    }
}