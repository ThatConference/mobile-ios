import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        let rootViewController = window!.rootViewController as! UITabBarController
        let navController = rootViewController.childViewControllers.first as! UINavigationController
        let scheduleViewController = navController.topViewController as! ScheduleViewController
        scheduleViewController.store = SessionStore()
        
//        let backImage = UIImage(named: "back");
//        UIBarButtonItem.appearance().setBackButtonBackgroundImage(backImage, forState: .Normal, barMetrics: .Default);
        
        // FIND AVAILABLE FONTS
//        for family: String in UIFont.familyNames()
//        {
//            print("\(family)")
//            for names: String in UIFont.fontNamesForFamilyName(family)
//            {
//                print("== \(names)")
//            }
//        }
        
        return true
    }
}