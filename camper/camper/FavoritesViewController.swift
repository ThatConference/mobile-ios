import UIKit

class FavoritesViewController : TimeSlotRootViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var timeTableView: UIStackView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var nextDayButton: UIButton!
    @IBOutlet var previousDayButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkUserStatus()
    
        // set up controls
        let rightArrow = UIImage(named: "subheader-arrow-right")
        self.nextDayButton.imageEdgeInsets = UIEdgeInsetsMake(0, self.nextDayButton.frame.size.width - (rightArrow!.size.width), 0, 0)
        self.nextDayButton.titleEdgeInsets = UIEdgeInsetsMake(0, -(rightArrow!.size.width + 5), 0, (rightArrow!.size.width + 5))
        self.nextDayButton.addTarget(self, action: #selector(self.moveToNext), forControlEvents: UIControlEvents.TouchUpInside)
    
        self.previousDayButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5)
        self.previousDayButton.addTarget(self, action: #selector(self.moveToPrevious), forControlEvents: .TouchUpInside)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (getDirtyData()) {
            if (self.dailySchedules != nil) {
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    self.dailySchedules.removeAll()
                    self.tableView.hidden = true
                }
            }
            loadData()
        }
    }
    
    internal override func moveToDay(day: String!) {
        if (day == nil) {
            return
        }
        
        self.dailySchedule = self.dailySchedules[day];
        UIView.transitionWithView(self.tableView, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {() -> Void in
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
    
    // MARK: Page Data
    private func checkUserStatus()
    {
        //Show login screen if not logged in
        if (!Authentication.isLoggedIn()) {
            setData(true)
            self.parentViewController!.parentViewController!.performSegueWithIdentifier("show_login", sender: self)
        } else {
            self.view.addSubview(self.activityIndicator)
            loadData()
        }
    }
    
    override func loadData() {
        let sessionStore = SessionStore()
        self.dateLabel.text = "Loading"
        self.activityIndicator.startAnimating()
        
        sessionStore.getFavoriteSessions(completion: {(sessionResult) -> Void in
            switch sessionResult {
            case .Success(let sessions):
                self.setData(false)
                self.dailySchedules = sessions
                PersistenceManager.saveDailySchedule(self.dailySchedules, path: Path.Favorites)
                self.displayData()
                break
            case .Failure(let error):
                print("Error: \(error)")
                self.setData(true)
                let values = PersistenceManager.loadDailySchedule(Path.Favorites)
                if values != nil && Authentication.isLoggedIn() {
                    self.dailySchedules = values!
                    self.displayData()
                } else {
                    let alert = UIAlertController(title: "Log In Needed", message: "Log in to view favorites.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Log In", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
                        self.parentViewController!.parentViewController!.performSegueWithIdentifier("show_login", sender: self)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
                        if (self.dailySchedules != nil) {
                            self.dailySchedules.removeAll()
                        }
                        
                        self.tableView.delegate = self
                        self.tableView.dataSource = self
                        self.tableView.reloadData()
                        self.activityIndicator.stopAnimating()
                        
                        self.navigateToSchedule()
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                break
            }
        })
    }
    
    func displayData() {
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            self.tableView.hidden = false
            self.activityIndicator.stopAnimating()
            
            self.setCurrentDay(self.dailySchedules)
            
            if (self.currentDay != nil) {
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
    
    func setData(isDirty: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.dirtyDataFavorites = isDirty;
    }
    
    override func getDirtyData() -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.dirtyDataFavorites;
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
    
    private func navigateToSchedule() {
        setData(true)
        self.tabBarController?.selectedIndex = 1
    }
    
    private func setPageState(currentDay: String!) {
        let sortedDates = Array(self.dailySchedules.keys).sort()
        
        if sortedDates.count == 0 {
            let alert = UIAlertController(title: "No Favorites", message: "No favorites found. Please select some favorites to view this page", preferredStyle: UIAlertControllerStyle.Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                self.navigateToSchedule()
            }
            alert.addAction(OKAction)
            self.presentViewController(alert, animated: true, completion: nil)
            self.dateLabel.text = ""
            return
        }
        
        if currentDay == nil || sortedDates[0] == currentDay {
            self.currentDay = sortedDates[0]
            self.nextDay = nil
            self.previousDay = nil
            
            if (sortedDates.count > 1) {
                self.nextDay = sortedDates[1]
            }
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
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Remove"
    }
    
    // MARK: DataSource
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FavoritesTableViewCell") as! FavoritesTableViewCell
        
        if let schedule = dailySchedule {
            let timeSlots = schedule.timeSlots[indexPath.section]
            let session  = timeSlots.sessions[indexPath.row]
            cell.session = session
            cell.sessionTitle.text = session.title
            cell.sessionTitle.sizeToFit()
            cell.cancelledOverlay.hidden = !session.cancelled
            cell.category.text = "\(session.primaryCategory!)  |  Room: \(session.scheduledRoom!)"
        }
        
        return cell
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