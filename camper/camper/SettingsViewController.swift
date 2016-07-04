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
        
        // camera button
        let cameraBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        cameraBtn.setImage(UIImage(named: "camera"), forState: UIControlState.Normal)
        cameraBtn.addTarget(self, action: #selector(self.moveToCamera), forControlEvents:  UIControlEvents.TouchUpInside)
        let item = UIBarButtonItem(customView: cameraBtn)
        self.navigationItem.rightBarButtonItem = item
    }
    
    @objc private func moveToCamera() {
        self.moveToPostCard()
    }
    
    private func moveToPostCard() {
        let postCardVC = self.storyboard?.instantiateViewControllerWithIdentifier("PostCardChooseFrameViewController") as! PostCardChooseFrameViewController
        self.navigationController!.pushViewController(postCardVC, animated: true)
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
            PersistenceManager.deleteDailySchedule(Path.Favorites)
            let alert = UIAlertController(title: "Signed Out", message: "Sign out was successful. You can now sign in with a different account or continue as a guest.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            self.parentViewController!.parentViewController!.performSegueWithIdentifier("show_login", sender: self)
        }
        
        setSignInButton()
    }
    
    @IBAction func developedPressed(sender: AnyObject) {
        let url = "http://milkcan.io"
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
    
    @IBAction func inWisconsinPressed(sender: AnyObject) {
        let url = "http://inwisconsin.com/"
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
    
    @IBAction func thatConferencePressed(sender: AnyObject) {
        let url = "http://thatconference.com"
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
    
    func setDirtyData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.dirtyDataSchedule = true;
        appDelegate.dirtyDataFavorites = true;
    }
}