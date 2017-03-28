import UIKit
import Fabric
import Crashlytics

protocol AuthorizationFormDelegate: class {
    func dismissViewController(_ controller: UIViewController)
}

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
    
    fileprivate var embeddedViewController: AuthorizationWebViewController!
    var delegate: AuthorizationFormDelegate!
    
    override func viewDidLoad() {
        clearErrors()
        
        let usernameSpacerView = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
        username.leftViewMode = UITextFieldViewMode.always
        username.leftView = usernameSpacerView
        
        let passwordSpacerView = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
        password.leftViewMode = UITextFieldViewMode.always
        password.leftView = passwordSpacerView
        
        //Force ContentMode for Buttons - Does not work from XIB
        facebookButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        twitterButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        googleButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        microsoftButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        githubButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        //check here for the right segue by name
        if let vc = segue.destination as? AuthorizationWebViewController
            , segue.identifier == "showWebView" {
            (segue.destination as! AuthorizationWebViewController).delegate = self;
            self.embeddedViewController = vc
        }
    }
    
    func clearErrors() {
        usernameError.text = ""
        passwordError.text = ""
        generalError.text = ""
    }
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        clearErrors()
        
        let authentication = Authentication()
        authentication.performLocalLogin(username.text!, password: password.text!, completionDelegate: self)
    }
    @IBAction func continueAsGuest(_ sender: AnyObject) {
        if self.delegate != nil {
            self.delegate.dismissViewController(self)
        } else {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func facebookPressed(_ sender: AnyObject) {
        loginOAuth("Facebook")
    }
    
    @IBAction func twitterPressed(_ sender: AnyObject) {
        loginOAuth("Twitter")
    }
    
    @IBAction func googlePressed(_ sender: AnyObject) {
        loginOAuth("Google")
    }
    
    @IBAction func microsoftPressed(_ sender: AnyObject) {
        loginOAuth("Microsoft")
    }
    
    @IBAction func githubPressed(_ sender: AnyObject) {
        loginOAuth("GitHub")
    }
    
    func Close() {
        webContainer.isHidden = true;
    }
    
    func SignedIn() {
        setDirtyData()
        self.DismissView()
    }
    
    fileprivate func DismissView() {
        self.dismiss(animated: false, completion: nil)
    }
    
    func loginOAuth(_ provider: String) {
        print("Logging in with:" + provider)
        
        let authentication = Authentication()
        authentication.fetchExternalLogins() {
            (externalLoginResult) -> Void in
            
            switch externalLoginResult {
            case .success(let externalLogins):
                print("External Logins Retrieved. \(externalLogins.count)")
                var url: URL!
                for externalLogin in externalLogins {
                    if (externalLogin.name == provider) {
                        url = URL(string: ThatConferenceAPI.baseURLString + externalLogin.url!)
                        
                        DispatchQueue.main.async {
                            self.webContainer.isHidden = false
                            self.embeddedViewController!.openOAuthDestination(url, provider: provider)
                        }
                        
                        break
                    }
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func setDirtyData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.dirtyDataSchedule = true;
        appDelegate.dirtyDataFavorites = true;
    }
    
    func DataReceived(data : Data?, response : URLResponse?, error : Error?) {
        guard let httpResponse = response as? HTTPURLResponse else {
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
            print(error ?? "Unknown Error")
            loginError("Server Error. Bad Response.")
            return
        }
        
        let post: NSDictionary
        do {
            post = try JSONSerialization.jsonObject(with: responseData,
                                                              options: []) as! NSDictionary
        } catch  {
            print("error trying to convert data to JSON")
            loginError("Server Error. Bad Response.")
            return
        }
        
        guard let
            accessToken = post["access_token"] as? String,
            let expiresIn = post["expires_in"] as? Double
            else {
                print("Could not parse data to internal login")
                loginError("Server Error. Bad Response.")
                return
        }
        
        let token = AuthToken()
        token.token = accessToken
        token.expiration = Date().addingTimeInterval(Double(expiresIn))
        Authentication.saveAuthToken(token)
        
        print("Sign in was successful")
        Answers.logLogin(withMethod: "InternalLogin", success: true, customAttributes: [:])
        DispatchQueue.main.async {
            self.SignedIn()
        }
    }
    
    func loginError(_ errorMessage: String) {
        DispatchQueue.main.async {
            self.generalError.text = errorMessage
        }
    }
}
