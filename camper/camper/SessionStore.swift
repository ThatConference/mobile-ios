import CoreData

class SessionStore {
    let coreDataStack = CoreDataStack(modelName: "ThatConference")
    
    func fetchAll(completion completion: (SessionsResult) -> Void) {
        let url = ThatConferenceAPI.sessionsGetAllURL()
        let request = NSURLRequest(URL: url)
        let task = ThatConferenceAPI.nsurlSession.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            let result = self.processSessionsRequest(data: data, error: error)
            
            // temporarily disable caching
//            if case let .Success(sessions) = result {                
//                let mainQueueContext = self.coreDataStack.mainQueueContext
//                mainQueueContext.performBlockAndWait() {
//                    try! mainQueueContext.obtainPermanentIDsForObjects(sessions)
//                }
//                
//                let objectIds = sessions.map { $0.objectID }
//                let predicate = NSPredicate(format: "self IN %@", objectIds)
//                let sortBySessionDate = NSSortDescriptor(key: "scheduledDateTime", ascending: true)                
//                
//                do {
//                    try self.coreDataStack.saveChanges()
//                    
//                    let mainQueueSessions = try self.fetchMainQueueSessions(predicate: predicate, sortDescriptors: [sortBySessionDate])
//                    result = .Success(mainQueueSessions)
//                }
//                catch let error {
//                    result = .Failure(error)
//                }
//            }
            
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
   
    func getDailySchedules(sessions: [Session]) -> Dictionary<String, DailySchedule> {
        var schedule = Dictionary<String, DailySchedule>()
        var cancelled: Int = 0
        
        for session in sessions {
            if session.cancelled {
                cancelled += 1
                continue
            }
            
            var dateString = String()
            //var time = String()
            if let date = session.scheduledDateTime {
                dateString = getDate(date)
                //time = getTime(date)
            }

            //create a new reference for this dailySchedule in our temp lookup
            if schedule[dateString] == nil {
                let dailySchedule = DailySchedule()
                if let date = session.scheduledDateTime {
                    dailySchedule.date = date
                }
                
                schedule[dateString] = dailySchedule                
            }
            
            if let currentDay = schedule[dateString] {
                var found: Bool = false
                for timeSlot in currentDay.timeSlots {
                    if timeSlot.time == session.scheduledDateTime {
                        timeSlot.sessions.append(session)
                        found = true
                        break
                    }
                }
                
                if !found {
                    let timeSlot = TimeSlot()
                    timeSlot.time = session.scheduledDateTime
                    timeSlot.sessions = [session]
                    currentDay.timeSlots.append(timeSlot)
                }
            }
        }
        
        return schedule
    }
    
    private func getDate(dateTime: NSDate?) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-YYYY"
        
        return dateFormatter.stringFromDate(dateTime!)
    }
    
    class func getFormattedTime(dateTime: NSDate?) -> String {
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        
        return timeFormatter.stringFromDate(dateTime!)
    }

}