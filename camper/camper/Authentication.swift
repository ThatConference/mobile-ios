//
//  Authentication.swift
//  That Conference
//
//  Created by Matthew Ridley on 4/11/16.
//  Copyright © 2016 That Conference. All rights reserved.
//

import Foundation

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
}