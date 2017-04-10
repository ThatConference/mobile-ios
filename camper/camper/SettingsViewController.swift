import UIKit
import Crashlytics
import Fabric

class SettingsViewController : BaseViewController {
    @IBOutlet var versionNumber: UILabel!
    @IBOutlet var tcLogo: UIImageView!
    @IBOutlet var mcLogo: UIImageView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Version Number
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        versionNumber.text = "\(version).\(build)"
        
        //Add TC Logo Tap
        let tcTapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(SettingsViewController.thatConferencePressed(_:)))
        tcLogo.isUserInteractionEnabled = true
        tcLogo.addGestureRecognizer(tcTapGestureRecognizer)
        
        //Add MC Logo Tap
        let mcTapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(SettingsViewController.milkcanPressed(_:)))
        mcLogo.isUserInteractionEnabled = true
        mcLogo.addGestureRecognizer(mcTapGestureRecognizer)
        self.revealViewControllerFunc(barButton: menuButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Answers.logContentView(withName: "Settings",
                                       contentType: "Page",
                                       contentId: "",
                                       customAttributes: [:])
    }
    
    func thatConferencePressed(_ sender: AnyObject) {
        let url = "http://thatconference.com"
        UIApplication.shared.openURL(URL(string: url)!)
    }
    
    func milkcanPressed(_ sender: AnyObject) {
        let url = "http://milkcan.io"
        UIApplication.shared.openURL(URL(string: url)!)
    }
    
    @IBAction func sponsorsPressed(_ sender: AnyObject) {
        let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        self.navigationController!.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func reportBugPressed(_ sender: AnyObject) {
        let url = "https://github.com/ThatConference/mobile-ios/issues"
        UIApplication.shared.openURL(URL(string: url)!)
    }

    func setDirtyData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.dirtyDataSchedule = true;
        appDelegate.dirtyDataFavorites = true;
    }
}
