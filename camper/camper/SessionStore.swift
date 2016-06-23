import Foundation

class SessionStore {
    enum SessionDataRetrieval {
        case Success(Dictionary<String, DailySchedule>)
        case Failure(ErrorType)
    }
    
    func getDailySchedules(returnSchedule: Bool, completion: (SessionDataRetrieval) -> Void) {
        var sessions = [Session]()
        
        self.fetchAll() {
            (sessionResult) -> Void in
            switch sessionResult {
            case .Success(let returnedSessions):
                sessions = returnedSessions
                var schedule = Dictionary<String, DailySchedule>()
                var openspaces = Dictionary<String, DailySchedule>()
                var cancelled: Int = 0
                
                for session in sessions {
                    if session.cancelled {
                        cancelled += 1
                        continue
                    }
                    
                    var dateString = String()
                    if let date = session.scheduledDateTime {
                        dateString = self.getDate(date)
                    }

                    if session.primaryCategory != "Open Spaces" {
                        //Add Item to Schedule
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
                        
                    } else {
                        //Add Item to Open Spaces
                        if openspaces[dateString] == nil {
                            let dailySchedule = DailySchedule()
                            if let date = session.scheduledDateTime {
                                dailySchedule.date = date
                            }
                            
                            openspaces[dateString] = dailySchedule
                        }
                        
                        if let currentDay = openspaces[dateString] {
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
                }
                
                PersistenceManager.saveDailySchedule(schedule, path: Path.Schedule)
                PersistenceManager.saveDailySchedule(openspaces, path: Path.OpenSpaces)
            
                if (returnSchedule) {
                    return completion(.Success(schedule))
                } else {
                    return completion(.Success(openspaces))
                }
            case .Failure(let error):
                return completion(.Failure(error))
            }
        }
    }
    
    func  addFavorite(session: Session, completion: (SessionsResult) -> Void) {
        ThatConferenceAPI.saveFavorite(session.id, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                completion(SessionsResult.Failure(error!))
            }
            
            session.isUserFavorite = true
            
            completion(.Success([session]))
        })
    }
    
    func removeFavorite(session: Session, completion: (SessionsResult) -> Void) {
        ThatConferenceAPI.deleteFavorite(session.id, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                completion(SessionsResult.Failure(error!))
            }
            
            session.isUserFavorite = false
            completion(.Success([session]))
        })

    }
    
    func getFavoriteSessions(completion completion: (SessionDataRetrieval) -> Void) {
        var sessions = [Session]()
        
        ThatConferenceAPI.getFavoriteSessions(ThatConferenceAPI.GetCurrentYear(), completionHandler: {(sessionsResult) -> Void in
            switch sessionsResult {
            case .Success(let returnedSessions):
                sessions = returnedSessions
                var schedule = Dictionary<String, DailySchedule>()
                var cancelled: Int = 0
                
                for session in sessions {
                    if session.cancelled {
                        cancelled += 1
                        continue
                    }
                    
                    var dateString = String()
                    if let date = session.scheduledDateTime {
                        dateString = self.getDate(date)
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
                
                return completion(.Success(schedule))
            case .Failure(let error):
                return completion(.Failure(error))
            }
        })
    }
    
    private func fetchAll(completion completion: (SessionsResult) -> Void) {
        let url = ThatConferenceAPI.sessionsGetAcceptedURL(nil)
        var request = NSMutableURLRequest(URL: url)
        request = addAuthIfPossible(request)
        let task = ThatConferenceAPI.nsurlSession.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            let result = self.processSessionsRequest(data: data, error: error)
            
            completion(result)
        }
        task.resume()
    }
    
    private func processSessionsRequest(data data: NSData?, error: NSError?) -> SessionsResult {
        guard let jsonData = data
            else {
                return .Failure(error!)
        }
        
        return ThatConferenceAPI.sessionsFromJSONData(jsonData)
    }
    
    private func addAuthIfPossible(request: NSMutableURLRequest) -> NSMutableURLRequest {
        if let authToken = Authentication.loadAuthToken() {
            request.setValue("Bearer \(authToken.token!)", forHTTPHeaderField: "Authorization")
        }
        
        return request
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