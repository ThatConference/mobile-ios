import UIKit

class ScheduleViewController : TimeSlotRootViewController {    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var timeTableView: UIStackView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var nextDayButton: UIButton!
    @IBOutlet var previousDayButton: UIButton!
    @IBOutlet var updatedFlag: UIImageView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        // set up controls
        let rightArrow = UIImage(named: "subheader-arrow-right")
        self.nextDayButton.imageEdgeInsets = UIEdgeInsetsMake(0, self.nextDayButton.frame.size.width - (rightArrow!.size.width), 0, 0)
        self.nextDayButton.titleEdgeInsets = UIEdgeInsetsMake(0, -(rightArrow!.size.width + 5), 0, (rightArrow!.size.width + 5))
        self.nextDayButton.addTarget(self, action: #selector(self.moveToNext), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.previousDayButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5)
        self.previousDayButton.addTarget(self, action: #selector(self.moveToPrevious), forControlEvents: .TouchUpInside)
    }
    
    internal override func moveToDay(day: String!) {
        if (day == nil) {
            return
        }
        
        self.dailySchedule = self.dailySchedules[day];
        UIView.transitionWithView(self.tableView, duration: 0.5, options: .TransitionCrossDissolve, animations: {() -> Void in
                self.tableView.reloadData()
                self.tableView.scrollToRowAtIndexPath(NSIndexPath.init(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
            }, completion: nil)
        UIView.transitionWithView(self.timeTableView, duration: 0.5, options: .TransitionCrossDissolve, animations: {() -> Void in
                self.loadTimeTable()
            }, completion: nil)
        UIView.transitionWithView(self.dateLabel, duration: 0.5, options: .TransitionCrossDissolve, animations: {() -> Void in
                self.setDateLabel(self.dailySchedule.date!)
                self.setPageState(day)
            }, completion: nil)
        
        let order = NSCalendar.currentCalendar().compareDate(NSDate(), toDate: self.dailySchedule.date, toUnitGranularity: .Day)
        if order == NSComparisonResult.OrderedSame {
            self.jumpToTimeOfDay()
        }
    }
    
    // MARK: Data
    override func loadData() {
        let sessionStore = SessionStore()
        self.dateLabel.text = "Loading"
        self.activityIndicator.startAnimating()
        
        sessionStore.getDailySchedules(true) {
            (results) -> Void in
            
            switch results {
            case .Success(let schedules):
                self.setData(false)
                self.dailySchedules = schedules
                self.displayData()
                break
            case .Failure(_):
                if let values = PersistenceManager.loadDailySchedule(Path.Schedule) {
                    self.setData(true)
                    self.dailySchedules = values
                    self.displayData()
                } else {
                    let alert = UIAlertController(title: "Error", message: "Could not retrieve schedule data. Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    return
                }
                break
            }
        }
    }
    
    func displayData() {
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            self.activityIndicator.stopAnimating()
            
            self.setCurrentDay(self.dailySchedules)
            
            if self.dailySchedules.count > 0 {
                if let schedule = self.dailySchedules[self.currentDay] {
                    self.dailySchedule = schedule
                }
                
                self.loadTimeTable()
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                
                self.setDateLabel(self.dailySchedule.date!)
                
                let order = NSCalendar.currentCalendar().compareDate(NSDate(), toDate: self.dailySchedule.date, toUnitGranularity: .Day)
                if order == NSComparisonResult.OrderedSame {
                    self.jumpToTimeOfDay()
                }
            }
        }
    }
    
    override func setData(isDirty: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.dirtyDataSchedule = isDirty;
    }
    
    override func getDirtyData() -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.dirtyDataSchedule;
    }
    
    // MARK: Page State
    
    private func setCurrentDay(schedules: Dictionary<String, DailySchedule>) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "mm-dd-yyyy"
        let today = formatter.stringFromDate(NSDate())
        
        // set the date to today, unless we're outside the conference
        if schedules.indexForKey(today) != nil {
            self.setPageState(today)
        }
        else {
            self.setPageState(nil)
        }
    }
    
    private func setPageState(currentDay: String!) {
        let sortedDates = Array(self.dailySchedules.keys).sort()
        if sortedDates.count > 0 {
            if currentDay == nil || sortedDates[0] == currentDay {
                self.currentDay = sortedDates[0]
                self.nextDay = sortedDates[1]
                self.previousDay = nil
            }
            else {
                let indexes = sortedDates.count - 1
                var index = 0
                repeat {
                    self.previousDay = sortedDates[index]
                    if index + 1 <= indexes {
                        self.currentDay = sortedDates[index + 1]
                    }
                    if index + 2 <= indexes {
                        self.nextDay = sortedDates[index + 2]
                    }
                    else {
                        self.nextDay = nil
                    }
                    
                    index += 1
                } while sortedDates[index] != currentDay
            }
        }
        setButtonValues(self.dailySchedules)
    }
    
    private func setDateLabel(date: NSDate) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE MMM dd"
        self.dateLabel.text = dateFormatter.stringFromDate(date)
    }
    
