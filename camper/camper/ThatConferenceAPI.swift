import Foundation

enum Method: String {
    case ExternalLogins = "/api3/Account/ExternalLogins"
    case Favorite = "/api3/Favorites/"
    case SessionGetAccepted = "/api3/Session/GetAcceptedSessions"
    case SessionsGetAll = "/api3/Session/GetAllAcceptedSessions"
    case Sponsors = "/api3/Sponsors/GetSponsors"
    case Token = "/Token"
    case UserFavorites = "/api3/Session/GetFavoriteSessions"
}

enum ExternalLoginResult {
    case success([ExternalLogin])
    case failure(Error)
}

enum SessionsResult {
    case success([Session])
    case failure(Error)
}

enum SponsorsResult {
    case success([Sponsor])
    case failure(Error)
}

enum APIError: Error {
    case invalidJSONData
    case notLoggedIn
}

protocol RequestCompleteProtocol {
    func DataReceived(data : Data?, response : URLResponse?, error : Error?)
}

class ThatConferenceAPI {
    var requestCompleteProtocol: RequestCompleteProtocol?
    
    static let nsurlSession: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    static let baseURLString = "https://www.thatconference.com"
    static let baseResourceURLString = "https://thatconference.blob.core.windows.net"
    
    fileprivate static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
    
    fileprivate static func thatConferenceURL(_ method: Method, parameters: [String:String]?) -> URL {
        let fullURL = baseURLString + method.rawValue;
        var components = URLComponents(string: fullURL)!
        var queryItems = [URLQueryItem]()
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        
        if (queryItems.count > 0) {
            components.queryItems = queryItems
        }
        
        return components.url!
    }
    
    class func authorizationExternalLogins() -> URL {
        return thatConferenceURL(.ExternalLogins, parameters: nil)
    }
    
    class func externalLoginsURL() -> URL {
        return thatConferenceURL(.ExternalLogins, parameters: ["returnUrl":"/", "generateState": "true"])
    }
    
    class func sponsorsURL() -> URL {
        return thatConferenceURL(.Sponsors, parameters: nil)
    }
    
    static func resourceURL(_ partialURL: String) -> URL {
        let badPrefix = "cloud/"
        let index1 = partialURL.characters.index(partialURL.startIndex, offsetBy: badPrefix.characters.count)
        let substringURL = partialURL.substring(from: index1)
        
        let fullURL = baseResourceURLString + substringURL;
        let components = URLComponents(string: fullURL)!
        return components.url!
    }
    
    static func sessionsGetAcceptedURL(_ sinceDate: Date?) -> URL {
        var params: Dictionary<String, String>? = Dictionary<String, String>()
        if let date = sinceDate {
            let dateString = dateFormatter.string(from: date)
            params = ["sinceUpdatedDate": dateString]
        }
        return thatConferenceURL(.SessionGetAccepted, parameters: params!)
    }
    
    class func convertToBool(_ value: NSNumber?) -> Bool {
        return value == 1
    }
    
    class func convertToBool(_ value: String?) -> Bool {
        return value == "1"
    }
    
    class func GetCurrentYear() -> String {
        return "2016"
    }
    
    // MARK: Sessions
    class func sessionsFromJSONData(_ data: Data) -> SessionsResult {
        do {
            let jsonObject: Any = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let sessions = jsonObject as? [[String:AnyObject]]
                else {
                    return .failure(APIError.invalidJSONData)
            }
            
            var finalSessions = [Session]()
            
            for sessionJSON in sessions {
                if let session = sessionFromJSONData(sessionJSON) {
                    finalSessions.append(session)
                }
            }
            
            if finalSessions.count == 0 && sessions.count > 0 {
                return .failure(APIError.invalidJSONData)
            }
            
            return .success(finalSessions)
        }
        catch let error {
            return .failure(error)
        }
    }
    
