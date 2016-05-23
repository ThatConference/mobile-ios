import UIKit

class FavoritesViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: if not logged in, show log in warning
        
        let sessionStore = SessionStore()
        sessionStore.getFavoriteSessions(completion: {(sessionResult) -> Void in
            switch sessionResult {
            case .Success(let sessions):
                
                break;
            case .Failure(_): break
            }
        })
    }
}