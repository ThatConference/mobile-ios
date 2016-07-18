import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var dirtyDataSchedule: Bool = false
    var dirtyDataFavorites: Bool = false

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        let rootViewController = window!.rootViewController as! UITabBarController
        let navController = rootViewController.childViewControllers.first as! UINavigationController
        let favoritesViewController = navController.topViewController as! FavoritesViewController
        favoritesViewController.store = SessionStore()
        
        //Back Image
        let backArrowImage = UIImage(named: "back")
        let renderedImage = backArrowImage?.imageWithRenderingMode(.AlwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = renderedImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = renderedImage
        
        return true
    }
}