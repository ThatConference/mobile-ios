import Foundation
import CoreData

enum Method: String {
    case SessionsGetAll = "/api3/Session/GetAllAcceptedSessions"
    case ExternalLogins = "/api3/Account/ExternalLogins?returnUrl=%2F&generateState=true"
}

enum SessionsResult {
    case Success([Session])
    case Failure(ErrorType)
}

enum ExternalLoginResult {
    case Success([ExternalLogin])
    case Failure(ErrorType)
}

enum APIError: ErrorType {
    case InvalidJSONData
}

class ThatConferenceAPI {
    static let nsurlSession: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: config)
    }()
    
    private static let baseURLString = "https://www.thatconference.com"
    
    private static let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
    
    private static func thatConferenceURL(method: Method, parameters: [String:String]?) -> NSURL {
        let fullURL = baseURLString + method.rawValue;
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
    
    static func authorizationExternalLogins() -> NSURL {
        return thatConferenceURL(.ExternalLogins, parameters: nil)
    }
    
    static func sessionsGetAllURL() -> NSURL {
        return thatConferenceURL(.SessionsGetAll, parameters: ["year": GetCurrentYear()])
    }
    
    static func externalLogins() -> NSURL {
        return thatConferenceURL(.ExternalLogins, parameters: nil)
    }
    
    static func convertToBool(value: NSNumber?) -> Bool {
        return value == 1
    }
    
    static func convertToBool(value: String?) -> Bool {
        return value == "1"
    }
    
    private static func GetCurrentYear() -> String {
//        let date = NSDate()
//        let calendar = NSCalendar.currentCalendar()
//        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
//        
//        return String(components.year)
        return "2015"
    }
    
    class func sessionsFromJSONData(data: NSData, inContext context: NSManagedObjectContext) -> SessionsResult {
        do {
            let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            
            guard let sessions = jsonObject as? [[String:AnyObject]]
                else {
                    return .Failure(APIError.InvalidJSONData)
            }
            
            var finalSessions = [Session]()
            
            for sessionJSON in sessions {
                if let session = sessionFromJSONData(sessionJSON, inContext: context) {
                    finalSessions.append(session)
                }
            }
            
            if finalSessions.count == 0 && sessions.count > 0 {
                return .Failure(APIError.InvalidJSONData)
            }
            
            return .Success(finalSessions)
        }
        catch let error {
            return .Failure(error)
        }
    }
    
    private class func sessionFromJSONData(json: [String: AnyObject], inContext context: NSManagedObjectContext) -> Session? {
        guard let
            id = json["Id"] as? Int,
            title = json["Title"] as? String,
            sessionDescription = json["Description"] as? String,
            dateString = json["ScheduledDateTime"] as? String?,
            scheduledRoom = json["ScheduledRoom"] as? String,
            primaryCategory = json["PrimaryCategory"] as? String,
            level = json["Level"] as? String,
            accepted = (json["Accepted"] as? NSNumber)?.boolValue,
            cancelled = (json["Canceled"] as? NSNumber)?.boolValue
            else {
                return nil
        }
        
        //let accepted = ThatConferenceAPI.convertToBool(acceptedValue)
        //let cancelled = ThatConferenceAPI.convertToBool(cancelledValue)
        
        var scheduledDateTime: NSDate?
        if dateString != nil {
            scheduledDateTime = dateFormatter.dateFromString(dateString!)            
        }
        
        //let isUserFavoriteValue = json["IsUserFavorite"] as? NSNumber
        
        /****************
        **  Appears to be pulling from cache and ignoring fetch request **
        ***************/
//        let fetchRequest = NSFetchRequest(entityName: "Session")
//        let predicate = NSPredicate(format: "id == \(id)")
//        fetchRequest.predicate = predicate
//        
//        var fetchedSessions: [Session]!
//        context.performBlockAndWait() {
//            fetchedSessions = try! context.executeFetchRequest(fetchRequest) as! [Session]
//        }
//        if fetchedSessions.count > 0 {
//            print("fetched session date time: \(fetchedSessions.first?.scheduledDateTime)")
//            return fetchedSessions.first
//        }
        
        //is this ever hit?!?!
        let session = Session()
        //context.performBlockAndWait() {
           // session = NSEntityDescription.insertNewObjectForEntityForName("Session", inManagedObjectContext: context) as! Session
            
            session.id = id
            session.title = title
            session.sessionDescription = sessionDescription
            session.scheduledDateTime = scheduledDateTime
            session.scheduledRoom = scheduledRoom
            session.primaryCategory = primaryCategory
            session.level = level
            session.accepted = accepted
            session.cancelled = cancelled
            //session.isUserFavorite = ThatConferenceAPI.convertToBool(isUserFavoriteValue)
        //}
        
        return session
    }
    
    class func externalLoginsFromJSONData(data: NSData, inContext context: NSManagedObjectContext) -> ExternalLoginResult {
        do {
            let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            
            guard let logins = jsonObject as? [[String:AnyObject]]
                else {
                    return .Failure(APIError.InvalidJSONData)
            }
            
            var returnLogins = [ExternalLogin]()
            
            for loginJSON in logins {
                if let login = externalLoginFromJSONData(loginJSON, inContext: context) {
                    returnLogins.append(login)
                }
            }
            
            if returnLogins.count == 0 && logins.count > 0 {
                return .Failure(APIError.InvalidJSONData)
            }
            
            return .Success(returnLogins)
        }
        catch let error {
            return .Failure(error)
        }
    }
    
    private class func externalLoginFromJSONData(json: [String: AnyObject], inContext context: NSManagedObjectContext) -> ExternalLogin? {
        guard let
            name = json["Name"] as? String,
            state = json["State"] as? String,
            url = json["Url"] as? String
        else {
            return nil
        }
        
        let login = ExternalLogin()
        login.name = name
        login.state = state
        login.url = url
        
        return login
    }
}