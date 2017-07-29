import Foundation
import Locksmith

class Authentication {
    func performLocalLogin(_ username: String, password: String, completionDelegate: RequestCompleteProtocol) {
        let tcAPI = ThatConferenceAPI()
        tcAPI.requestCompleteProtocol = completionDelegate
        tcAPI.localLogin(username, password: password)
    }
    
    func fetchExternalLogins(completion: @escaping (ExternalLoginResult) -> Void) {
        let url = ThatConferenceAPI.externalLoginsURL()
        let request = URLRequest(url: url as URL)
        let task = ThatConferenceAPI.nsurlSession.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            
            let result = self.processExternalLoginsRequest(data: data, error: error as NSError?)
            completion(result)
        }) 
        task.resume()
    }

    func processExternalLoginsRequest(data: Data?, error: NSError?) -> ExternalLoginResult {
        guard let jsonData = data
            else {
                return .failure(error!)
        }
        
        return ThatConferenceAPI.externalLoginsFromJSONData(jsonData)
    }
    
    
    func fetchGoogleLogins(completion: @escaping (ExternalLoginResult) -> Void) {
        let url = ThatConferenceAPI.googleLoginsURL()
        let request = URLRequest(url: url as URL)
        let task = ThatConferenceAPI.nsurlSession.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            
            let result = self.processExternalLoginsRequest(data: data, error: error as NSError?)
            completion(result)
        })
        task.resume()
    }
    
    func processGoogleLoginsRequest(data: Data?, error: NSError?) -> ExternalLoginResult {
        guard let jsonData = data
            else {
                return .failure(error!)
        }
        
        
        return ThatConferenceAPI.externalLoginsFromJSONData(jsonData)
    }
    
    static let AuthTokenLocation = "TCAuthToken"
    static let key_Token = "token"
    static let key_Expiration = "expires"
    
    static func saveAuthToken(_ authToken: AuthToken) {
        do {
            try Locksmith.updateData(data: [key_Token: authToken.token, key_Expiration: authToken.expiration], forUserAccount: AuthTokenLocation)
        } catch {
            print ("Could not save auth token")
        }
    }
    
    static func loadAuthToken() -> AuthToken? {
        if let dictionary = Locksmith.loadDataForUserAccount(userAccount: AuthTokenLocation) as Dictionary<String, AnyObject>! {
            let authToken = AuthToken()
            authToken.token = dictionary[key_Token] as! String
            authToken.expiration = (dictionary[key_Expiration] as! NSDate) as Date!
            return authToken
        }
        return nil
    }
    
    static func removeAuthToken() {
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: AuthTokenLocation)
        } catch {
            print ("Could not remove auth token")
        }
    }
    
    static func isLoggedIn() -> Bool {
        var loggedIn = false
        
        if let authToken = Authentication.loadAuthToken() {
            if authToken.expiration.isGreaterThanDate(Date()) {
                loggedIn = true
            } else {
                Authentication.removeAuthToken()
            }
        }
        
        return loggedIn
    }
}
