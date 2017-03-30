import UIKit
import CoreGraphics

class ScheduleTableViewCell: TimeSlotRootTableViewCell {
    @IBOutlet weak var updateFlag: UIImageView!
    @IBOutlet weak var sessionTitle: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var speakerLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var favoriteIcon: UIImageView!
    @IBOutlet weak var cancelledCover: UIView!
    @IBOutlet weak var sessionTitleCancelled: UILabel!
    @IBOutlet weak var levelLabel: UILabel!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
