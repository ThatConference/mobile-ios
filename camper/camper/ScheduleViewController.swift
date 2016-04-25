    import UIKit

class ScheduleViewController : UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var timeTableView: UIStackView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var nextDayButton: UIButton!
    @IBOutlet var previousDayButton: UIButton!
    
    var store: SessionStore!
    var currentDay: String!
    var previousDay: String!
    var nextDay: String!
    
    private let scheduleDataSource = ScheduleDataSource()
    private var currentlySelectedTimeLabel: CircleLabel!
    private var dailySchedules: Dictionary<String, DailySchedule>!
    private var activityIndicator: UIActivityIndicatorView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 80, 80))
        self.activityIndicator.activityIndicatorViewStyle = .Gray
        self.activityIndicator.center =  self.view.center
        self.activityIndicator.backgroundColor = UIColor.whiteColor()
        self.activityIndicator.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicator)
        
        let sessionStore = SessionStore()
        self.dateLabel.text = "Loading"
        self.activityIndicator.startAnimating()
        sessionStore.fetchAll() {
            (sessionResult) -> Void in
            //var dailySchedules: Dictionary<String,DailySchedule>!
            switch sessionResult {
            case .Success(let sessions):
                self.dailySchedules = sessionStore.getDailySchedules(sessions)
            case .Failure(let error):
                //TODO: notify pulling from cache - accuracy may be off
                // REENABLE CACHING 
                //let sortBySessionDateTime = NSSortDescriptor(key: "scheduledDateTime", ascending: true)
                //allSessions = try! self.store.fetchMainQueueSessions(predicate: nil, sortDescriptors: [sortBySessionDateTime])
                print("Error: \(error)")
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.activityIndicator.stopAnimating()                
                
                self.setCurrentDay(self.dailySchedules)
                
                if let schedule = self.dailySchedules[self.currentDay] {
                    self.scheduleDataSource.dailySchedule = schedule
                }
                
                self.loadTimeTable()
                self.tableView.delegate = self
                self.tableView.dataSource = self.scheduleDataSource
                self.tableView.reloadData()
                
                self.setDateLabel(self.scheduleDataSource.dailySchedule.date!)
                
                let order = NSCalendar.currentCalendar().compareDate(NSDate(), toDate: self.scheduleDataSource.dailySchedule.date, toUnitGranularity: .Day)
                if order == NSComparisonResult.OrderedSame {
                    self.jumpToTimeOfDay()
                }
            }
        }
        
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
    
    @objc private func moveToNextDay() {
        self.moveToDay(self.nextDay)
    }
    
    @objc private func moveToPrevious() {
        self.moveToDay(self.previousDay)
    }
    
    private func moveToDay(day: String!) {
        self.scheduleDataSource.dailySchedule = self.dailySchedules[day];
        UIView.transitionWithView(self.tableView, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {() -> Void in
                self.tableView.reloadData()
            self.tableView.scrollToRowAtIndexPath(NSIndexPath.init(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
            }, completion: nil)
        UIView.transitionWithView(self.timeTableView, duration: 0.5, options: .TransitionCrossDissolve, animations: {() -> Void in
                self.loadTimeTable()
            }, completion: nil)
        UIView.transitionWithView(self.dateLabel, duration: 0.5, options: .TransitionCrossDissolve, animations: {() -> Void in
                self.setDateLabel(self.scheduleDataSource.dailySchedule.date!)
                self.setPageState(day)
            }, completion: nil)
        
        let order = NSCalendar.currentCalendar().compareDate(NSDate(), toDate: self.scheduleDataSource.dailySchedule.date, toUnitGranularity: .Day)
        if order == NSComparisonResult.OrderedSame {
            self.jumpToTimeOfDay()
        }

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
        for timeSlot in self.scheduleDataSource.dailySchedule.timeSlots {
            var alreadyAdded: Bool = false
            var hour = NSCalendar.currentCalendar().component(.Hour, fromDate: timeSlot.time)
            
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
                
                let label = createClickableTimeLabel("\(hour)")
                label.timeSlot = timeSlot.time
                self.timeTableView.addArrangedSubview(label)
                hours.append(hour)
            }
        }
        
        self.timeTableView.addArrangedSubview(createTimeLabel("PM"));
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
        let view = CircleLabel(frame: CGRect(x: 0, y: 0, width: 20.0, height: 20.0))
        view.userInteractionEnabled = true
        view.label.text = "\(value)"
        view.label.font = UIFont(name: "Neutraface Text", size: 14.0)
        view.sizeToFit()
        view.heightAnchor.constraintEqualToConstant(20).active = true
        view.widthAnchor.constraintEqualToConstant(20).active = true
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
        currentlySelectedTimeLabel?.toggleCircle()
        currentlySelectedTimeLabel = view
        view.toggleCircle()
        self.scrollToSection(view.timeSlot)
    }
    
    private func determineClosestTimeslotSection(hourSelected: NSDate) -> Int {
        for index in 0...scheduleDataSource.dailySchedule.timeSlots.count - 1 {
            let timeSlot = scheduleDataSource.dailySchedule.timeSlots[index]
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

    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) { 
        //TODO: go to proper time
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ScheduleTableViewCell
        let session =  cell.session
        let sessionDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("SessionDetailViewController") as! SessionDetailViewController
        sessionDetailVC.session = session
        self.navigationController!.pushViewController(sessionDetailVC, animated: true)
    }
}
