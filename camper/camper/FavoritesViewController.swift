import UIKit
import Fabric
import Crashlytics

class FavoritesViewController : TimeSlotRootViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var timeTableView: UIStackView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var nextDayButton: UIButton!
    @IBOutlet var previousDayButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkUserStatus()
        
        // set up controls
        let rightArrow = UIImage(named: "subheader-arrow-right")
        self.nextDayButton.imageEdgeInsets = UIEdgeInsetsMake(0, self.nextDayButton.frame.size.width - (rightArrow!.size.width), 0, 0)
        self.nextDayButton.titleEdgeInsets = UIEdgeInsetsMake(0, -(rightArrow!.size.width + 5), 0, (rightArrow!.size.width + 5))
        self.nextDayButton.addTarget(self, action: #selector(self.moveToNext), for: UIControlEvents.touchUpInside)
        
        self.previousDayButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5)
        self.previousDayButton.addTarget(self, action: #selector(self.moveToPrevious), for: .touchUpInside)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(FavoritesViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(self.refreshControl)
        self.revealViewControllerFunc(barButton: menuButton)
        
        if currentReachabilityStatus != .notReachable {
            if StateData.instance.offlineFavoriteSessions.sessions.count > 0 {
                ThatConferenceAPI.saveOfflineFavorites(offlineFavorites: StateData.instance.offlineFavoriteSessions.sessions)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (getDirtyData()) {
            if (self.dailySchedules != nil) {
                OperationQueue.main.addOperation() {
                    self.dailySchedules.removeAll()
                    self.tableView.isHidden = true
                }
            }
            
            if (!Authentication.isLoggedIn()) {
                loadData()
            }
        }
        
        Answers.logContentView(withName: "Open Spaces",
                               contentType: "Page",
                               contentId: "",
                               customAttributes: [:])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.syncOfflineFavorites()
    }
    
    internal override func moveToDay(_ day: String!) {
        if (day == nil) {
            return
        }
        
        self.dailySchedule = self.dailySchedules[day];
        UIView.transition(with: self.tableView, duration: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {() -> Void in
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
    
    // MARK: Page Data
    
    fileprivate func checkUserStatus()
    {
        //Show login screen if not logged in
        if (!Authentication.isLoggedIn()) {
            setData(true)
            self.performSegue(withIdentifier: "show_login", sender: self)
        } else {
            self.view.addSubview(self.activityIndicator)
            loadData()
        }
    }
    
    @objc func refresh(_ sender:AnyObject) {
        loadData()
    }
    
    override func loadData() {
        self.syncOfflineFavorites()
        
        if let sessionStore = StateData.instance.sessionStore {
            self.dateLabel.text = "Loading"
            self.activityIndicator.startAnimating()
            
            if (self.refreshControl != nil) {
                self.refreshControl.endRefreshing()
            }
            
            sessionStore.getFavoriteSessions(completion: {(sessionResult) -> Void in
                switch sessionResult {
                case .success(let sessions):
                    self.setData(false)
                    self.dailySchedules = sessions
                    PersistenceManager.saveDailySchedule(self.dailySchedules, path: Path.Favorites)
                    self.displayData()
                    break
                case .failure(let error):
                    print("Error: \(error)")
                    self.setData(true)
                    let values = PersistenceManager.loadDailySchedule(Path.Favorites)
                    if values != nil && Authentication.isLoggedIn() {
                        self.dailySchedules = values!
                        self.displayData()
                    } else {
                        if (self.isViewLoaded && self.view.window != nil) {
                            self.alert = UIAlertController(title: "Log In Needed", message: "Log in to view favorites.", preferredStyle: UIAlertControllerStyle.alert)
                            self.alert.addAction(UIAlertAction(title: "Log In", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
                                self.parent!.parent!.performSegue(withIdentifier: "show_login", sender: self)
                            }))
                            self.alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
                                if (self.dailySchedules != nil) {
                                    self.dailySchedules.removeAll()
                                }
                                
                                self.tableView.delegate = self
                                self.tableView.dataSource = self
                                self.tableView.reloadData()
                                self.activityIndicator.stopAnimating()
                                
                                self.navigateToSchedule()
                            }))
                            self.present(self.alert, animated: true, completion: nil)
                        }
                    }
                    break
                }
            })
        }
    }
    
    func displayData() {
        OperationQueue.main.addOperation() {
            self.tableView.isHidden = false
            self.activityIndicator.stopAnimating()
            
            self.setCurrentDay(self.dailySchedules)
            self.jumpToTimeOfDay()
            
            if (self.currentDay != nil) {
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
        appDelegate.dirtyDataFavorites = isDirty;
    }
    
    override func getDirtyData() -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.dirtyDataFavorites;
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
        
        if sortedDates.count == 0 {
            let alert = UIAlertController(title: "No Favorites", message: "No favorites found. Please select some favorites to view this page", preferredStyle: UIAlertControllerStyle.alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                self.navigateToSchedule()
            }
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
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
    
    // MARK: DataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesTableViewCell") as! FavoritesTableViewCell
        
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
            removeFavoriteIcon(cell, animated: false)
            
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
    
    @objc func SessionFavorited(_ sender: UITapGestureRecognizer) {
        if Authentication.isLoggedIn() {
            if let sessionStore = StateData.instance.sessionStore {
                if let cell = sender.view?.superview?.superview as? FavoritesTableViewCell {
                    self.startIndicator()
                    if cell.session.isUserFavorite {
                        sessionStore.removeFavorite(cell.session, completion:{(sessionsResult) -> Void in
                            switch sessionsResult {
                            case .success(let sessions):
                                self.stopIndicator()
                                self.setDirtyData()
                                cell.session = sessions.first
                                cell.session.isUserFavorite = false
                                self.saveOfflineFavorites(currentSession: cell.session, isOffline: false) {
                                    self.removeFavoriteIcon(cell, animated: true)
                                    Answers.logCustomEvent(withName: "Removed Favorite", customAttributes: [:])
                                }
                                break
                            case .failure(_):
                                self.stopIndicator()
                                guard let currentSession = cell.session else {return}
                                currentSession.isUserFavorite = false
                                self.saveOfflineFavorites(currentSession: currentSession, isOffline: true) {
                                    self.removeFavoriteIcon(cell, animated: true)
                                    Answers.logCustomEvent(withName: "Removed Favorite", customAttributes: [:])
                                }
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
                                cell.session = sessions.first
                                cell.session.isUserFavorite = true
                                self.saveOfflineFavorites(currentSession: cell.session, isOffline: false) {
                                    self.removeFavoriteIcon(cell, animated: true)
                                    Answers.logCustomEvent(withName: "Added Favorite", customAttributes: [:])
                                }
                                break
                            case .failure(_):
                                self.stopIndicator()
                                guard let currentSession = cell.session else {return}
                                currentSession.isUserFavorite = true
                                self.saveOfflineFavorites(currentSession: currentSession, isOffline: true) {
                                    self.removeFavoriteIcon(cell, animated: true)
                                    Answers.logCustomEvent(withName: "Added Favorite", customAttributes: [:])
                                }
                                break
                            }
                        })
                    }
                }
            }
        }
        else
        {
            self.parent!.parent!.performSegue(withIdentifier: "show_login", sender: self)
        }
    }
}
