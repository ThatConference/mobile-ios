    import UIKit

class ScheduleViewController : UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var timeTableView: UIStackView!
    @IBOutlet var dateLabel: UILabel!
    
    var store: SessionStore!
    private let sessionDataSource = SessionDataSource()
    private var currentlySelectedTimeLabel: CircleLabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        self.timeTableView.backgroundColor = UIColor.clearColor()
        self.loadTimeTable()
        
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
                                
                self.tableView.dataSource = self.sessionDataSource
                self.tableView.reloadData()
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "EEEE MMM dd"
                self.dateLabel.text = dateFormatter.stringFromDate(self.sessionDataSource.dailySchedule.date!)
            }
        }
        
        //TODO: If logged in, skip this
        self.parentViewController!.parentViewController!.performSegueWithIdentifier("show_login", sender: self)
    }
   
    func loadTimeTable() {
        self.timeTableView.addArrangedSubview(createTimeLabel("AM"));
        
        for amTime in 8...12 {
              self.timeTableView.addArrangedSubview(createClickableTimeLabel("\(amTime)"))
        }

        for pmTime in 1...8 {
            self.timeTableView.addArrangedSubview(createClickableTimeLabel("\(pmTime)"))
        }
        
        self.timeTableView.addArrangedSubview(createTimeLabel("PM"));
    }
    
    func createTimeLabel(value: String) -> UILabel {
        let label = UILabel()
        label.userInteractionEnabled = true
        label.backgroundColor = UIColor.clearColor()
        label.text = "\(value)"
        label.font = UIFont(name: "Neutraface Text", size: 14.0)
        
        return label
    }
    
    func createCircleTimeLabel(value: String) -> CircleLabel {
        let view = CircleLabel(frame: CGRect(x: 0, y: 0, width: 20.0, height: 20.0))
        view.userInteractionEnabled = true
        view.label.text = "\(value)"
        view.label.font = UIFont(name: "Neutraface Text", size: 14.0)
        view.sizeToFit()
        view.heightAnchor.constraintEqualToConstant(20).active = true
        view.widthAnchor.constraintEqualToConstant(20).active = true
        return view
    }
    
    func createClickableTimeLabel(value: String) -> UIView {
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
        
        //TODO: go to proper time
    }
}