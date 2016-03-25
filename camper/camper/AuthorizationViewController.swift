import UIKit

class AuthorizationViewController : UIViewController {
    
    @IBAction func authorizeUsernamePassword(sender: AnyObject) {
        //TODO: Authorize using username/password
    }
    
    @IBAction func continueAsGuest(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}