import UIKit

class AuthorizationViewController : UIViewController {
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var usernameError: UILabel!
    @IBOutlet var passwordError: UILabel!
    
    @IBAction func loginPressed(sender: AnyObject) {
        //TODO: Authorize using username/password
        usernameError.text = "No checked. Oh no!"
        passwordError.text = "That is a good password"
    }
    @IBAction func continueAsGuest(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func facebookPressed(sender: AnyObject) {
    }
    
    @IBAction func twitterPressed(sender: AnyObject) {
    }
    
    @IBAction func googlePressed(sender: AnyObject) {
    }
    
    @IBAction func windowsPressed(sender: AnyObject) {
    }
    
    @IBAction func githubPressed(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        usernameError.text = ""
        passwordError.text = ""
    }
}