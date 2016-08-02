import UIKit
import Fabric
import Crashlytics

class MapViewController : BaseViewController {
    @IBOutlet var mapImage: UIImageView!
    var roomName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let setRoomName = roomName {
            setRoom(setRoomName.lowercaseString)
        }
        
        Answers.logContentViewWithName("Map",
                                       contentType: "Page",
                                       contentId: roomName,
                                       customAttributes: [:])
    }
    
    private func setRoom(roomName: String) {
        switch roomName {
        case "acadia" :
            mapImage.image = UIImage(named: "map-acadia")
        case "aloeswood" :
            mapImage.image = UIImage(named: "map-aloeswood")
        case "aralia" :
            mapImage.image = UIImage(named: "map-aralia")
        case "b" :
            mapImage.image = UIImage(named: "map-b")
        case "bamboo" :
            mapImage.image = UIImage(named: "map-bamboo")
        case "banyan" :
            mapImage.image = UIImage(named: "map-banyan")
        case "c" :
            mapImage.image = UIImage(named: "map-c")
        case "crownpalm" :
            mapImage.image = UIImage(named: "map-crownpalm")
        case "cypress" :
            mapImage.image = UIImage(named: "map-cypress")
        case "d" :
            mapImage.image = UIImage(named: "map-d")
        case "e" :
            mapImage.image = UIImage(named: "map-e")
        case "f" :
            mapImage.image = UIImage(named: "map-f")
        case "g" :
            mapImage.image = UIImage(named: "map-g")
        case "guava" :
            mapImage.image = UIImage(named: "map-guava")
        case "ironwood" :
            mapImage.image = UIImage(named: "map-ironwood")
        case "key note" :
            mapImage.image = UIImage(named: "map-keynote")
        case "mangrove" :
            mapImage.image = UIImage(named: "map-mangrove")
        case "marula" :
            mapImage.image = UIImage(named: "map-marula")
        case "mess hall" :
            mapImage.image = UIImage(named: "map-messhall")
        case "open spaces" :
            mapImage.image = UIImage(named: "map-openspaces")
        case "portia" :
            mapImage.image = UIImage(named: "map-portia")
        case "tamarind" :
            mapImage.image = UIImage(named: "map-tamarind")
        case "tamboti" :
            mapImage.image = UIImage(named: "map-tamboti")
        case "wisteria" :
            mapImage.image = UIImage(named: "map-wisteria")
        default:
            print("Room Name:\(roomName) not found.")
        }
    }
}