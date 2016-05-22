import UIKit

class SessionDetailViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var labelDate: UILabel!
    @IBOutlet var labelTime: UILabel!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var roomName: UILabel!
    @IBOutlet var labelDescription: UITextView!
    @IBOutlet var detailTable: UITableView!
    @IBOutlet var detailTableHeight: NSLayoutConstraint!
    @IBOutlet var detailSectionHeight: NSLayoutConstraint!
    
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
        labelDescription.text = session.sessionDescription
        labelDescription.scrollRangeToVisible(NSRange(location: 0, length: 0))
        roomName.text = session.scheduledRoom
        
        self.detailTable.separatorStyle = UITableViewCellSeparatorStyle.None
        self.detailTable.delegate = self
        self.detailTable.dataSource = self
        
        newTableHeight = 30 * CGFloat(session.speakers.count)
        detailTableHeight.constant = newTableHeight
        detailSectionHeight.constant = newTableHeight + 105
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
        cell.descriptionLabel.text = "\(speaker.firstName) \(speaker.lastName)"
        
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
}
