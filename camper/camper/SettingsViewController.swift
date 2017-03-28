import UIKit
import Crashlytics
import Fabric

class SettingsViewController : BaseViewController {
    @IBOutlet var versionNumber: UILabel!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var tcLogo: UIImageView!
    @IBOutlet var mcLogo: UIImageView!
    @IBOutlet var sponsorsButton: UIButton!
    
    var loggedIn = false
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSignInButton()
        
        Answers.logContentView(withName: "Settings",
                                       contentType: "Page",
                                       contentId: "",
                                       customAttributes: [:])
    }
    
    func setSignInButton() {
        if (Authentication.isLoggedIn()) {
            loginButton.setTitle("Sign Out", for: UIControlState())
        } else {
            loginButton.setTitle("Sign In", for: UIControlState())
        }
    }
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        if (Authentication.isLoggedIn()) {
            Authentication.removeAuthToken()
            setDirtyData()
            _ = PersistenceManager.deleteDailySchedule(Path.Favorites)
            let alert = UIAlertController(title: "Signed Out", message: "Sign out was successful. You can now sign in with a different account or continue as a guest.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.parent!.parent!.performSegue(withIdentifier: "show_login", sender: self)
        }
        
        setSignInButton()
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
