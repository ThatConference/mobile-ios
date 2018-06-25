//
//  SpeakerAPI.swift
//  That Conference
//
//  Created by Steven Yang on 6/14/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import Foundation

enum SpeakerMethod: String {
    case Speakers = "/api3/Speakers/GetSpeakers"
}

enum SpeakerResult {
    case success([Speaker])
    case failure(Error)
}

class SpeakerAPI {
    
    let baseURLString = "https://www.thatconference.com"
    
    func getSpeakers(completionHandler: @escaping (SpeakerResult) -> Void) {
        
        let url: URL = URL(string: getSpeakerURL())!
                
        var request = URLRequest(url: url,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10.0)
    
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completionHandler(SpeakerResult.failure(error!))
            } else {
                
                do {
                    let jsonObject: Any = try? JSONSerialization.jsonObject(with: data!, options: []) as Any?
                    
                    guard let json = jsonObject as? [Dictionary<String, AnyObject>] else {
                        return completionHandler(SpeakerResult.failure(APIError.invalidJSONData))
                    }
                    
                    var speakerArray = [Speaker]()
                    
                    for jsonSpeaker in json {
                        
                        let speaker = Speaker()
                        speaker.firstName = jsonSpeaker["FirstName"] as? String
                        speaker.lastName = jsonSpeaker["LastName"] as? String
                        
                        if let headshotString = jsonSpeaker["HeadShot"] as? String {
                            speaker.headShotURL = URL(string: headshotString)
                        }
                        
                        speaker.biography = jsonSpeaker["Biography"] as? String
                        speaker.biographyHTML = jsonSpeaker["BiographyHtml"] as? String
                        
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
                            speaker.lastUpdated = SpeakerAPI.dateFormatter.date(from: lastUpdatedString)
                        }
                        
                        speakerArray.append(speaker)
                    }
                    PersistenceManager.saveSpeakers(speakerArray, path: Path.Speakers)
                    return completionHandler(SpeakerResult.success(speakerArray))
                }
            }
        }
        
        dataTask.resume()
    }
    
    fileprivate static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
    
    func getSpeakerURL() -> String {
        let url = self.baseURLString + SpeakerMethod.Speakers.rawValue;
        return url
    }
}
