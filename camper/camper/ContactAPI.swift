//
//  ContactAPI.swift
//  That Conference
//
//  Created by Steven Yang on 7/3/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import Foundation

enum ContactMethod: String {
    case GetContacts = "vendor/api/contacts?year={year}"
    case ContactSharing = "/contact-sharing"
}

enum GetContactResult {
    case success()
    case failure(Error)
}

class ContactAPI {
    let tcBaseURLString = "https://www.thatconference.com"
    let fbBaseURLString = "https://that-phone.firebaseio.com"
    
    let year = "2017"
    
    func getContacts() {
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
            print(user.id)
            PersistenceManager.saveUser(user, path: Path.User)
            StateData.instance.currentUser = user
        }
        
        task.resume()
    }
    
    private func getMainUserURL() -> String {
        let url = self.tcBaseURLString + UserMethod.GetContacts.rawValue;
//        let customUrl = 
        
        return url
    }
}
