import Foundation
import CoreData

enum Method: String {
    case SessionsGetAll = "Session/GetAllAcceptedSessions"
}

struct ThatConferenceAPI {
    private static let baseURLString = "https://www.thatconference.com/api3/"
    
    private static func thatConferenceURL(method: Method, parameters: [String:String]?) -> NSURL {
        let fullURL = "\(baseURLString)\(method)";
        let components = NSURLComponents(string: fullURL)!
        var queryItems = [NSURLQueryItem]()
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = NSURLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        
        components.queryItems = queryItems
        return components.URL!
    }
    
    static func sessionsGetAllURL() -> NSURL {
        return thatConferenceURL(.SessionsGetAll, parameters: ["year": GetCurrentYear()])
    }
    
    private static func GetCurrentYear() -> String {
//        let date = NSDate()
//        let calendar = NSCalendar.currentCalendar()
//        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
//        
//        return String(components.year)
        return "2015"
    }
}