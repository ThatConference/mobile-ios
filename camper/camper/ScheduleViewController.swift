import UIKit

class ScheduleViewController : UIViewController {
    
    var store: SessionStore!
    let sessionDataSource = SessionDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.fetchAll() {
            (sessionResult) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                switch sessionResult {
                case let .Success(sessions):
                    print("Successfully found \(sessions.count) sessions.")
                    self.sessionDataSource.sessions = sessions
                case let .Failure(error):
                    self.sessionDataSource.sessions.removeAll()
                    print("Error fetching sessions: \(error)")
                }
                //self.collectionView.reloadSections(NSIndexSet(index: 0))
            }
        }
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let sessionStore = SessionStore()
//        sessionStore.fetchAll() {
//            (sessionResult) -> Void in
//            let sortBySessionDateTime = NSSortDescriptor(key: "ScheduledDateTime", ascending: true)
//            let allSessions = try! self.store.fetchMainQueueSessions(predicate: nil, sortDescriptors: [sortBySessionDateTime])
//            
//            NSOperationQueue.mainQueue().addOperationWithBlock() {
//                self.sessionDataSource.sessions = allSessions
//                //self.collectionView.reloadSections(NSIndexSet(index: 0))
//            }
//        }
//    }
}