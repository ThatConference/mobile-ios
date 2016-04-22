import Foundation
import CoreData

enum Method: String {
    case SessionsGetAll = "/api3/Session/GetAllAcceptedSessions"
    case ExternalLogins = "/api3/Account/ExternalLogins"
    case Token = "/Token"
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
    
    static let baseURLString = "https://www.thatconference.com"
    
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
    
    static func externalLoginsURL() -> NSURL {
        return thatConferenceURL(.ExternalLogins, parameters: ["returnUrl":"/", "generateState": "true"])
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
    
    
    static func localLogin(username: String, password: String) {
        let headers = [
            "accept": "application/json",
            "content-type": "application/x-www-form-urlencoded"
        ]
        
        let postData = NSMutableData(data: "grant_type=password".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&username=\(username)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&password=\(password)".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        let request = NSMutableURLRequest(URL: NSURL(string: baseURLString + Method.Token.rawValue)!,
                                          cachePolicy: .UseProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.HTTPMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.HTTPBody = postData
        
        print("REQUEST:\(request)")
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? NSHTTPURLResponse
                print(httpResponse)
            }
        })
        
        dataTask.resume()
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
        
        var scheduledDateTime: NSDate?
        if dateString != nil {
            scheduledDateTime = dateFormatter.dateFromString(dateString!)            
        }

        
        let session = Session()
        session.id = id
        session.title = title
        session.sessionDescription = sessionDescription
        session.scheduledDateTime = scheduledDateTime
        session.scheduledRoom = scheduledRoom
        session.primaryCategory = primaryCategory
        session.level = level
        session.accepted = accepted
        session.cancelled = cancelled
        
        if let speakers = json["Speakers"] as? [[String: AnyObject]] {
            for jsonSpeaker in speakers {
                let speaker = Speaker()
                speaker.firstName = jsonSpeaker["FirstName"] as? String
                speaker.lastName = jsonSpeaker["LastName"] as? String
                
                if let headshotString = jsonSpeaker["HeadShot"] as? String {
                    speaker.headShotURL = NSURL(string: headshotString)
                }
                
                speaker.biography = jsonSpeaker["Biography"] as? String
                
                if let websiteString = jsonSpeaker["WebSite"] as? String {
                    speaker.website = NSURL(string: websiteString)
                }
                
                speaker.company = jsonSpeaker["Company"] as? String
                speaker.title = jsonSpeaker["Title"] as? String
                speaker.twitter = jsonSpeaker["Twitter"] as? String
                speaker.facebook = jsonSpeaker["Facebook"] as? String
                speaker.googlePlus = jsonSpeaker["GooglePlus"] as? String
                speaker.linkedIn = jsonSpeaker["LinkedIn"] as? String
                speaker.gitHub = jsonSpeaker["GitHub"] as? String
                
                if let lastUpdatedString = jsonSpeaker["LastUpdated"] as? String {
                    speaker.lastUpdated = dateFormatter.dateFromString(lastUpdatedString)
                }
                
                session.speakers.append(speaker)
            }
        }
        
        return session
    }
    
    class func externalLoginsFromJSONData(data: NSData) -> ExternalLoginResult {
        do {
            let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            
            guard let logins = jsonObject as? [[String:AnyObject]]
                else {
                    return .Failure(APIError.InvalidJSONData)
            }
            
            var returnLogins = [ExternalLogin]()
            
            for loginJSON in logins {
                if let login = externalLoginFromJSONData(loginJSON) {
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
    
    private class func externalLoginFromJSONData(json: [String: AnyObject]) -> ExternalLogin? {
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