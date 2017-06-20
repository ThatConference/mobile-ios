//
//  UserAPI.swift
//  That Conference
//
//  Created by Steven Yang on 6/20/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import Foundation

enum UserMethod: String {
    case GetUser = "/api3/Account/UserProfile"
}

class UserAPI {
    let baseURLString = "https://www.thatconference.com"

    func getMainUser() {
        let url: URL = URL(string: getMainUserURL())!
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        
        request.httpMethod = "GET"
        if let token = Authentication.loadAuthToken() {
            request.addValue("Bearer \(token.token!)", forHTTPHeaderField: "Authorization")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            let user = User(dictionary: json as! [String: AnyObject])
            PersistenceManager.saveUser(user, path: Path.User)
            StateData.instance.currentUser = user
        }
        
        task.resume()
    }
    
    private func getMainUserURL() -> String {
        let url = self.baseURLString + UserMethod.GetUser.rawValue;
        
        return url
    }
    
    fileprivate static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
    
}
