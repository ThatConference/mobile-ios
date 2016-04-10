import UIKit
import CoreGraphics

class ScheduleTableViewCell: UITableViewCell {
    @IBOutlet var sessionTitle: UILabel!
    @IBOutlet var speakerLabel: UILabel!
    @IBOutlet var roomLabel: UILabel!
    @IBOutlet var circleView: CircleView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