    private func setButtonValues(schedules: Dictionary<String, DailySchedule>) {
        let buttonLabelFormatter = NSDateFormatter()
        buttonLabelFormatter.dateFormat = "MMM dd"
        
        let getDateFormatter = NSDateFormatter()
        getDateFormatter.dateFormat = "MM-dd-yyyy"
        
        if let previous = self.previousDay {
            self.previousDayButton.hidden = false
            let date = getDateFormatter.dateFromString(previous)
            self.previousDayButton.setTitle(buttonLabelFormatter.stringFromDate(date!), forState: .Normal)
        }
        else {
            self.previousDayButton.hidden = true
        }
        
        if let next = self.nextDay {
            self.nextDayButton.hidden = false
            let date = getDateFormatter.dateFromString(next)
            self.nextDayButton.setTitle(buttonLabelFormatter.stringFromDate(date!), forState: .Normal)
        }
        else {
            self.nextDayButton.hidden = true
        }
    }
   
    // MARK: Time Table Methods
    
    private func loadTimeTable() {
        for subview in self.timeTableView.arrangedSubviews {
            self.timeTableView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        self.timeTableView.addArrangedSubview(createTimeLabel("AM"));
        
        var hours: [Int] = []
        for timeSlot in self.dailySchedule.timeSlots {
            var alreadyAdded: Bool = false
            
            if (timeSlot.time != nil) {
                var hour = NSCalendar.currentCalendar().component(.Hour, fromDate: timeSlot.time)
                let minutes = NSCalendar.currentCalendar().component(.Minute, fromDate: timeSlot.time)
                
                for trackedHours in hours {
                    if trackedHours == hour {
                        alreadyAdded = true
                        break
                    }
                }
                
                if !alreadyAdded {
                    if hour > 12 {
                        hour = hour - 12
                    }
                    
                    var padding = ""
                    if (minutes == 0) {
                        padding = "0"
                    }
                    
                    let timeLabel = "\(hour):\(minutes)\(padding)"
                    let label = createClickableTimeLabel(timeLabel)
                    label.timeSlot = timeSlot.time
                    self.timeTableView.addArrangedSubview(label)
                    hours.append(hour)
                }
            }
        }
        
        self.timeTableView.addArrangedSubview(createTimeLabel("PM"));
        
        //set initial time to circle
        for circleView in self.timeTableView.subviews {
            if circleView.isKindOfClass(CircleLabel) {
                (circleView as! CircleLabel).toggleCircle()
                break
            }
        }
    }
    
    override func timeSelected(recognizer: UITapGestureRecognizer) {
        let view = recognizer.view  as! CircleLabel
        currentlySelectedTimeLabel = view
        view.toggleCircle()
        self.scrollToSection(view.timeSlot)
    }
    
    private func jumpToTimeOfDay() {
        let nowHour = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate())
        
        var locationSet: Bool = false
        var lastTimeVew: CircleLabel?
        for timeView in self.timeTableView.subviews {
            if timeView.isKindOfClass(CircleLabel) {
                lastTimeVew = (timeView as! CircleLabel)
                let viewHour = NSCalendar.currentCalendar().component(.Hour, fromDate: (timeView as! CircleLabel).timeSlot)
                if viewHour >= nowHour {
                    self.currentlySelectedTimeLabel = (timeView as! CircleLabel)
                    self.currentlySelectedTimeLabel.toggleCircle()
                    self.scrollToSection((timeView as! CircleLabel).timeSlot)
                    locationSet = true
                    break
                }
            }
        }
        
        if !locationSet {
            // didn't find a next/current time - go to the end
            if let view = lastTimeVew {
                self.scrollToSection(view.timeSlot)
                
                if let currentSelected = self.currentlySelectedTimeLabel {
                    currentSelected.toggleCircle()
                }
                self.currentlySelectedTimeLabel = view
                self.currentlySelectedTimeLabel.toggleCircle()
            }
            
        }
    }
   
