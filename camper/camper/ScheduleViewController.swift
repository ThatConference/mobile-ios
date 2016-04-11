    import UIKit

class ScheduleViewController : UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var timeTableView: UIStackView!
    @IBOutlet var dateLabel: UILabel!
    
    var store: SessionStore!
    private let sessionDataSource = SessionDataSource()
    private var currentlySelectedTimeLabel: CircleLabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        self.timeTableView.backgroundColor = UIColor.clearColor()
        
        let sessionStore = SessionStore()
        sessionStore.fetchAll() {
            (sessionResult) -> Void in
            let allSessions: [Session]
            var dailySchedules: Dictionary<String,DailySchedule>!
            switch sessionResult {
            case .Success(let sessions):
                allSessions = sessions
                dailySchedules = sessionStore.getDailySchedules(allSessions)
            case .Failure(let error):
                // REENABLE CACHING 
                //let sortBySessionDateTime = NSSortDescriptor(key: "scheduledDateTime", ascending: true)
                //allSessions = try! self.store.fetchMainQueueSessions(predicate: nil, sortDescriptors: [sortBySessionDateTime])
                print("Error: \(error)")
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock() {                
                if let schedule = dailySchedules["08-10-2015"] {
                    self.sessionDataSource.dailySchedule = schedule
                }
                self.loadTimeTable()
                self.tableView.delegate = self
                self.tableView.dataSource = self.sessionDataSource
                self.tableView.reloadData()
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "EEEE MMM dd"
                self.dateLabel.text = dateFormatter.stringFromDate(self.sessionDataSource.dailySchedule.date!)
                
                //TODO: put this check back in before we go live - just commenting out for testing
                //let order = NSCalendar.currentCalendar().compareDate(NSDate(), toDate: self.sessionDataSource.dailySchedule.date, toUnitGranularity: .Day)
                //if order == NSComparisonResult.OrderedSame {
                    self.jumpToTimeOfDay()
                //}
            }
        }
        
        //TODO: If logged in, skip this
        self.parentViewController!.parentViewController!.performSegueWithIdentifier("show_login", sender: self)
    }
   
    func loadTimeTable() {
        self.timeTableView.addArrangedSubview(createTimeLabel("AM"));
        
        var hours: [Int] = []
        for timeSlot in self.sessionDataSource.dailySchedule.timeSlots {
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
        for index in 0...sessionDataSource.dailySchedule.timeSlots.count - 1 {
            let timeSlot = sessionDataSource.dailySchedule.timeSlots[index]
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
        
    }
}