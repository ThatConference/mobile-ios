import UIKit

class ScheduleViewController : UIViewController {
    override func viewDidLoad() {
        let sessionStore = SessionStore()
        sessionStore.fetchSessions()
    }
}