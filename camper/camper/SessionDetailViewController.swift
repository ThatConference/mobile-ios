import UIKit

class SessionDetailViewController : BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var labelDate: UILabel!
    @IBOutlet var labelTime: UILabel!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelCategory: UILabel!
    @IBOutlet var roomName: UILabel!
    @IBOutlet var labelDescription: UITextView!
    @IBOutlet var detailTable: UITableView!
    @IBOutlet var detailTableHeight: NSLayoutConstraint!
    @IBOutlet var detailSectionHeight: NSLayoutConstraint!
    @IBOutlet var favoriteButton: UIImageView!
    
    var session: Session!
    var newTableHeight = CGFloat(0)
    let textCellIdentifier = "SpeakerCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        setDateLabel(session.scheduledDateTime!)
        setTimeLabel(session.scheduledDateTime!)
        
        labelTitle.text = session.title
        labelCategory.text = session.primaryCategory
        labelDescription.text = session.sessionDescription
        roomName.text = session.scheduledRoom
        
        self.detailTable.separatorStyle = UITableViewCellSeparatorStyle.None
        self.detailTable.delegate = self
        self.detailTable.dataSource = self
        
        newTableHeight = 30 * CGFloat(session.speakers.count)
        detailTableHeight.constant = newTableHeight
        detailSectionHeight.constant = newTableHeight + 105
        self.view.layoutIfNeeded()
        
        favoriteButton.userInteractionEnabled = true
        favoriteButton!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SessionDetailViewController.SessionFavorited(_:))))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        labelDescription.setContentOffset(CGPointZero, animated: false)
    }
    
    @IBAction func RoomButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("OpenMap", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "OpenMap"
        {
            if let mapVC = segue.destinationViewController as? MapViewController {
                mapVC.roomName = session.scheduledRoom
            }
        }
    }
    
    private func setDateLabel(date: NSDate) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE MMM dd"
        self.labelDate.text = dateFormatter.stringFromDate(date)
    }
    
    private func setTimeLabel(date: NSDate) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        self.labelTime.text = dateFormatter.stringFromDate(date)
    }
    
    // MARK:  UITextFieldDelegate Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return session.speakers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as! PageDetailCell
        
        let row = indexPath.row
        let speaker = session.speakers[row]
        
        cell.speaker = speaker
        cell.descriptionLabel.text = "\(speaker.firstName!) \(speaker.lastName!)"
        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PageDetailCell
        let speaker =  cell.speaker
        let speakerDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("SpeakerProfileViewController") as! SpeakerProfileViewController
        speakerDetailVC.speaker = speaker
        self.navigationController!.pushViewController(speakerDetailVC, animated: true)
    }
    
    // MARK: Favoriting
    
    func SessionFavorited(sender: UITapGestureRecognizer) {
        if Authentication.isLoggedIn() {
            let sessionStore = SessionStore()
            if self.session.isUserFavorite {
                sessionStore.removeFavorite(self.session, completion:{(sessionsResult) -> Void in
                    switch sessionsResult {
                    case .Success(let sessions):
                        CATransaction.begin()
                        CATransaction.setAnimationDuration(1.5)
                        let transition = CATransition()
                        transition.type = kCATransitionFade
                        self.favoriteButton!.layer.addAnimation(transition, forKey: kCATransitionFade)
                        CATransaction.commit()
                        self.favoriteButton!.image = UIImage(named:"like-remove")
                        
                        self.setDirtyData()
                        self.session = sessions.first
                        self.setFavoriteIcon(animated: true)
                        break
                    case .Failure(_):
                        let alert = UIAlertController(title: "Error", message: "Could not remove favorite at this time. Check your connection.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        break
                    }
                })
                
            }
            else {
                sessionStore.addFavorite(self.session, completion:{(sessionsResult) -> Void in
                    switch sessionsResult {
                    case .Success(let sessions):
                        CATransaction.begin()
                        CATransaction.setAnimationDuration(1.5)
                        let transition = CATransition()
                        transition.type = kCATransitionFade
                        self.favoriteButton!.layer.addAnimation(transition, forKey: kCATransitionFade)
                        CATransaction.commit()
                        self.favoriteButton!.image = UIImage(named:"likeadded")
                        
                        self.setDirtyData()
                        self.session = sessions.first
                        self.setFavoriteIcon(animated: true)
                        break
                    case .Failure(_):
                        let alert = UIAlertController(title: "Error", message: "Could not add favorite at this time. Check your connection.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        break
                    }
                })
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
    
    private func setFavoriteIcon(animated animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), { 
            if animated {
                CATransaction.begin()
                CATransaction.setAnimationDuration(1.5)
                let transition = CATransition()
                transition.type = kCATransitionFade
                self.favoriteButton!.layer.addAnimation(transition, forKey: kCATransitionFade)
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
