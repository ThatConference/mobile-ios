import UIKit
import Fabric
import Crashlytics

class SpeakerProfileViewController : BaseViewController {
    var speaker: Speaker!
    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var speakerName: UILabel!
    @IBOutlet var jobTitle: UILabel!
    @IBOutlet var company: UILabel!
    @IBOutlet var biography: UITextView!
    @IBOutlet var website: UIButton!
    
    @IBOutlet var twitterButton: UIButton!
    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var googleButton: UIButton!
    @IBOutlet var linkedInButton: UIButton!
    @IBOutlet var gitHubButton: UIButton!
    
    @IBAction func websiteButton(_ sender: AnyObject) {
        if let url = speaker.website
        {
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    @IBAction func twitterButton(_ sender: AnyObject) {
        if let url = speaker.twitter
        {
            UIApplication.shared.openURL(URL(string: "https://twitter.com/" + url)!)
        }
    }
    
    @IBAction func facebookButton(_ sender: AnyObject) {
        if let url = speaker.facebook
        {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func googleButton(_ sender: AnyObject) {
        if let url = speaker.googlePlus
        {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func linkedinButton(_ sender: AnyObject) {
        if let url = speaker.linkedIn
        {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func githubButton(_ sender: AnyObject) {
        if let url = speaker.gitHub
        {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        if let headshot = speaker.headShotURL
        {
            let url = ThatConferenceAPI.resourceURL(headshot.absoluteString)
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async(execute: {
                        self.profileImage.image = UIImage(data: data)
                    });
                }
            }
        }

        let speakerFullName = "\(speaker.firstName!) \(speaker.lastName!)"
        speakerName.text = speakerFullName
        jobTitle.text = speaker.title
        company.text = speaker.company
        
        website.titleLabel?.text = ""
        if let speakerWebsite = speaker.website
        {
            website.setTitle(speakerWebsite.absoluteString, for: UIControlState())
        }
        
        if let bioText = speaker.biography
        {
            biography.text = bioText
        }
        
        setSocialButtons()
        
        Answers.logContentView(withName: "Session Detail",
                                       contentType: "Page",
                                       contentId: speakerFullName,
                                       customAttributes: [:])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        biography.setContentOffset(CGPoint.zero, animated: false)
    }
    
    fileprivate func setSocialButtons() {
        if speaker.twitter == nil
        {
            twitterButton.isHidden = true
        }
        if speaker.facebook == nil
        {
            facebookButton.isHidden = true
        }
        if speaker.googlePlus == nil
        {
            googleButton.isHidden = true
        }
        if speaker.linkedIn == nil
        {
            linkedInButton.isHidden = true
        }
        if speaker.gitHub == nil
        {
            gitHubButton.isHidden = true
        }
    }
}