    fileprivate class func sessionFromJSONData(_ json: [String: AnyObject]) -> Session? {
        let id = json["Id"] as? Int
        let title = json["Title"] as? String
        let sessionDescription = json["Description"] as? String
        let scheduledRoom = json["ScheduledRoom"] as? String
        let primaryCategory = json["PrimaryCategoryDisplayText"] as? String
        let level = json["Level"] as? String
        let accepted = (json["Accepted"] as? NSNumber)?.boolValue
        let cancelled = (json["Canceled"] as? NSNumber)?.boolValue
        let isFamilyApproved = (json["IsFamilyApproved"] as? NSNumber)?.boolValue
        
        var isUserFavorite: Bool = false
        if let userFavorite = (json["IsUserFavorite"] as? NSNumber) {
            isUserFavorite = userFavorite.boolValue
        }
       
        var scheduledDateTime: Date?
        if let dateString = json["ScheduledDateTime"] as? String {
            scheduledDateTime = dateFormatter.date(from: dateString)
        } else {
            return nil
        }

        let session = Session()
        session.id = id as NSNumber?
        session.title = title
        session.sessionDescription = sessionDescription
        session.scheduledDateTime = scheduledDateTime
        session.scheduledRoom = scheduledRoom
        session.primaryCategory = primaryCategory
        session.level = level
        session.accepted = accepted!
        session.cancelled = cancelled!
        session.isFamilyApproved = isFamilyApproved!
        session.isUserFavorite = isUserFavorite
        
        if let speakers = json["Speakers"] as? [[String: AnyObject]] {
            for jsonSpeaker in speakers {
                let speaker = Speaker()
                speaker.firstName = jsonSpeaker["FirstName"] as? String
                speaker.lastName = jsonSpeaker["LastName"] as? String
                
                if let headshotString = jsonSpeaker["HeadShot"] as? String {
                    speaker.headShotURL = URL(string: headshotString)
                }
                
                speaker.biography = jsonSpeaker["Biography"] as? String
                
                if let websiteString = jsonSpeaker["WebSite"] as? String {
                    speaker.website = URL(string: websiteString)
                }
                
                speaker.company = jsonSpeaker["Company"] as? String
                speaker.title = jsonSpeaker["Title"] as? String
                speaker.twitter = jsonSpeaker["Twitter"] as? String
                speaker.facebook = jsonSpeaker["Facebook"] as? String
                speaker.googlePlus = jsonSpeaker["GooglePlus"] as? String
                speaker.linkedIn = jsonSpeaker["LinkedIn"] as? String
                speaker.gitHub = jsonSpeaker["GitHub"] as? String
                
                if let lastUpdatedString = jsonSpeaker["LastUpdated"] as? String {
                    speaker.lastUpdated = dateFormatter.date(from: lastUpdatedString)
                }
                
                session.speakers.append(speaker)
            }
        }
        
        return session
    }
    
    // MARK: Internal Logins
    func localLogin(_ username: String, password: String) {
        let headers = [
            "accept": "application/json",
            "content-type": "application/x-www-form-urlencoded"
        ]
        
        var postData = NSData(data: "grant_type=password".data(using: String.Encoding.utf8)!) as Data
        postData.append("&username=\(username)".data(using: String.Encoding.utf8)!)
        postData.append("&password=\(password)".data(using: String.Encoding.utf8)!)
        
        var request = URLRequest(url: URL(string: ThatConferenceAPI.baseURLString + Method.Token.rawValue)!,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            self.requestCompleteProtocol?.DataReceived(data: data, response: response, error: error)
        })
        
