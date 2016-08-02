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
        let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        let build = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String
        versionNumber.text = "\(version).\(build)"
        
        //Add TC Logo Tap
        let tcTapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(SettingsViewController.thatConferencePressed(_:)))
        tcLogo.userInteractionEnabled = true
        tcLogo.addGestureRecognizer(tcTapGestureRecognizer)
        
        //Add MC Logo Tap
        let mcTapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(SettingsViewController.milkcanPressed(_:)))
        mcLogo.userInteractionEnabled = true
        mcLogo.addGestureRecognizer(mcTapGestureRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setSignInButton()
        
        Answers.logContentViewWithName("Settings",
                                       contentType: "Page",
                                       contentId: "",
                                       customAttributes: [:])
    }
    
    func setSignInButton() {
        if (Authentication.isLoggedIn()) {
            loginButton.setTitle("Sign Out", forState: UIControlState.Normal)
        } else {
            loginButton.setTitle("Sign In", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        if (Authentication.isLoggedIn()) {
            Authentication.removeAuthToken()
            setDirtyData()
            PersistenceManager.deleteDailySchedule(Path.Favorites)
            let alert = UIAlertController(title: "Signed Out", message: "Sign out was successful. You can now sign in with a different account or continue as a guest.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            self.parentViewController!.parentViewController!.performSegueWithIdentifier("show_login", sender: self)
        }
        
        setSignInButton()
    }
    
    func thatConferencePressed(sender: AnyObject) {
        let url = "http://thatconference.com"
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
    
    func milkcanPressed(sender: AnyObject) {
        let url = "http://milkcan.io"
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
    
    @IBAction func sponsorsPressed(sender: AnyObject) {
        let mapVC = self.storyboard?.instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
        self.navigationController!.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func reportBugPressed(sender: AnyObject) {
        let url = "https://github.com/ThatConference/mobile-ios/issues"
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }

    func setDirtyData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.dirtyDataSchedule = true;
        appDelegate.dirtyDataFavorites = true;
    }
}