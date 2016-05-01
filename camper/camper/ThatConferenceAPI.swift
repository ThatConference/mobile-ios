import Foundation
import CoreData

enum Method: String {
    case SessionsGetAll = "/api3/Session/GetAllAcceptedSessions"
    case ExternalLogins = "/api3/Account/ExternalLogins"
    case Token = "/Token"
    case Favorite = "/api3/Favorites/"
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

protocol RequestCompleteProtocol {
    func DataReceived(data : NSData?, response : NSURLResponse?, error : NSError?)
}

class ThatConferenceAPI {
    var requestCompleteProtocol: RequestCompleteProtocol?
    
    static let nsurlSession: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: config)
    }()
    
    static let baseURLString = "https://www.thatconference.com"
    static let baseResourceURLString = "https://thatconference.blob.core.windows.net"
    
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
        
        if (queryItems.count > 0) {
            components.queryItems = queryItems
        }
        
        return components.URL!
    }
    
    class func authorizationExternalLogins() -> NSURL {
        return thatConferenceURL(.ExternalLogins, parameters: nil)
    }
    
    class func externalLoginsURL() -> NSURL {
        return thatConferenceURL(.ExternalLogins, parameters: ["returnUrl":"/", "generateState": "true"])
    }
    
    static func resourceURL(partialURL: String) -> NSURL {
        let badPrefix = "cloud/"
        let index1 = partialURL.startIndex.advancedBy(badPrefix.characters.count)
        let substringURL = partialURL.substringFromIndex(index1)
        
        let fullURL = baseResourceURLString + substringURL;
        let components = NSURLComponents(string: fullURL)!
        return components.URL!
    }
    
    static func sessionsGetAllURL() -> NSURL {
        return thatConferenceURL(.SessionsGetAll, parameters: ["year": GetCurrentYear()])
    }
    
    class func convertToBool(value: NSNumber?) -> Bool {
        return value == 1
    }
    
    class func convertToBool(value: String?) -> Bool {
        return value == "1"
    }
    
    private class func GetCurrentYear() -> String {
//        let date = NSDate()
//        let calendar = NSCalendar.currentCalendar()
//        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
//        
//        return String(components.year)
        return "2016"
    }
    
    
    func localLogin(username: String, password: String) {
        let headers = [
            "accept": "application/json",
            "content-type": "application/x-www-form-urlencoded"
        ]
        
        let postData = NSMutableData(data: "grant_type=password".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&username=\(username)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&password=\(password)".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        let request = NSMutableURLRequest(URL: NSURL(string: ThatConferenceAPI.baseURLString + Method.Token.rawValue)!,
                                          cachePolicy: .UseProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.HTTPMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.HTTPBody = postData
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            self.requestCompleteProtocol?.DataReceived(data, response: response, error: error)
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
            cancelled = (json["Canceled"] as? NSNumber)?.boolValue,
            isFamilyApproved = (json["IsFamilyApproved"] as? NSNumber)?.boolValue
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
        session.isFamilyApproved = isFamilyApproved
        
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
    
    // MARK: Favorites
    
    func saveFavorite(sessionId: NSNumber?) {
        // save the favorite
        let url = ThatConferenceAPI.thatConferenceURL(.Favorite, parameters: nil).URLByAppendingPathComponent("Add").URLByAppendingPathComponent("\(sessionId!)")
        let request = NSMutableURLRequest(URL: url,
                                          cachePolicy: .UseProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.HTTPMethod = "GET"
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            self.requestCompleteProtocol?.DataReceived(data, response: response, error: error)
        })
        
        dataTask.resume()
        
        // TODO: need to update our sessionStore data...
    }
    
    func deleteFavorite(sessionId: String) {
        
    }
}
