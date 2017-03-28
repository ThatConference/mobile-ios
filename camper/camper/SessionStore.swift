import Foundation

class SessionStore {
    enum SessionDataRetrieval {
        case success(Dictionary<String, DailySchedule>)
        case failure(Error)
    }
    
    func getDailySchedules(_ returnSchedule: Bool, completion: @escaping (SessionDataRetrieval) -> Void) {
        var sessions = [Session]()
        
        do {
            try self.fetchAll() {
                (sessionResult) -> Void in
                switch sessionResult {
                case .success(let returnedSessions):
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
                            dateString = self.getDate(date as Date)
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
                                    if timeSlot?.time == session.scheduledDateTime {
                                        timeSlot?.sessions.append(session)
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
                                    if timeSlot?.time == session.scheduledDateTime {
                                        timeSlot?.sessions.append(session)
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
                        return completion(.success(schedule))
                    } else {
                        return completion(.success(openspaces))
                    }
                case .failure(let error):
                    return completion(.failure(error))
                }
            }
        }
        catch let error {
            return completion(.failure(error))
        }
    }
    
    func addFavorite(_ session: Session, completion: @escaping (SessionsResult) -> Void) {
        ThatConferenceAPI.saveFavorite(session.id, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                return completion(SessionsResult.failure(error!))
            }
            
            session.isUserFavorite = true
            return completion(.success([session]))
        })
    }
    
    func removeFavorite(_ session: Session, completion: @escaping (SessionsResult) -> Void) {
        ThatConferenceAPI.deleteFavorite(session.id, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                return completion(SessionsResult.failure(error!))
            }
            
            session.isUserFavorite = false
            return completion(.success([session]))
        })

    }
    
    func getFavoriteSessions(completion: @escaping (SessionDataRetrieval) -> Void) {
        var sessions = [Session]()
        
        ThatConferenceAPI.getFavoriteSessions(ThatConferenceAPI.GetCurrentYear(), completionHandler: {(sessionsResult) -> Void in
            switch sessionsResult {
            case .success(let returnedSessions):
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
                            if timeSlot?.time == session.scheduledDateTime {
                                timeSlot?.sessions.append(session)
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
                
                return completion(.success(schedule))
            case .failure(let error):
                return completion(.failure(error))
            }
        })
    }
    
    fileprivate func fetchAll(completion: @escaping (SessionsResult) -> Void) throws {
        let url = ThatConferenceAPI.sessionsGetAcceptedURL(nil)
        var request = URLRequest(url: url)
        
        if let token = Authentication.loadAuthToken() {
            request.addValue("Bearer \(token.token!)", forHTTPHeaderField: "Authorization")
        } else {
            throw APIError.notLoggedIn
        }
        
        let task = ThatConferenceAPI.nsurlSession.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            
            let result = self.processSessionsRequest(data: data, error: error)
            
            return completion(result)
        }) 
        task.resume()
    }
    
    fileprivate func processSessionsRequest(data: Data?, error: Error?) -> SessionsResult {
        guard let jsonData = data
            else {
                return .failure(error!)
        }
        
        return ThatConferenceAPI.sessionsFromJSONData(jsonData)
    }
    
    private func getDate(_ dateTime: Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-YYYY"
        
        return dateFormatter.string(from: dateTime!)
    }
    
    class func getFormattedTime(_ dateTime: Date?) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        
        return timeFormatter.string(from: dateTime!)
    }

}
