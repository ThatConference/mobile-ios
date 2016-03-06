import UIKit
import CoreFoundation

enum SessionResult {
    case Success(Session)
    case Failure(ErrorType)
}

class SessionStore {
    let coreDataStack = CoreDataStack(modelName: "Sessions")
    let session: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: config)
    }()
    
    func fetchSessions() {
        let url = ThatConferenceAPI.sessionsGetAllURL()
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            if let jsonData = data {
                if let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) {
                    print(jsonString)
                }
            } else if let requestError = error {
                print("Error fetching sessions: \(requestError)")
            } else {
                print("Unexprected error with the request")
            }
            
            //completion(result)
        }
        task.resume()
    }
}