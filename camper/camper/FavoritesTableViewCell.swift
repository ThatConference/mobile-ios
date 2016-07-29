import UIKit

class FavoritesTableViewCell: TimeSlotRootTableViewCell {
    @IBOutlet var updateFlag: UIImageView!
    @IBOutlet var sessionTitle: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var speakerLabel: UILabel!
    @IBOutlet var roomLabel: UILabel!
    @IBOutlet var favoriteIcon: UIImageView!
    @IBOutlet var cancelledCover: UIView!
    @IBOutlet var sessionTitleCancelled: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}