//
//  Authentication.swift
//  That Conference
//
//  Created by Matthew Ridley on 4/11/16.
//  Copyright © 2016 That Conference. All rights reserved.
//

import Foundation
import Locksmith

class Authentication {
    func fetchExternalLogins(completion completion: (ExternalLoginResult) -> Void) {
        let url = ThatConferenceAPI.externalLoginsURL()
        let request = NSURLRequest(URL: url)
        let task = ThatConferenceAPI.nsurlSession.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            let result = self.processExternalLoginsRequest(data: data, error: error)
            completion(result)
        }
        task.resume()
    }

    func processExternalLoginsRequest(data data: NSData?, error: NSError?) -> ExternalLoginResult {
        guard let jsonData = data
            else {
                return .Failure(error!)
        }
        
        return ThatConferenceAPI.externalLoginsFromJSONData(jsonData)
    }
    
    static let AuthTokenLocation = "TCAuthToken"
    static let key_Token = "token"
    static let key_Expiration = "expires"
    
    static func saveAuthToken(authToken: AuthToken) {
        do {
            try Locksmith.updateData([key_Token: authToken.token, key_Expiration: authToken.expiration], forUserAccount: AuthTokenLocation)
        } catch {
            print ("Could not save auth token")
        }
    }
    
    static func loadAuthToken() -> AuthToken? {
        if let dictionary = Locksmith.loadDataForUserAccount(AuthTokenLocation) as Dictionary<String, AnyObject>! {
            let authToken = AuthToken()
            authToken.token = dictionary[key_Token] as! String
            authToken.expiration = dictionary[key_Expiration] as! NSDate
            return authToken
        }
        return nil
    }
    
    static func removeAuthToken() {
        do {
            try Locksmith.deleteDataForUserAccount(AuthTokenLocation)
        } catch {
            print ("Count not remove auth token")
        }
    }
}