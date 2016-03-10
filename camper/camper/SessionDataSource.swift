import UIKit

class SessionDataSource: NSObject, UICollectionViewDataSource {
    
    var sessions: [Session] = []
    
    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            return sessions.count
    }
    
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            
            let identifier = "SessionCollectionViewCell"
            let cell =
            collectionView.dequeueReusableCellWithReuseIdentifier(identifier,
                forIndexPath: indexPath) as! SessionCollectionViewCell
            
            let session = sessions[indexPath.row]
            cell.session = session
            
            return cell
    }
}