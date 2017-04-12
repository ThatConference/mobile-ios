import UIKit

class TimeSlotRootViewController : BaseViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, ScheduleCellDelegate {
    
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
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.delegate = self
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(TimeSlotRootViewController.handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(TimeSlotRootViewController.handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    func createTimeLabel(_ value: String) -> UILabel {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.backgroundColor = UIColor.clear
        label.text = "\(value)"
        label.font = UIFont(name: "Neutraface Text", size: 14.0)
        
        return label
    }
    
    func createCircleTimeLabel(_ value: String) -> CircleLabel {
        let view = CircleLabel(frame: CGRect(x: 0, y: 0, width: 35.0, height: 35.0))
        view.isUserInteractionEnabled = true
        view.label.text = "\(value)"
        view.label.font = UIFont(name: "Neutraface Text", size: 14.0)
        view.sizeToFit()
        view.heightAnchor.constraint(equalToConstant: 35).isActive = true
        view.widthAnchor.constraint(equalToConstant: 35).isActive = true
        return view
    }
    
    func createClickableTimeLabel(_ value: String) -> CircleLabel {
        let view = createCircleTimeLabel(value)
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.timeSelected(_:)))
        recognizer.delegate = self
        view.addGestureRecognizer(recognizer)
        
        return view
    }
    
    func timeSelected(_ recognizer: UITapGestureRecognizer) {
        fatalError("Must Override")
    }
    
    func determineClosestTimeslotSection(_ hourSelected: Date) -> Int {
        if (dailySchedule.timeSlots.count > 0) {
            for index in 0...dailySchedule.timeSlots.count - 1 {
                let timeSlot = dailySchedule.timeSlots[index]
                if timeSlot?.time == hourSelected {
                    return index
                }
            }
        }
        return 0
    }
    
    // MARK: UITableViewDelegate
    
    func ScheduleCellDelegate(_ session: Session) {
        let session =  session
        
        if !(session.cancelled) {
            let sessionDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "SessionDetailViewController") as! SessionDetailViewController
            sessionDetailVC.session = session
            self.navigationController!.pushViewController(sessionDetailVC, animated: true)
        }
    }
    
    // MARK: Data Source
    func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            moveToNext()
        }
        
        if (sender.direction == .right) {
            moveToPrevious()
        }
    }
    
    internal func moveToNext() {
        self.moveToDay(self.nextDay)
    }
    
    internal func moveToPrevious() {
        self.moveToDay(self.previousDay)
    }
    
    internal func moveToDay(_ day: String!) {
        fatalError("Must Override")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Must Override")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (dailySchedule.timeSlots[section]?.sessions.count)! > 0 {
            return dailySchedule.timeSlots[section]!.sessions.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SessionStore.getFormattedTime(dailySchedule.timeSlots[section]?.time)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (dailySchedule == nil) {
            return 0
        }
        
        return dailySchedule.timeSlots.count
    }
    
    func setDirtyData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.dirtyDataFavorites = true;
    }
    
    func setFavoriteIcon(_ cell: ScheduleTableViewCell, animated: Bool) {
        DispatchQueue.main.async(execute: {
            if animated {
                CATransaction.begin()
                CATransaction.setAnimationDuration(1.5)
                let transition = CATransition()
                transition.type = kCATransitionFade
                cell.favoriteIcon!.layer.add(transition, forKey: kCATransitionFade)
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
