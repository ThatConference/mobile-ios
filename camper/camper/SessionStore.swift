import UIKit
import CoreData

enum SessionsResult {
    case Success([Session])
    case Failure(ErrorType)
}

enum APIError: ErrorType {
    case InvalidJSONData
}

class SessionStore {
    let coreDataStack = CoreDataStack(modelName: "ThatConference")
    let session: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: config)
    }()
    
    func fetchAll(completion completion: (SessionsResult) -> Void) {
        let url = ThatConferenceAPI.sessionsGetAllURL()
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            var result = self.processSessionsRequest(data: data, error: error)
            
            if case let .Success(sessions) = result {
                let mainQueueContext = self.coreDataStack.mainQueueContext
                mainQueueContext.performBlockAndWait() {
                    try! mainQueueContext.obtainPermanentIDsForObjects(sessions)
                }
                
                let objectIds = sessions.map { $0.objectID }
                let predicate = NSPredicate(format: "self IN %@", objectIds)
                //let sortBySessionDate = NSSortDescriptor(key: "ScheduledDateTime", ascending: true)
                let sortBySessionDate = NSSortDescriptor(key: "id", ascending: true)
                
                do {
                    try self.coreDataStack.saveChanges()
                    
                    let mainQueueSessions = try self.fetchMainQueueSessions(predicate: predicate, sortDescriptors: [sortBySessionDate])
                    result = .Success(mainQueueSessions)
                }
                catch let error {
                    result = .Failure(error)
                }
            }
            
            completion(result)
        }
        task.resume()
    }
        
    func fetchMainQueueSessions(predicate predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Session] {
        let fetchRequest = NSFetchRequest(entityName: "Session")
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueueSessions: [Session]?
        var fetchRequestError: ErrorType?
        
        mainQueueContext.performBlockAndWait() {
            do {
                mainQueueSessions = try mainQueueContext.executeFetchRequest(fetchRequest) as? [Session]
            }
            catch let error {
                fetchRequestError = error
            }
        }
        
        guard let sessions = mainQueueSessions else {
            throw fetchRequestError!
        }
        
        return sessions
    }
    
    func processSessionsRequest(data data: NSData?, error: NSError?) -> SessionsResult {
        guard let jsonData = data
            else {
                return .Failure(error!)
        }
        
        return ThatConferenceAPI.sessionsFromJSONData(jsonData, inContext: self.coreDataStack.privateQueueContext)
    }
}