import UIKit

class TimeSlotRootTableViewCell: UITableViewCell {
    var session: Session!
    var delegate: ScheduleCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(ScheduleTableViewCell.swipeCellFunc(sender:)))
        swipeGesture.direction = .left
        addGestureRecognizer(swipeGesture)
    }
    
    func swipeCellFunc(sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            delegate?.ScheduleCellDelegate(session)
        }
    }
}

protocol ScheduleCellDelegate {
    func ScheduleCellDelegate(_ session: Session)
}
