import Foundation

class SessionStore {
    enum SessionDataRetrieval {
        case success(Dictionary<String, DailySchedule>)
        case failure(Error)
    }
    
    func getDailySchedules(_ returnSchedule: Bool, completion: @escaping (SessionDataRetrieval) -> Void) {
        var sessions = [Session]()

        do {
            try self.fetchAll(requiresLogin: false) {
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
    
    private func testData(sessions: [Session]) {
        // For getSchedules
        
//        let dateString1 = "2017-04-10 12:00:00 +0000"
//        let dateString2 = "2017-04-10 13:30:00 +0000"
//        let dateString3 = "2017-04-11 14:45:00 +0000"
//        let dateString4 = "2017-04-11 15:00:00 +0000"
//        let dateString5 = "2017-04-11 19:45:00 +0000"
//        let dateString6 = "2017-04-11 20:00:00 +0000"
//        
//        let sessionOne = Session(cancelled: false, accepted: true, id: 190, title: "You Are Alive!", sessionDescription: "There is something coo;", scheduledDateTime: dateString1.stringToDate, scheduledRoom: "B", primaryCategory: "That Conference", level: "100", speakers: [], isFamilyApproved: true, isUserFavorite: false, updated: false)
//
//        let sessionTwo = Session(cancelled: false, accepted: true, id: 191, title: "You Are Alive!", sessionDescription: "There is something coo;", scheduledDateTime: dateString2.stringToDate, scheduledRoom: "B", primaryCategory: "Open Spaces", level: "100", speakers: [], isFamilyApproved: true, isUserFavorite: false, updated: false)
//
//        let sessionThree = Session(cancelled: false, accepted: true, id: 192, title: "You Are Alive!", sessionDescription: "There is something coo;", scheduledDateTime: dateString3.stringToDate, scheduledRoom: "B", primaryCategory: "That Conference", level: "100", speakers: [], isFamilyApproved: true, isUserFavorite: false, updated: false)
//
//        let sessionFour = Session(cancelled: false, accepted: true, id: 193, title: "You Are Alive!", sessionDescription: "There is something coo;", scheduledDateTime: dateString4.stringToDate, scheduledRoom: "B", primaryCategory: "That Conference", level: "100", speakers: [], isFamilyApproved: true, isUserFavorite: false, updated: false)
//
//        let sessionFive = Session(cancelled: false, accepted: true, id: 192, title: "You Are Alive!", sessionDescription: "There is something coo;", scheduledDateTime: dateString5.stringToDate, scheduledRoom: "B", primaryCategory: "That Conference", level: "100", speakers: [], isFamilyApproved: true, isUserFavorite: false, updated: false)
//
//        let sessionSix = Session(cancelled: false, accepted: true, id: 193, title: "You Are Alive!", sessionDescription: "There is something coo;", scheduledDateTime: dateString6.stringToDate, scheduledRoom: "B", primaryCategory: "That Conference", level: "100", speakers: [], isFamilyApproved: true, isUserFavorite: false, updated: false)
//        
//        sessions.append(sessionOne)
//        sessions.append(sessionTwo)
//        sessions.append(sessionThree)
//        sessions.append(sessionFour)
//        sessions.append(sessionFive)
//        sessions.append(sessionSix)
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
        
        ThatConferenceAPI.getFavoriteSessions(completionHandler: {(sessionsResult) -> Void in
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
    
    fileprivate func fetchAll(requiresLogin: Bool, completion: @escaping (SessionsResult) -> Void) throws {
        let url = ThatConferenceAPI.sessionsGetAcceptedURL(nil)
        var request = URLRequest(url: url)
        
        if let token = Authentication.loadAuthToken() {
            request.addValue("Bearer \(token.token!)", forHTTPHeaderField: "Authorization")
        } else {
            if requiresLogin {
                throw APIError.notLoggedIn
            }
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
