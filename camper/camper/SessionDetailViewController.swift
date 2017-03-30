import UIKit
import Fabric
import Crashlytics

class SessionDetailViewController : BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var roomName: UILabel!
    @IBOutlet weak var labelDescription: UITextView!
    @IBOutlet weak var detailTable: UITableView!
    @IBOutlet weak var detailTableHeight: NSLayoutConstraint!
    @IBOutlet weak var detailSectionHeight: NSLayoutConstraint!
    @IBOutlet weak var favoriteButton: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    
    var session: Session!
    var newTableHeight = CGFloat(0)
    let textCellIdentifier = "SpeakerCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        setDateLabel(session.scheduledDateTime! as Date)
        setTimeLabel(session.scheduledDateTime! as Date)
        
        labelTitle.text = session.title
        labelCategory.text = session.primaryCategory
        labelDescription.text = session.sessionDescription
        roomName.text = session.scheduledRoom
        if let level = session.level {
            levelLabel.text = "Level: \(level)"
        }
        
        self.detailTable.separatorStyle = UITableViewCellSeparatorStyle.none
        self.detailTable.delegate = self
        self.detailTable.dataSource = self
        
        newTableHeight = 30 * CGFloat(session.speakers.count)
        detailTableHeight.constant = newTableHeight
        detailSectionHeight.constant = newTableHeight + 105
        self.view.layoutIfNeeded()
        
        favoriteButton.isUserInteractionEnabled = true
        favoriteButton!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SessionDetailViewController.SessionFavorited(_:))))
        
        Answers.logContentView(withName: "Session Detail",
                                       contentType: "Page",
                                       contentId: session.title,
                                       customAttributes: [:])
        
        setFavoriteIcon(false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        labelDescription.setContentOffset(CGPoint.zero, animated: false)
    }
    
    @IBAction func RoomButtonPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "OpenMap", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenMap"
        {
            if let mapVC = segue.destination as? MapViewController {
                mapVC.roomName = session.scheduledRoom
            }
        }
    }
    
    fileprivate func setDateLabel(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE MMM dd"
        self.labelDate.text = dateFormatter.string(from: date)
    }
    
    fileprivate func setTimeLabel(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        self.labelTime.text = dateFormatter.string(from: date)
    }
    
    // MARK:  UITextFieldDelegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return session.speakers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as! PageDetailCell
        
        let row = (indexPath as NSIndexPath).row
        let speaker = session.speakers[row]
        
        cell.speaker = speaker
        cell.descriptionLabel.text = "\(speaker.firstName!) \(speaker.lastName!)"
        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as! PageDetailCell
        let speaker =  cell.speaker
        let speakerDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "SpeakerProfileViewController") as! SpeakerProfileViewController
        speakerDetailVC.speaker = speaker
        self.navigationController!.pushViewController(speakerDetailVC, animated: true)
    }
    
    // MARK: Favoriting
    
    func SessionFavorited(_ sender: UITapGestureRecognizer) {
        if Authentication.isLoggedIn() {
            let sessionStore = SessionStore()
            if self.session.isUserFavorite {
                sessionStore.removeFavorite(self.session, completion:{(sessionsResult) -> Void in
                    switch sessionsResult {
                    case .success(let sessions):
                        CATransaction.begin()
                        CATransaction.setAnimationDuration(1.5)
                        let transition = CATransition()
                        transition.type = kCATransitionFade
                        self.favoriteButton!.layer.add(transition, forKey: kCATransitionFade)
                        CATransaction.commit()
                        self.favoriteButton!.image = UIImage(named:"like-remove")
                        
                        self.setDirtyData()
                        self.session = sessions.first
                        self.setFavoriteIcon(true)
                        break
                    case .failure(_):
                        let alert = UIAlertController(title: "Error", message: "Could not remove favorite at this time. Check your connection.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        break
                    }
                })
                
            }
            else {
                sessionStore.addFavorite(self.session, completion:{(sessionsResult) -> Void in
                    switch sessionsResult {
                    case .success(let sessions):
                        CATransaction.begin()
                        CATransaction.setAnimationDuration(1.5)
                        let transition = CATransition()
                        transition.type = kCATransitionFade
                        self.favoriteButton!.layer.add(transition, forKey: kCATransitionFade)
                        CATransaction.commit()
                        self.favoriteButton!.image = UIImage(named:"likeadded")
                        
                        self.setDirtyData()
                        self.session = sessions.first
                        self.setFavoriteIcon(true)
                        break
                    case .failure(_):
                        let alert = UIAlertController(title: "Error", message: "Could not add favorite at this time. Check your connection.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        break
                    }
                })
            }
        }
        else
        {
            self.parent!.parent!.performSegue(withIdentifier: "show_login", sender: self)
        }
    }
    
    func setDirtyData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.dirtyDataFavorites = true;
    }
    
    fileprivate func setFavoriteIcon(_ animated: Bool) {
        DispatchQueue.main.async(execute: { 
            if animated {
                CATransaction.begin()
                CATransaction.setAnimationDuration(1.5)
                let transition = CATransition()
                transition.type = kCATransitionFade
                self.favoriteButton!.layer.add(transition, forKey: kCATransitionFade)
                CATransaction.commit()
            }
            if self.session.isUserFavorite {
                self.favoriteButton!.image = UIImage(named:"like-remove")
            }
            else {
                self.favoriteButton!.image = UIImage(named:"like-1")
            }
        })
    }
}
