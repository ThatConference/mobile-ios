import UIKit
import Fabric
import Crashlytics
import UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var dirtyDataSchedule: Bool = false
    var dirtyDataFavorites: Bool = false

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
        
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        FirebaseApp.configure()

        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        

        var didHandle: Bool = false
        
        if (userActivity.activityType == NSUserActivityTypeBrowsingWeb) {
            
            if let url = userActivity.webpageURL {
                print("MYURL: \(url)")
                
//                let baseURL = url.host!
//                
//                if baseURL.contains("thatconference") {
//                    let fullURL = url.absoluteString
//                    let result = fullURL.range(of: "access_token" )
//                    if result != nil {
//                        let authToken = AuthToken()
//                        authToken.token = url.getQueryItemValueForKey(key: "access_token")
//                        authToken.expiration = Date().addDays(7)
//                        
//                        let expireSeconds = url.getQueryItemValueForKey(key: "expires_in")
//                        if (expireSeconds != nil) {
//                            let numericValue = Double(expireSeconds!)!
//                            authToken.expiration = Date().addingTimeInterval(numericValue)
//                        }
//                        
//                        Authentication.saveAuthToken(authToken)
//                        Answers.logLogin(withMethod: "oAuth Login", success: true, customAttributes: [:])
//                        
//                        
////                        if self.window?.rootViewController?.presentedViewController != nil {
////                            self.window?.rootViewController?.dismiss(animated: false, completion: nil)
////                        }
//                        
//                        didHandle = true
//                    }
//                }

                let urlString = "\(url)"

                if let range = urlString.range(of: "access_token=") {
                    var tokenRange = urlString.substring(from: range.upperBound)
                    if let removeTokenType = tokenRange.range(of: "&token_type=") {
                        tokenRange.removeSubrange(removeTokenType.lowerBound..<tokenRange.endIndex)
                        let token = tokenRange.replacingOccurrences(of: "&token_type=", with: "")
                        
                        // Token ready to be saved
                        print(token)
                    }
                
                    didHandle = true
                }
            }
        }
        
        return didHandle
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
//        if let sourceApplication = options[.sourceApplication] {
//            if (String(describing: sourceApplication) == ".com.thatconference.mobile.ios") {
//                print("Aloha")
//                NotificationCenter.default.post(name: Notification.Name("CallbackNotification"), object: url)
//                return true
//            }
//        }
        
        return false
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
//        let dict = userInfo["aps"] as! Dictionary
//        let message = dict["alert"]
//        print("\(message)")
    }
}
