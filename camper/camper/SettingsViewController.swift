import UIKit

class SettingsViewController : UITableViewController {
    @IBOutlet var versionNumber: UILabel!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var loginImage: UIImageView!
    
    var loggedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Version Number
        let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        let build = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String
        versionNumber.text = "\(version).\(build)"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setSignInButton()
    }
    
    func setSignInButton() {
        if (Authentication.isLoggedIn()) {
            loginButton.setTitle("Sign Out", forState: UIControlState.Normal)
            loginImage.image = UIImage(named: "log-out")
        } else {
            loginButton.setTitle("Sign In", forState: UIControlState.Normal)
            loginImage.image = UIImage(named: "log-in")
        }
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        if (Authentication.isLoggedIn()) {
            Authentication.removeAuthToken()
            setDirtyData()
            let alert = UIAlertController(title: "Signed Out", message: "Sign out was successful. You can now sign in with a different account or continue as a guest.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            self.parentViewController!.parentViewController!.performSegueWithIdentifier("show_login", sender: self)
        }
        
        setSignInButton()
    }
    
    func setDirtyData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.dirtyDataSchedule = true;
        appDelegate.dirtyDataFavorites = true;
    }
}