        dataTask.resume()
    }
    
    // MARK: External Logins
    class func externalLoginsFromJSONData(_ data: Data) -> ExternalLoginResult {
        do {
            let jsonObject: Any = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let logins = jsonObject as? [[String:AnyObject]]
                else {
                    return .failure(APIError.invalidJSONData)
            }
            
            var returnLogins = [ExternalLogin]()
            
            for loginJSON in logins {
                if let login = externalLoginFromJSONData(loginJSON) {
                    returnLogins.append(login)
                }
            }
            
            if returnLogins.count == 0 && logins.count > 0 {
                return .failure(APIError.invalidJSONData)
            }
            
            return .success(returnLogins)
        }
        catch let error {
            return .failure(error)
        }
    }
    
    fileprivate class func externalLoginFromJSONData(_ json: [String: AnyObject]) -> ExternalLogin? {
        guard let
            name = json["Name"] as? String,
            let state = json["State"] as? String,
            let url = json["Url"] as? String
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
    class func saveFavorite(_ sessionId: NSNumber?, completionHandler: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        // save the favorite
        let url = thatConferenceURL(.Favorite, parameters: nil).appendingPathComponent("Add").appendingPathComponent("\(sessionId!)")
        var request = URLRequest(url: url,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        if let token = Authentication.loadAuthToken() {
                request.addValue("Bearer \(token.token!)", forHTTPHeaderField: "Authorization")
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            completionHandler(data, response, error)
        })
        
        dataTask.resume()
    }
    
    class func deleteFavorite(_ sessionId: NSNumber?, completionHandler: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        // remove the favorite
        let url = thatConferenceURL(.Favorite, parameters: nil).appendingPathComponent("Remove").appendingPathComponent("\(sessionId!)")
        var request = URLRequest(url: url,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        if let token = Authentication.loadAuthToken() {
            request.addValue("Bearer \(token.token!)", forHTTPHeaderField: "Authorization")
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            completionHandler(data, response, error)
        })

        dataTask.resume()
    }
    
    class func getFavoriteSessions(_ year: String, completionHandler:@escaping (SessionsResult) -> Void) {
        let url = thatConferenceURL(.UserFavorites, parameters: ["year": year])
        var request = URLRequest(url: url,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        if let token = Authentication.loadAuthToken() {
            request.addValue("Bearer \(token.token!)", forHTTPHeaderField: "Authorization")
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if error != nil {
                completionHandler(SessionsResult.failure(error!))
            } else {
                print("Response: \(String(describing: response))")
                print("Favorites Return Data \(String(describing: data))")
                let sessions = sessionsFromJSONData(data!)
                completionHandler(sessions)
            }
        })
        
        dataTask.resume()
    }
    
    // MARK : Sponsors
    class func sponsorsFromJSONData(_ data: Data) -> SponsorsResult {
        do {
            let jsonObject: Any = try JSONSerialization.jsonObject(with: data, options: [])

            guard let sponsors = jsonObject as? [[String:AnyObject]]
                else {
                    return .failure(APIError.invalidJSONData)
            }

            var returnSponsors = [Sponsor]()

            for sponsorJSON in sponsors {
                if let sponsor = sponsorFromJSONData(sponsorJSON) {
                    returnSponsors.append(sponsor)
                }
            }

            if returnSponsors.count == 0 && sponsors.count > 0 {
                return .failure(APIError.invalidJSONData)
            }
            
            return .success(returnSponsors)
        }
        catch let error {
            return .failure(error)
        }
    }
    
    fileprivate class func sponsorFromJSONData(_ json: [String: AnyObject]) -> Sponsor? {
        let name = json["Name"] as? String
        let sponsorLevel = json["SponsorLevel"] as? String
        let levelOrder = json["LevelOrder"] as? Int
        let imageUrl = json["ImageUrl"] as? String
        let website = json["Website"] as? String
        let twitter = json["Twitter"] as? String
        let facebook = json["Facebook"] as? String
        let googlePlus = json["GooglePlus"] as? String
        let linkedIn = json["LinkedIn"] as? String
        let gitHub = json["GitHub"] as? String
        let pinterest = json["Pinterest"] as? String
        let instragram = json["Instagram"] as? String
        let youTube = json["YouTube"] as? String
        
        let sponsor = Sponsor()
        sponsor.name = name
        sponsor.sponsorLevel = sponsorLevel
        sponsor.levelOrder = levelOrder
        sponsor.imageUrl = imageUrl
        sponsor.website = website
        sponsor.twitter = twitter
        sponsor.facebook = facebook
        sponsor.googlePlus = googlePlus
        sponsor.linkedIn = linkedIn
        sponsor.gitHub = gitHub
        sponsor.pinterest = pinterest
        sponsor.instagram = instragram
        sponsor.youTube = youTube
        
        return sponsor
    }
}
