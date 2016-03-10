import UIKit

class ScheduleViewController : UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var store: SessionStore!
    let sessionDataSource = SessionDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sessionStore = SessionStore()
        sessionStore.fetchAll() {
            (sessionResult) -> Void in
            let sortBySessionDateTime = NSSortDescriptor(key: "scheduledDateTime", ascending: true)
            let allSessions = try! self.store.fetchMainQueueSessions(predicate: nil, sortDescriptors: [sortBySessionDateTime])
            
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.sessionDataSource.sessions = allSessions
                print("Successfully loaded \(allSessions.count) sessions.")
                self.collectionView.reloadSections(NSIndexSet(index: 0))
            }
        }
    }
}