import UIKit

class BaseViewController: UIViewController, AuthorizationFormDelegate {
    
    var activityIndicator: UIActivityIndicatorView!
    var alert: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(StateData.instance.offlineFavoriteSessions.sessions)
        
        self.activityIndicator = UIActivityIndicatorView()
        self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        self.activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.4)
        self.activityIndicator.layer.cornerRadius = 10
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.activityIndicator.clipsToBounds = true
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.center = self.view.center
        
        self.view.addSubview(self.activityIndicator)
        
        // That Post Card
        let cameraBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        cameraBtn.setImage(UIImage(named: "camera"), for: UIControlState())
        cameraBtn.addTarget(self, action: #selector(self.moveToCamera), for:  UIControlEvents.touchUpInside)
        let item = UIBarButtonItem(customView: cameraBtn)
        self.navigationItem.rightBarButtonItem = item
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newVC = segue.destination as? AuthorizationViewController {
            newVC.delegate = self
        }
    }
    
    func dismissViewController(_ controller: UIViewController) {
        controller.dismiss(animated: true) { () -> Void in
            self.navigateToSchedule()
        }
    }
    
    internal func navigateToSchedule() {
        setData(true)
        self.tabBarController?.selectedIndex = 1
    }
    
    internal func setData(_ isDirty: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.dirtyDataFavorites = isDirty;
    }
    
    @objc fileprivate func moveToCamera() {
        self.moveToPostCard()
    }
    
    fileprivate func moveToPostCard() {
        let postCardVC = self.storyboard?.instantiateViewController(withIdentifier: "PostCardChoosePhotoViewController") as! PostCardChoosePhotoViewController
        self.present(postCardVC, animated: true, completion: nil)
    }
    
    func startIndicator() {
        DispatchQueue.main.async(execute: {
            self.activityIndicator.startAnimating()
        })
    }
    
    func stopIndicator() {
        DispatchQueue.main.async(execute: {
            self.activityIndicator.stopAnimating()
        })
    }
    
    func simpleAlert(title: String, body: String) {
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    // Offline Favoriting
    
    func syncOfflineFavorites() {
        if currentReachabilityStatus != .notReachable {
            if StateData.instance.offlineFavoriteSessions.sessions.count > 0 {
                ThatConferenceAPI.saveOfflineFavorites(offlineFavorites: StateData.instance.offlineFavoriteSessions.sessions)
            } else {
                if let data = PersistenceManager.loadOfflineFavorites(Path.OfflineFavorites) {
                    ThatConferenceAPI.saveOfflineFavorites(offlineFavorites: data.sessions)
                }
            }
        }
    }
    
    func saveOfflineFavorites(currentSession: Session, isOffline: Bool, completed: @escaping DownloadComplete) {
        guard let sessionId = currentSession.id else {return}
        
        StateData.instance.offlineFavoriteSessions.sessions["\(sessionId)"] = currentSession
        PersistenceManager.saveOfflineFavorites(StateData.instance.offlineFavoriteSessions, path: Path.OfflineFavorites)
        
        if isOffline {
            saveOfflineScheduleFavorite(currentSession: currentSession)
            offlineFavorite(currentSession: currentSession)
        }
        
        completed()
    }
    
    func saveOfflineScheduleFavorite(currentSession: Session) {
        // Saves Offline Schedule Favorites
        var schedule: Dictionary<String, DailySchedule>!
        
        if currentSession.primaryCategory == "Open Spaces" {
            if let schedulePersistence = PersistenceManager.loadDailySchedule(Path.OpenSpaces) {
                schedule = schedulePersistence
                var dateString = String()
                if let date = currentSession.scheduledDateTime {
                    dateString = self.getDate(date)
                }
                
                if let timeSlot = schedulePersistence[dateString]?.timeSlots {
                    for i in 0..<timeSlot.count {
                        var array: [Session] = []
                        guard let sessions = timeSlot[i]?.sessions else { break }
                        array = sessions as! [Session]
                        for t in 0..<sessions.count {
                            guard let sessionId = sessions[t]?.id else { break }
                            if sessionId == currentSession.id {
                                array[t] = currentSession
                            }
                        }
                        schedule[dateString]?.timeSlots[i]?.sessions = array
                    }
                }
            }
            
            PersistenceManager.saveDailySchedule(schedule, path: Path.OpenSpaces)
        } else {
            if let schedulePersistence = PersistenceManager.loadDailySchedule(Path.Schedule) {
                schedule = schedulePersistence
                var dateString = String()
                if let date = currentSession.scheduledDateTime {
                    dateString = self.getDate(date)
                }
                
                if let timeSlot = schedulePersistence[dateString]?.timeSlots {
                    for i in 0..<timeSlot.count {
                        var array: [Session] = []
                        guard let sessions = timeSlot[i]?.sessions else { break }
                        array = sessions as! [Session]
                        for t in 0..<sessions.count {
                            guard let sessionId = sessions[t]?.id else { break }
                            if sessionId == currentSession.id {
                                array[t] = currentSession
                            }
                        }
                        schedule[dateString]?.timeSlots[i]?.sessions = array
                    }
                }
            }
            
            PersistenceManager.saveDailySchedule(schedule, path: Path.Schedule)
        }
        
    }
    
    func offlineFavorite(currentSession: Session) {
        
        var favorites: Dictionary<String, DailySchedule>!
        
        if let data = PersistenceManager.loadDailySchedule(Path.Favorites) {
            favorites = data
            
            var dateString = String()
            if let date = currentSession.scheduledDateTime {
                dateString = self.getDate(date as Date)
            }
            
            if currentSession.isUserFavorite {
                if (favorites[dateString]) == nil {
                    let dailySchedule = DailySchedule()
                    if let date = currentSession.scheduledDateTime {
                        dailySchedule.date = date
                        favorites[dateString] = dailySchedule
                    }
                }
                
                var wasFound = false
                if let timeSlots = favorites[dateString]?.timeSlots {
                    for t in 0..<timeSlots.count {
                        if timeSlots[t]?.time == currentSession.scheduledDateTime {
                            favorites[dateString]?.timeSlots[t]?.sessions.append(currentSession)
                            wasFound = true
                        }
                    }
                }
                
                if !wasFound {
                    let timeSlot = TimeSlot()
                    timeSlot.time = currentSession.scheduledDateTime
                    timeSlot.sessions = [currentSession]
                    
                    favorites[dateString]?.timeSlots.append(timeSlot)
                    if let timeSlots = favorites[dateString]?.timeSlots {
                        if timeSlots.count > 1 {
                            favorites[dateString]?.timeSlots.sort {
                                let sortOne = $0.0?.time
                                let sortTwo = $0.1?.time
                                return sortOne! < sortTwo!
                            }
                        }
                    }
                }
            } else {
                if let timeSlots = favorites[dateString]?.timeSlots {
                    for i in (0..<timeSlots.count).reversed() {
                        if let sessions = timeSlots[i]?.sessions {
                            for t in (0..<sessions.count).reversed() {
                                if sessions[t]?.id == currentSession.id {
                                    favorites[dateString]?.timeSlots[i]?.sessions.remove(at: t)
                                }
                            }
                            if favorites[dateString]?.timeSlots[i]?.sessions.count == 0 {
                                favorites[dateString]?.timeSlots.remove(at: i)
                            }
                        }
                    }
                }
                
                if favorites[dateString]?.timeSlots.count == 0 {
                    favorites.removeValue(forKey: dateString)
                }
            }
        }
        PersistenceManager.saveDailySchedule(favorites, path: Path.Favorites)
    }
    
    func getDate(_ dateTime: Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-YYYY"
        
        return dateFormatter.string(from: dateTime!)
    }
    
    class func getFormattedTime(_ dateTime: Date?) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        
        return timeFormatter.string(from: dateTime!)
    }
    
    func revealViewControllerFunc(barButton: UIBarButtonItem) {
        if revealViewController() != nil {
            barButton.target = revealViewController()
            barButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().panGestureRecognizer().isEnabled = false
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
}
