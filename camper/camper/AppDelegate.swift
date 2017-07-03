import UIKit
import Fabric
import Crashlytics
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var dirtyDataSchedule: Bool = false
    var dirtyDataFavorites: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
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
}
