import UIKit
import CoreGraphics

class ScheduleTableViewCell: UITableViewCell {
    @IBOutlet var sessionTitle: UILabel!
    @IBOutlet var speakerLabel: UILabel!
    @IBOutlet var roomLabel: UILabel!
    @IBOutlet var circleView: CircleView!
    @IBOutlet var favoriteIcon: UIImageView!
    @IBOutlet weak var circleViewHeightConstraint: NSLayoutConstraint!
    
    var session: Session!
    
    override func awakeFromNib() {        
        favoriteIcon!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScheduleTableViewCell.favorited(_:))))
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc private func favorited (sender:UITapGestureRecognizer) {
        ThatConferenceAPI().saveFavorite(session.id)
    }
}

