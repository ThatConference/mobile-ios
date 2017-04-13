import UIKit
import Fabric
import Crashlytics

class ScheduleViewController : TimeSlotRootViewController {    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var timeTableView: UIStackView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var nextDayButton: UIButton!
    @IBOutlet var previousDayButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var refreshControl: UIRefreshControl!
    var currentDateTime: Date!
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        // set up controls
        let rightArrow = UIImage(named: "subheader-arrow-right")
        self.nextDayButton.imageEdgeInsets = UIEdgeInsetsMake(0, self.nextDayButton.frame.size.width - (rightArrow!.size.width), 0, 0)
        self.nextDayButton.titleEdgeInsets = UIEdgeInsetsMake(0, -(rightArrow!.size.width + 5), 0, (rightArrow!.size.width + 5))
        self.nextDayButton.addTarget(self, action: #selector(self.moveToNext), for: UIControlEvents.touchUpInside)
        
        self.previousDayButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5)
        self.previousDayButton.addTarget(self, action: #selector(self.moveToPrevious), for: .touchUpInside)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(ScheduleViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(self.refreshControl)
        
        self.revealViewControllerFunc(barButton: menuButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Answers.logContentView(withName: "Open Spaces",
                                       contentType: "Page",
                                       contentId: "",
                                       customAttributes: [:])
    }
    
    internal override func moveToDay(_ day: String!) {
        if (day == nil) {
            return
        }
        
        self.dailySchedule = self.dailySchedules[day];
        UIView.transition(with: self.tableView, duration: 0.5, options: .transitionCrossDissolve, animations: {() -> Void in
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
            }, completion: nil)
        UIView.transition(with: self.timeTableView, duration: 0.5, options: .transitionCrossDissolve, animations: {() -> Void in
                self.loadTimeTable()
            }, completion: nil)
        UIView.transition(with: self.dateLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {() -> Void in
                self.setDateLabel(self.dailySchedule.date! as Date)
                self.setPageState(day)
            }, completion: nil)
        
        let order = (Calendar.current as NSCalendar).compare(Date(), to: self.dailySchedule.date as Date, toUnitGranularity: .day)
        if order == ComparisonResult.orderedSame {
            self.jumpToTimeOfDay()
        }
    }
    
    func refresh(_ sender:AnyObject) {
        loadData()
    }
    
    // MARK: Data
    override func loadData() {
        if let sessionStore = StateData.instance.sessionStore {
            self.dateLabel.text = "Loading"
            self.activityIndicator.startAnimating()
            
            if (self.refreshControl != nil) {
                self.refreshControl.endRefreshing()
            }
            
            sessionStore.getDailySchedules(true) {
                (results) -> Void in
                
                switch results {
                case .success(let schedules):
                    self.setData(false)
                    self.dailySchedules = schedules
                    self.displayData()
                    break
                case .failure(let error):
                    print("ERROR:\(error)")
                    if let values = PersistenceManager.loadDailySchedule(Path.Schedule) {
                        self.setData(true)
                        self.dailySchedules = values
                        self.displayData()
                    } else {
                        let alert = UIAlertController(title: "Error", message: "Could not retrieve schedule data. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.activityIndicator.stopAnimating()
                        return
                    }
                    break
                }
            }

        }
    }
    
    func displayData() {
        OperationQueue.main.addOperation() {
            self.activityIndicator.stopAnimating()
            
            self.setCurrentDay(self.dailySchedules)
            self.jumpToTimeOfDay()
            
            if self.dailySchedules.count > 0 {
                if let schedule = self.dailySchedules[self.currentDay] {
                    self.dailySchedule = schedule
                }
                
                self.loadTimeTable()
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                
                self.setDateLabel(self.dailySchedule.date! as Date)
                
                let order = (Calendar.current as NSCalendar).compare(Date(), to: self.dailySchedule.date as Date, toUnitGranularity: .day)
                if order == ComparisonResult.orderedSame {
                    self.jumpToTimeOfDay()
                }
            }
        }
    }
    
    override func setData(_ isDirty: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.dirtyDataSchedule = isDirty;
    }
    
    override func getDirtyData() -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.dirtyDataSchedule;
    }
    
    // MARK: Page State
    
    fileprivate func setCurrentDay(_ schedules: Dictionary<String, DailySchedule>) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let today = formatter.string(from: Date())
        
        // set the date to today, unless we're outside the conference
        if schedules.index(forKey: today) != nil {
            self.setPageState(today)
        }
        else {
            self.setPageState(nil)
        }
    }
    