    private func scrollToSection(timeSlot: NSDate) {
        let section = determineClosestTimeslotSection(timeSlot)
        let indexPath = NSIndexPath(forRow: 0, inSection: section)
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }
    
    //set the proper selected Time
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let tableView = scrollView as! UITableView
        
        if let visibleRows = tableView.indexPathsForVisibleRows {
            let section = visibleRows[0].section; //top visible time
            
            let timeSlot = dailySchedules[self.currentDay]?.timeSlots[section];
            
            for timeView in self.timeTableView.subviews {
                if timeView.isKindOfClass(CircleLabel) {
                    let circleView = (timeView as! CircleLabel)
                    if circleView.timeSlot.isEqualToDate(timeSlot!.time!) {
                        if circleView.circleVisible() == false {
                            circleView.toggleCircle()
                        }
                    } else if circleView.circleVisible() {
                        circleView.toggleCircle()
                    }
                }
            }
        }
    }
    
    // MARK: UINavigationContollerDelegate
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if viewController.isEqual(self) {
            self.tableView.reloadData()
        }
    }
    
    override func setDirtyData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.dirtyDataFavorites = true;
    }
    
    // MARK: Data Source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ScheduleTableViewCell") as! ScheduleTableViewCell
        
        if let schedule = dailySchedule {
            let timeSlots = schedule.timeSlots[indexPath.section]
            let session  = timeSlots.sessions[indexPath.row]
            cell.session = session
            cell.sessionTitle.text = session.title
            cell.sessionTitleCancelled.text = session.title
            cell.sessionTitle.sizeToFit()
            cell.categoryLabel.text = session.primaryCategory
            
            cell.favoriteIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.SessionFavorited(_:))))
            setFavoriteIcon(cell, animated: false)
            
            //set up speaker text
            var speakerString: String = ""
            var firstSpeaker: Bool = true
            for speaker in session.speakers {
                if !firstSpeaker {
                    speakerString.appendContentsOf(", ")
                } else {
                    firstSpeaker = false
                }
                
                speakerString.appendContentsOf("\(speaker.firstName!) \(speaker.lastName!)")
            }
            
            cell.speakerLabel.text = speakerString
            cell.roomLabel.text = session.scheduledRoom
            cell.updateFlag.hidden = !session.updated
            cell.cancelledCover.hidden = !session.cancelled
        }
        
        return cell
    }
    
    func SessionFavorited(sender: UITapGestureRecognizer) {
        if Authentication.isLoggedIn() {
            let sessionStore = SessionStore()
            if let cell = sender.view?.superview?.superview as? ScheduleTableViewCell {
                self.startIndicator()
                if cell.session.isUserFavorite {
                    sessionStore.removeFavorite(cell.session, completion:{(sessionsResult) -> Void in
                        switch sessionsResult {
                        case .Success(let sessions):
                            self.stopIndicator()
                            self.setDirtyData()
                            cell.session = sessions.first
                            self.setFavoriteIcon(cell, animated: true)
                            break
                        case .Failure(_):
                            self.stopIndicator()
                            let alert = UIAlertController(title: "Error", message: "Could not remove favorite at this time. Check your connection.", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                            break
                        }
                    })
                }
                else {
                    sessionStore.addFavorite(cell.session, completion:{(sessionsResult) -> Void in
                        switch sessionsResult {
                        case .Success(let sessions):
                            self.stopIndicator()
                            self.setDirtyData()
                            cell.session = sessions.first
                            self.setFavoriteIcon(cell, animated: true)
                            break
                        case .Failure(_):
                            self.stopIndicator()
                            let alert = UIAlertController(title: "Error", message: "Could not add favorite at this time. Check your connection.", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                            break
                        }
                    })
                }
            }
        }
        else
        {
            self.parentViewController!.parentViewController!.performSegueWithIdentifier("show_login", sender: self)
        }
    }
}
