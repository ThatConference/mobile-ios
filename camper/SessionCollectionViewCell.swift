import UIKit

class SessionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    var session: Session!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateWithSession()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        updateWithSession()
    }
    
    func updateWithSession() {
        
    }
}