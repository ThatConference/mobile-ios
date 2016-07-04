import UIKit

class AuthorizationViewController : UIViewController, ContainerDelegateProtocol, RequestCompleteProtocol {
    @IBOutlet var webContainer: UIView!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var usernameError: UILabel!
    @IBOutlet var passwordError: UILabel!
    @IBOutlet var generalError: UILabel!
    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var twitterButton: UIButton!
    @IBOutlet var googleButton: UIButton!
    @IBOutlet var microsoftButton: UIButton!
    @IBOutlet var githubButton: UIButton!
    
    private var embeddedViewController: AuthorizationWebViewController!
    
    override func viewDidLoad() {
        clearErrors()
        
        let usernameSpacerView = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
        username.leftViewMode = UITextFieldViewMode.Always
        username.leftView = usernameSpacerView
        
        let passwordSpacerView = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
        password.leftViewMode = UITextFieldViewMode.Always
        password.leftView = passwordSpacerView
        
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
    
    func clearErrors() {
        usernameError.text = ""
        passwordError.text = ""
        generalError.text = ""
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        clearErrors()
        
        let authentication = Authentication()
        authentication.performLocalLogin(username.text!, password: password.text!, completionDelegate: self)
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
        setDirtyData()
        self.DismissView()
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
    
    func setDirtyData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.dirtyDataSchedule = true;
        appDelegate.dirtyDataFavorites = true;
    }
    
    func DataReceived(data : NSData?, response : NSURLResponse?, error : NSError?) {
        guard let httpResponse = response as? NSHTTPURLResponse else {
            print("Error: could not read response")
            loginError("Server Error. No Response.")
            return
        }
        
        if (httpResponse.statusCode == 400) {
            print("Wrong Credentials")
            loginError("Invalid Username / Password")
            return
        }
        
        guard let responseData = data else {
            print("Error: did not receive data")
            loginError("Server Error. No Response.")
            return
        }
        
        guard error == nil else {
            print("error calling GET on /posts/1")
            print(error)
            loginError("Server Error. Bad Response.")
            return
        }
        
        let post: NSDictionary
        do {
            post = try NSJSONSerialization.JSONObjectWithData(responseData,
                                                              options: []) as! NSDictionary
        } catch  {
            print("error trying to convert data to JSON")
            loginError("Server Error. Bad Response.")
            return
        }
        
        guard let
            accessToken = post["access_token"] as? String,
            expiresIn = post["expires_in"] as? Double
            else {
                print("Could not parse data to internal login")
                loginError("Server Error. Bad Response.")
                return
        }
        
        let token = AuthToken()
        token.token = accessToken
        token.expiration = NSDate().dateByAddingTimeInterval(Double(expiresIn))
        Authentication.saveAuthToken(token)
        
        print("Sign in was successful")
        dispatch_async(dispatch_get_main_queue()) {
            self.SignedIn()
        }
    }
    
    func loginError(errorMessage: String) {
        dispatch_async(dispatch_get_main_queue()) {
            self.generalError.text = errorMessage
        }
    }
}