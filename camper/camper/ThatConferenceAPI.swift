import Foundation
import CoreData

enum Method: String {
    case SessionsGetAll = "Session/GetAllAcceptedSessions"
}

class ThatConferenceAPI {
    private static let baseURLString = "https://www.thatconference.com/api3/"
    
    private static let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
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
    
    static func sessionsGetAllURL() -> NSURL {
        return thatConferenceURL(.SessionsGetAll, parameters: ["year": GetCurrentYear()])
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
            acceptedValue = json["Accepted"] as? NSNumber,
            cancelledValue = json["Canceled"] as? NSNumber
            else {
                return nil
        }
        
        let accepted = ThatConferenceAPI.convertToBool(acceptedValue)
        let cancelled = ThatConferenceAPI.convertToBool(cancelledValue)
        
        var scheduledDateTime: NSDate?
        if dateString != nil {
            scheduledDateTime = dateFormatter.dateFromString(dateString!)
        }
        
        //let isUserFavoriteValue = json["IsUserFavorite"] as? NSNumber
        
        let fetchRequest = NSFetchRequest(entityName: "Session")
        let predicate = NSPredicate(format: "id == \(id)")
        fetchRequest.predicate = predicate
        
        var fetchedSessions: [Session]!
        context.performBlockAndWait() {
            fetchedSessions = try! context.executeFetchRequest(fetchRequest) as! [Session]
        }
        if fetchedSessions.count > 0 {
            return fetchedSessions.first
        }
        
        var session: Session!
        context.performBlockAndWait() {
            session = NSEntityDescription.insertNewObjectForEntityForName("Session", inManagedObjectContext: context) as! Session
            
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
        }
        
        return session
    }
}