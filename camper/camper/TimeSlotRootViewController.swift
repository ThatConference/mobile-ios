import UIKit

class TimeSlotRootViewController : BaseViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    var store: SessionStore!
    var currentDay: String!
    var previousDay: String!
    var nextDay: String!
    var dailySchedule: DailySchedule!
    var currentlySelectedTimeLabel: CircleLabel!
    var dailySchedules: Dictionary<String, DailySchedule>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationController?.delegate = self
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(TimeSlotRootViewController.handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(TimeSlotRootViewController.handleSwipes(_:)))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (getDirtyData()) {
            loadData()
        }
    }
    
    func loadData() {
        fatalError("Must Override")
    }
    
    func getDirtyData() -> Bool {
        fatalError("Must Override")
    }
    
    // MARK: Time Table Methods
    func createTimeLabel(value: String) -> UILabel {
        let label = UILabel()
        label.userInteractionEnabled = true
        label.backgroundColor = UIColor.clearColor()
        label.text = "\(value)"
        label.font = UIFont(name: "Neutraface Text", size: 14.0)
        
        return label
    }
    
    func createCircleTimeLabel(value: String) -> CircleLabel {
        let view = CircleLabel(frame: CGRect(x: 0, y: 0, width: 35.0, height: 35.0))
        view.userInteractionEnabled = true
        view.label.text = "\(value)"
        view.label.font = UIFont(name: "Neutraface Text", size: 14.0)
        view.sizeToFit()
        view.heightAnchor.constraintEqualToConstant(35).active = true
        view.widthAnchor.constraintEqualToConstant(35).active = true
        return view
    }
    
    func createClickableTimeLabel(value: String) -> CircleLabel {
        let view = createCircleTimeLabel(value)
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ScheduleViewController.timeSelected(_:)))
        recognizer.delegate = self
        view.addGestureRecognizer(recognizer)
        
        return view
    }
    
    func determineClosestTimeslotSection(hourSelected: NSDate) -> Int {
        for index in 0...dailySchedule.timeSlots.count - 1 {
            let timeSlot = dailySchedule.timeSlots[index]
            if timeSlot.time == hourSelected {
                return index
            }
        }
        return 0
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TimeSlotRootTableViewCell
        let session =  cell.session
        
        if (!session.cancelled) {
            let sessionDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("SessionDetailViewController") as! SessionDetailViewController
            sessionDetailVC.session = session
            self.navigationController!.pushViewController(sessionDetailVC, animated: true)
        }
    }
    
    // MARK: Data Source
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            moveToNext()
        }
        
        if (sender.direction == .Right) {
            moveToPrevious()
        }
    }
    
    internal func moveToNext() {
        self.moveToDay(self.nextDay)
    }
    
    internal func moveToPrevious() {
        self.moveToDay(self.previousDay)
    }
    
    internal func moveToDay(day: String!) {
        fatalError("Must Override")
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        fatalError("Must Override")
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
        if (dailySchedule == nil) {
            return 0
        }
        
        return dailySchedule.timeSlots.count
    }
    
    func setDirtyData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.dirtyDataFavorites = true;
    }
    
    func setFavoriteIcon(cell: ScheduleTableViewCell, animated: Bool) {
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