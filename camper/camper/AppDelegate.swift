import UIKit
import Fabric
import Crashlytics
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var dirtyDataSchedule: Bool = false
    var dirtyDataFavorites: Bool = false
    
    override init() {
        FirebaseApp.configure()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self])
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Menu", bundle: nil)
        
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "RevealVC")
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        
        //Back Image
        let backArrowImage = UIImage(named: "back")
        let renderedImage = backArrowImage?.withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = renderedImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = renderedImage
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

        print("url \(url)")
        
        if url.host == nil {
            return true
        }
        
        print("url host :\(url.host!)")
        
        print("url path :\(url.path)")
//
//        let urlPath : String = url.path as String!
//    
//        if(urlPath == "*/mobileloginredirect") {
//            print("aloha")
//        }
//        
        if let sourceApplication = options[.sourceApplication] {
            if (String(describing: sourceApplication) == ".com.thatconference.mobile.ios") {
                print("Aloha")
                NotificationCenter.default.post(name: Notification.Name("CallbackNotification"), object: url)
                return true
            }
        }
        
        return false
    }
}
