import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        let rootViewController = window!.rootViewController as! UITabBarController
        let navController = rootViewController.childViewControllers.first as! UINavigationController
        let scheduleViewController = navController.topViewController as! ScheduleViewController
        scheduleViewController.store = SessionStore()
        
        return true
    }
}