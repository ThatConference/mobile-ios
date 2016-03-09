import UIKit

class SessionDataSource: NSObject, UICollectionViewDataSource {
    
    var sessions: [Session] = []
    
    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            return sessions.count
    }
    
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            
            let identifier = "UICollectionViewCell"
            let cell =
            collectionView.dequeueReusableCellWithReuseIdentifier(identifier,
                forIndexPath: indexPath) as! SessionCollectionViewCell
            
            //let session = sessions[indexPath.row]
            
            return cell
    }
}