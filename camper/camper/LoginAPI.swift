//
//  LoginAPI.swift
//  That Conference
//
//  Created by Steven Yang on 7/24/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import Foundation

enum LoginMethod: String {
    case ExternalLogin = "api3/Account/ExternalLogins?returnUrl={returnUrl}&generateState={generateState}"
}

enum LoginResult {
    case success([ExternalLoginResult])
    case failure(Error)
}

class LoginAPI {
    
    let baseURLString = "https://www.thatconference.com"
    let year = "2017"
    
    func externaLogin(returnURL: String, generateState: Bool) {
        let url = URL(string: self.getExternalURL(returnURL: returnURL, generateState: generateState))
        
        
    }
    
    func getExternalURL(returnURL: String, generateState: Bool) -> String {
        let url = self.baseURLString + LoginMethod.ExternalLogin.rawValue;
        let url2 = url.replacingOccurrences(of: "{returnUrl}", with: returnURL)
        let url3 = url2.replacingOccurrences(of: "{generateState}", with: String(generateState))
        
        return url3
    }
    
}
