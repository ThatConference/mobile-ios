import UIKit

class AuthorizationViewController : UIViewController, ContainerDelegateProtocol {
    @IBOutlet var webContainer: UIView!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var usernameError: UILabel!
    @IBOutlet var passwordError: UILabel!
    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var twitterButton: UIButton!
    @IBOutlet var googleButton: UIButton!
    @IBOutlet var microsoftButton: UIButton!
    @IBOutlet var githubButton: UIButton!
    
    private var embeddedViewController: AuthorizationWebViewController!
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        //check here for the right segue by name
        if let vc = segue.destinationViewController as? AuthorizationWebViewController
            where segue.identifier == "showWebView" {
            (segue.destinationViewController as! AuthorizationWebViewController).delegate = self;
            self.embeddedViewController = vc
        }
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        //TODO: Check inputs
//        usernameError.text = "Not checked. Oh no!"
//        passwordError.text = "That is a good password"
        
        let authentication = Authentication()
        authentication.performLocalLogin(username.text!, password: password.text!)
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
    
    func Close() {
        webContainer.hidden = true;
    }
    
    func SignedIn() {
        let alert = UIAlertController(title: "Success", message: "Sign in was successful", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            self.DismissView()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func DismissView() {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func loginOAuth(provider: String) {
        print("Logging in with:" + provider)
        
        let authentication = Authentication()
        authentication.fetchExternalLogins() {
            (externalLoginResult) -> Void in
            
            switch externalLoginResult {
            case .Success(let externalLogins):
                print("External Logins Retrieved. \(externalLogins.count)")
                var url: NSURL!
                for externalLogin in externalLogins {
                    if (externalLogin.name == provider) {
                        url = NSURL(string: ThatConferenceAPI.baseURLString + externalLogin.url!)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.webContainer.hidden = false
                            self.embeddedViewController!.openOAuthDestination(url, provider: provider)
                        }
                        
                        break
                    }
                }
            case .Failure(let error):
                print("Error: \(error)")
            }
        }
        
    }
}