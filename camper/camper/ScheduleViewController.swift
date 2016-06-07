import UIKit

class ScheduleViewController : UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var timeTableView: UIStackView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var nextDayButton: UIButton!
    @IBOutlet var previousDayButton: UIButton!
    @IBOutlet var updatedFlag: UIImageView!
    
    var store: SessionStore!
    var currentDay: String!
    var previousDay: String!
    var nextDay: String!
    var dailySchedule: DailySchedule!
    
    private var currentlySelectedTimeLabel: CircleLabel!
    private var dailySchedules: Dictionary<String, DailySchedule>!
    private var activityIndicator: UIActivityIndicatorView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationController?.delegate = self
        
        self.activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 80, 80))
        self.activityIndicator.activityIndicatorViewStyle = .Gray
        self.activityIndicator.center =  self.view.center
        self.activityIndicator.backgroundColor = UIColor.whiteColor()
        self.activityIndicator.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicator)
        
        loadData()
        
        //Show login screen if not logged in
        if (!Authentication.isLoggedIn()) {
            self.parentViewController!.parentViewController!.performSegueWithIdentifier("show_login", sender: self)
        }

        // set up controls
        let rightArrow = UIImage(named: "subheader-arrow-right")
        self.nextDayButton.imageEdgeInsets = UIEdgeInsetsMake(0, self.nextDayButton.frame.size.width - (rightArrow!.size.width), 0, 0)
        self.nextDayButton.titleEdgeInsets = UIEdgeInsetsMake(0, -(rightArrow!.size.width + 5), 0, (rightArrow!.size.width + 5))
        self.nextDayButton.addTarget(self, action: #selector(self.moveToNextDay), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.previousDayButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5)
        self.previousDayButton.addTarget(self, action: #selector(self.moveToPrevious), forControlEvents: .TouchUpInside)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (getDirtyData()) {
            loadData()
        }
    }
    
    @objc private func moveToNextDay() {
        self.moveToDay(self.nextDay)
    }
    
    @objc private func moveToPrevious() {
        self.moveToDay(self.previousDay)
    }
    
    private func moveToDay(day: String!) {
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
    
    // MARK: Data
    func loadData() {
        let sessionStore = SessionStore()
        self.dateLabel.text = "Loading"
        self.activityIndicator.startAnimating()
        
        sessionStore.getDailySchedules() {
            (results) -> Void in
            
            switch results {
            case .Success(let schedules):
                self.setData(false)
                self.dailySchedules = schedules
                PersistenceManager.saveDailySchedule(self.dailySchedules, path: Path.Schedule)
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
    
    func setData(isDirty: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.dirtyDataSchedule = isDirty;
    }
    
    func getDirtyData() -> Bool {
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
    
    private func createTimeLabel(value: String) -> UILabel {
        let label = UILabel()
        label.userInteractionEnabled = true
        label.backgroundColor = UIColor.clearColor()
        label.text = "\(value)"
        label.font = UIFont(name: "Neutraface Text", size: 14.0)
        
        return label
    }
    
    private func createCircleTimeLabel(value: String) -> CircleLabel {
        let view = CircleLabel(frame: CGRect(x: 0, y: 0, width: 35.0, height: 35.0))
        view.userInteractionEnabled = true
        view.label.text = "\(value)"
        view.label.font = UIFont(name: "Neutraface Text", size: 14.0)
        view.sizeToFit()
        view.heightAnchor.constraintEqualToConstant(35).active = true
        view.widthAnchor.constraintEqualToConstant(35).active = true
        return view
    }
    
    private func createClickableTimeLabel(value: String) -> CircleLabel {
        let view = createCircleTimeLabel(value)
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ScheduleViewController.timeSelected(_:)))
        recognizer.delegate = self
        view.addGestureRecognizer(recognizer)
        
        return view
    }
    
    func timeSelected(recognizer: UITapGestureRecognizer) {
        let view = recognizer.view  as! CircleLabel
        currentlySelectedTimeLabel = view
        view.toggleCircle()
        self.scrollToSection(view.timeSlot)
    }
    
    private func determineClosestTimeslotSection(hourSelected: NSDate) -> Int {
        for index in 0...dailySchedule.timeSlots.count - 1 {
            let timeSlot = dailySchedule.timeSlots[index]
            if timeSlot.time == hourSelected {
                return index
            }
        }
        return 0
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ScheduleTableViewCell
        let session =  cell.session
        let sessionDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("SessionDetailViewController") as! SessionDetailViewController
        sessionDetailVC.session = session
        self.navigationController!.pushViewController(sessionDetailVC, animated: true)
    }
    
    // MARK: UINavigationContollerDelegate
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if viewController.isEqual(self) {
            self.tableView.reloadData()
        }
    }
    
    // MARK: Data Source
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ScheduleTableViewCell") as! ScheduleTableViewCell
        
        if let schedule = dailySchedule {
            let timeSlots = schedule.timeSlots[indexPath.section]
            let session  = timeSlots.sessions[indexPath.row]
            cell.session = session
            cell.sessionTitle.text = session.title
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
        if Authentication.isLoggedIn() {
            if let cell = sender.view?.superview?.superview as? ScheduleTableViewCell {
                let sessionStore = SessionStore()
                if cell.session.isUserFavorite {
                    sessionStore.removeFavorite(cell.session, completion:{(sessionsResult) -> Void in
                        switch sessionsResult {
                        case .Success(let sessions):
                            self.setDirtyData()
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
                            self.setDirtyData()
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
        else
        {
            self.parentViewController!.parentViewController!.performSegueWithIdentifier("show_login", sender: self)
        }
    }
    
    func setDirtyData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.dirtyDataFavorites = true;
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
                cell.favoriteIcon!.image = UIImage(named:"like-1")
            }
        })
    }
}
