import UIKit

class AuthorizationViewController : UIViewController {
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var usernameError: UILabel!
    @IBOutlet var passwordError: UILabel!
    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var twitterButton: UIButton!
    @IBOutlet var googleButton: UIButton!
    @IBOutlet var microsoftButton: UIButton!
    @IBOutlet var githubButton: UIButton!
    
    override func viewDidLoad() {
        usernameError.text = ""
        passwordError.text = ""
        
        //Force ContentMode for Buttons - Does not work from XIB
        facebookButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        twitterButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        googleButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        microsoftButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        githubButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    ///api3/Account/ExternalLogins?returnUrl=%2F&generateState=true
    
    @IBAction func loginPressed(sender: AnyObject) {
        //TODO: Authorize using username/password
        usernameError.text = "Not checked. Oh no!"
        passwordError.text = "That is a good password"
    }
    @IBAction func continueAsGuest(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func facebookPressed(sender: AnyObject) {
        loginOAuth("Facebook")
    }
    
    @IBAction func twitterPressed(sender: AnyObject) {
        loginOAuth("Twitter")
    }
    
    @IBAction func googlePressed(sender: AnyObject) {
        loginOAuth("Google")
    }
    
    @IBAction func microsoftPressed(sender: AnyObject) {
        loginOAuth("Microsoft")
    }
    
    @IBAction func githubPressed(sender: AnyObject) {
        loginOAuth("GitHub")
    }
    
    func loginOAuth(vendor: String) {
        print("Logging in with:" + vendor)
    }
}