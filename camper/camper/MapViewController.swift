import UIKit

class MapViewController : UIViewController {
    @IBOutlet var currentRoomView: UIView!
    @IBOutlet var currentRoomLabel: UILabel!
    @IBOutlet var currentRoomWidth: NSLayoutConstraint!
    @IBOutlet var currentRoomHeight: NSLayoutConstraint!
    @IBOutlet var currentRoomY: NSLayoutConstraint!
    @IBOutlet var currentRoomX: NSLayoutConstraint!
    
    var roomName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let setRoomName = roomName {
            setRoomPosition(setRoomName)
        } else {
            currentRoomView.hidden = true
        }
    }
    
    private func setRoomPosition(roomName: String) {
        currentRoomLabel.text = roomName
        
        //TODO: Set X/Y, W/H based on room and map scaling
    }
}