    fileprivate func setPageState(_ currentDay: String!) {
        let sortedDates = Array(self.dailySchedules.keys).sorted()
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
    
    fileprivate func setDateLabel(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE MMM dd"
        self.dateLabel.text = dateFormatter.string(from: date)
    }
    
    fileprivate func setButtonValues(_ schedules: Dictionary<String, DailySchedule>) {
        let buttonLabelFormatter = DateFormatter()
        buttonLabelFormatter.dateFormat = "MMM dd"
        
        let getDateFormatter = DateFormatter()
        getDateFormatter.dateFormat = "MM-dd-yyyy"
        
        if let previous = self.previousDay {
            self.previousDayButton.isHidden = false
            let date = getDateFormatter.date(from: previous)
            self.previousDayButton.setTitle(buttonLabelFormatter.string(from: date!), for: UIControlState())
        }
        else {
            self.previousDayButton.isHidden = true
        }
        
        if let next = self.nextDay {
            self.nextDayButton.isHidden = false
            let date = getDateFormatter.date(from: next)
            self.nextDayButton.setTitle(buttonLabelFormatter.string(from: date!), for: UIControlState())
        }
        else {
            self.nextDayButton.isHidden = true
        }
    }
   
    // MARK: Time Table Methods
    
    fileprivate func loadTimeTable() {
        for subview in self.timeTableView.arrangedSubviews {
            self.timeTableView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        self.timeTableView.addArrangedSubview(createTimeLabel("AM"));
        
        var hours: [Int] = []
        for timeSlot in self.dailySchedule.timeSlots {
            var alreadyAdded: Bool = false
            
            if (timeSlot?.time != nil) {
                var hour = (Calendar.current as NSCalendar).component(.hour, from: (timeSlot?.time)!)
                let minutes = (Calendar.current as NSCalendar).component(.minute, from: (timeSlot?.time)!)
                
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
                    label.timeSlot = timeSlot?.time
                    self.timeTableView.addArrangedSubview(label)
                    hours.append(hour)
                }
            }
        }
        
        self.timeTableView.addArrangedSubview(createTimeLabel("PM"));
        
        //set initial time to circle
        for circleView in self.timeTableView.subviews {
            if circleView.isKind(of: CircleLabel.self) {
                (circleView as! CircleLabel).toggleCircle()
                break
            }
        }
    }
    
    override func timeSelected(_ recognizer: UITapGestureRecognizer) {
        let view = recognizer.view  as! CircleLabel
        currentlySelectedTimeLabel = view
        view.toggleCircle()
        self.scrollToSection(view.timeSlot as Date)
    }
    
    fileprivate func jumpToTimeOfDay() {
        let nowHour = (Calendar.current as NSCalendar).component(.hour, from: Date())
        
        var locationSet: Bool = false
        var lastTimeVew: CircleLabel?
        for timeView in self.timeTableView.subviews {
            if timeView.isKind(of: CircleLabel.self) {
                lastTimeVew = (timeView as! CircleLabel)
                let viewHour = (Calendar.current as NSCalendar).component(.hour, from: (timeView as! CircleLabel).timeSlot as Date)
                if viewHour >= nowHour {
                    self.currentlySelectedTimeLabel = (timeView as! CircleLabel)
                    self.currentlySelectedTimeLabel.toggleCircle()
                    self.scrollToSection((timeView as! CircleLabel).timeSlot as Date)
                    locationSet = true
                    break
                }
            }
        }
        
        if !locationSet {
            // didn't find a next/current time - go to the end
            if let view = lastTimeVew {
                self.scrollToSection(view.timeSlot as Date)
                
                if let currentSelected = self.currentlySelectedTimeLabel {
                    currentSelected.toggleCircle()
                }
                self.currentlySelectedTimeLabel = view
                self.currentlySelectedTimeLabel.toggleCircle()
            }
        }
    }
   
    fileprivate func scrollToSection(_ timeSlot: Date) {
        let section = determineClosestTimeslotSection(timeSlot)
        let indexPath = IndexPath(row: 0, section: section)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    //set the proper selected Time
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let tableView = scrollView as! UITableView
        
        if let visibleRows = tableView.indexPathsForVisibleRows {
            if (visibleRows.count > 0) {
                let section = (visibleRows[0] as NSIndexPath).section; //top visible time
                
                if let timeSlot = dailySchedules[self.currentDay]?.timeSlots[section] {
                    do {
                        for timeView in self.timeTableView.subviews {
                            if timeView.isKind(of: CircleLabel.self) {
                                let circleView = (timeView as! CircleLabel)
                                if circleView.timeSlot == timeSlot.time! as Date {
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
            }
        }
    }
    
    // MARK: UINavigationContollerDelegate
    func navigationController(_ navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if viewController.isEqual(self) {
            self.tableView.reloadData()
        }
    }
    
    override func setDirtyData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.dirtyDataFavorites = true;
    }
    
    // MARK: Data Source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableViewCell") as! ScheduleTableViewCell
        
        if let schedule = dailySchedule {
            let timeSlots = schedule.timeSlots[(indexPath as NSIndexPath).section]
            let session  = timeSlots?.sessions[(indexPath as NSIndexPath).row]
            cell.session = session
            cell.sessionTitle.text = session?.title
            cell.sessionTitleCancelled.text = session?.title
            cell.sessionTitle.sizeToFit()
            cell.categoryLabel.text = session?.primaryCategory
            if let level = session?.level {
                cell.levelLabel.text = "Level: \(level)"
            }
            
            cell.favoriteIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.SessionFavorited(_:))))
            setFavoriteIcon(cell, animated: false)
            
            //set up speaker text
            var speakerString: String = ""
            var firstSpeaker: Bool = true
            for speaker in (session?.speakers)! {
                if !firstSpeaker {
                    speakerString.append(", ")
                } else {
                    firstSpeaker = false
                }
                
                speakerString.append("\(speaker.firstName!) \(speaker.lastName!)")
            }
            
            cell.speakerLabel.text = speakerString
            cell.roomLabel.text = session?.scheduledRoom
            cell.updateFlag.isHidden = !(session?.updated)!
            cell.cancelledCover.isHidden = !(session?.cancelled)!
        }
        
        return cell
    }
    
    func SessionFavorited(_ sender: UITapGestureRecognizer) {
        if Authentication.isLoggedIn() {
            if let sessionStore = StateData.instance.sessionStore {
                if let cell = sender.view?.superview?.superview as? ScheduleTableViewCell {
                    self.startIndicator()
                    if cell.session.isUserFavorite {
                        sessionStore.removeFavorite(cell.session, completion:{(sessionsResult) -> Void in
                            switch sessionsResult {
                            case .success(let sessions):
                                self.stopIndicator()
                                self.setDirtyData()
                                let currentSession = sessions.first
                                currentSession?.isUserFavorite = false
                                cell.session = currentSession
                                self.setFavoriteIcon(cell, animated: true)
                                Answers.logCustomEvent(withName: "Removed Favorite", customAttributes: [:])
                                break
                            case .failure(_):
                                self.stopIndicator()
                                let alert = UIAlertController(title: "Error", message: "Could not remove favorite at this time. Check your connection.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                break
                            }
                        })
                    }
                    else {
                        sessionStore.addFavorite(cell.session, completion:{(sessionsResult) -> Void in
                            switch sessionsResult {
                            case .success(let sessions):
                                self.stopIndicator()
                                self.setDirtyData()
                                let currentSession = sessions.first
                                currentSession?.isUserFavorite = true
                                cell.session = currentSession
                                self.setFavoriteIcon(cell, animated: true)
                                Answers.logCustomEvent(withName: "Added Favorite", customAttributes: [:])
                                break
                            case .failure(_):
                                self.stopIndicator()
                                let alert = UIAlertController(title: "Error", message: "Could not add favorite at this time. Check your connection.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                break
                            }
                        })
                    }
                }
            }
            else
            {
                self.parent!.parent!.performSegue(withIdentifier: "show_login", sender: self)
            }
        }
    }
}
