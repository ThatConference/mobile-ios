//
//  ContactAPI.swift
//  That Conference
//
//  Created by Steven Yang on 7/3/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import Foundation
import Firebase

enum ContactMethod: String {
    case DeleteContact = "/api3/Accout/Contact/{shareContactId}"
    case GetContacts = "/api3/Account/Contacts"
    case GetContact = "/api3/Account/UserProfile/{userID}"
    case ContactSharing = "/contact-sharing"
    case PostContact = "/api3/Account/Contact"
    case UserAuxiliaryInfo = "/api3/Account/UserInfosAuxiliary?"
}

enum GetContactResult {
    case success([Contact])
    case failure(Error)
}

enum GetUserAuxInfo {
    case success([UserAuxiliaryModel])
    case failure(Error)
}

enum DeleteContactResult {
    case success()
    case failure(Error)
}

class ContactAPI {
    let tcBaseURLString = "https://www.thatconference.com"
    let conditionRef = Database.database().reference().child("contact-sharing")

    let year = "2017"
    
    func getContact(userID: String) {
        let url: URL = URL(string: getContactURL(userID))!
        
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
            print(json)
        }
        
        task.resume()
    }
    
    private func getContactURL(_ userID: String) -> String {
        let url = self.tcBaseURLString + ContactMethod.GetContact.rawValue;
        let customURL = url.replacingOccurrences(of: "{userID}", with: userID)
        
        return customURL
    }
    
    func getContacts(completionHandler: @escaping (GetContactResult) -> Void) {
        let url: URL = URL(string: getContactsURL())!
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        
        request.httpMethod = "GET"
        if let token = Authentication.loadAuthToken() {
            request.addValue("Bearer \(token.token!)", forHTTPHeaderField: "Authorization")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print(error!)
                return completionHandler(GetContactResult.failure(error!))
            }
            
            var contactArray: [Contact] = []
            
            let jsonObject: Any = try! JSONSerialization.jsonObject(with: data!, options: [])
            
            guard let json = jsonObject as? [Dictionary<String, AnyObject>] else {
                return completionHandler(GetContactResult.success([]))
            }
            
            for jsonContact in json {
                let contact = Contact(dictionary: jsonContact)
//                if let blockedContact = self.conditionRef. ) {
//                    
//                }
                contactArray.append(contact)
            }
                        
            PersistenceManager.saveContacts(contactArray, path: Path.CamperContacts)
            StateData.instance.camperContacts = contactArray
            return completionHandler(GetContactResult.success(contactArray))
        }
        
        task.resume()
    }
    
    private func getContactsURL() -> String {
        let url = self.tcBaseURLString + ContactMethod.GetContacts.rawValue;
        
        return url
    }
    
    func postContacts(contactIDs: Dictionary<String, Int>) {
        for contactId in contactIDs {
            postContact(contactID: contactId.key)
        }
    }
    
    func postContact(contactID: String) {
        
        let params: [String: AnyObject] = ["UserId": contactID as AnyObject,
                                        "Memo": "" as AnyObject
        ]

        let jsonData = try? JSONSerialization.data(withJSONObject: params)
        
        let url: URL = URL(string: postContactURL())!
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "POST"
        
        if let token = Authentication.loadAuthToken() {
            let headers = [
                "Authorization": "Bearer \(token.token!)",
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            request.allHTTPHeaderFields = headers
        }
        
        request.httpBody = jsonData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print(error!)
                return
            }
        }
        
        task.resume()
    }
    
    private func postContactURL() -> String {
        let url = self.tcBaseURLString + ContactMethod.PostContact.rawValue;
        
        return url
    }
    
    
    func deleteContact(shareContactId: Int, completionHandler: @escaping (DeleteContactResult) -> Void) {
        
        let url: URL = URL(string: deleteContactURL(shareContactId: shareContactId))!
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "DELETE"
        
        if let token = Authentication.loadAuthToken() {
            let headers = [
                "Authorization": "Bearer \(token.token!)",
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            request.allHTTPHeaderFields = headers
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print(error!)
                return completionHandler(DeleteContactResult.failure(error!))
            }
            
            return completionHandler(DeleteContactResult.success())
        }
        
        task.resume()
    }
    
    private func deleteContactURL(shareContactId: Int) -> String {
        let url = self.tcBaseURLString + ContactMethod.GetContact.rawValue;
        let deleteURL = url.replacingOccurrences(of: "{shareContactId}", with: "\(shareContactId)")
        
        return deleteURL
    }
    
    // GET USER AUX ID HERE
    
    func getAuxUsers(auxIdArray: [Int], completionHandler: @escaping (GetUserAuxInfo) -> Void) {
        let url: URL = URL(string: getUserAuxURL(array: auxIdArray))!
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        
        request.httpMethod = "GET"
        if let token = Authentication.loadAuthToken() {
            request.addValue("Bearer \(token.token!)", forHTTPHeaderField: "Authorization")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print(error!)
                return completionHandler(GetUserAuxInfo.failure(error!))
            }
            
            var userAuxArray: [UserAuxiliaryModel] = []
            
            let jsonObject: Any = try! JSONSerialization.jsonObject(with: data!, options: [])
            
            guard let json = jsonObject as? [Dictionary<String, AnyObject>] else {
                return completionHandler(GetUserAuxInfo.success([]))
            }
            
            for object in json {
                let userAux = UserAuxiliaryModel(dictionary: object)
                userAuxArray.append(userAux)
            }
            
            return completionHandler(GetUserAuxInfo.success(userAuxArray))
        }
        
        task.resume()
    }
    
    private func getUserAuxURL(array: [Int]) -> String {
        var url = self.tcBaseURLString + ContactMethod.UserAuxiliaryInfo.rawValue;
        
        for x in 0..<array.count {
            let auxId = array[x]
            if (x == 0) {
                let string = "userIds[\(x)]=\(auxId)"
                url.append(string)
            } else {
                let string = "&userIds[\(x)]=\(auxId)"
                url.append(string)
            }
        }

        return url
    }
    
}
