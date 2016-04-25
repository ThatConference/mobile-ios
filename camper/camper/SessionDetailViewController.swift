import UIKit

class SessionDetailViewController : UIViewController {
    @IBOutlet var labelDate: UILabel!
    @IBOutlet var labelTime: UILabel!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelSpeaker: UILabel!
    @IBOutlet var labelRoom: UILabel!
    @IBOutlet var labelDescription: UITextView!
    
    var session: Session!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDateLabel(session.scheduledDateTime!)
        setTimeLabel(session.scheduledDateTime!)
        setSpeakers(session.speakers)
        
        labelTitle.text = session.title
        labelRoom.text = session.scheduledRoom
        labelDescription.text = session.sessionDescription
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
    
    private func setSpeakers(speakers: [Speaker]) {
        var speakerString: String = ""
        var firstSpeaker: Bool = true
        for speaker in speakers {
            if !firstSpeaker {
                speakerString.appendContentsOf(", ")
            } else {
                firstSpeaker = false
            }
            
            speakerString.appendContentsOf("\(speaker.firstName) \(speaker.lastName)")
        }
        self.labelSpeaker.text = speakerString
    }
}
