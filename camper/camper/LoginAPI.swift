//
//  LoginAPI.swift
//  That Conference
//
//  Created by Steven Yang on 7/24/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import Foundation

enum LoginMethod: String {
    case ExternalLogin = "/api3/Account/ExternalLogins?returnUrl={returnUrl}&generateState={generateState}"
}

enum LoginResult {
    case success(URL)
    case failure(Error)
}

class LoginAPI {
    
    let baseURLString = "https://www.thatconference.com"
    let baseTestURLString = "https://thatconference2014-staging.azurewebsites.net"
    let baseURLScheme = "thatconference://"
    let loginRedirect = "/api3/account/mobileloginredirect"
    let year = "2017"
    
    func googleLogin(completion: @escaping (LoginResult) -> Void)  {
        
        let url = URL(string: self.getGoogleURL(returnURL: baseTestURLString + loginRedirect,  //CHANGE RETURN URL HERE
                                                generateState: true))!
        print(url)
        
        let urlRequest = URLRequest(url: url)
        
        let task = ThatConferenceAPI.nsurlSession.dataTask(with: urlRequest, completionHandler: {
            (data, response, error) -> Void in
            
            guard let jsonData = data else {
                print(error!)
                return
            }
            
            let externalLogins: ExternalLoginResult = ThatConferenceAPI.externalLoginsFromJSONData(jsonData)
            switch (externalLogins) {
            case .success(let externalLogins):
                for externalLogin in externalLogins {
                    
                    if (externalLogin.name == "Google") {
                        let urlString = self.baseTestURLString + externalLogin.url!
                        
                        print("URL: \(urlString)")
                        
                        return completion(LoginResult.success((URL(string: urlString)!)))
                    }
                break
                }
            case .failure(let error):
                print("Error: \(error)")
                return completion(LoginResult.failure(error))
            }
            
        })
        task.resume()
        
    }
    
    func getGoogleURL(returnURL: String, generateState: Bool) -> String {
        let url = self.baseTestURLString + LoginMethod.ExternalLogin.rawValue;
        let url2 = url.replacingOccurrences(of: "{returnUrl}", with: returnURL)
        let url3 = url2.replacingOccurrences(of: "{generateState}", with: String(generateState))
        
        return url3
    }
    
}
