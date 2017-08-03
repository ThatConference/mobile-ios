//
//  AuthorizationWebViewController.swift
//  That Conference
//
//  Created by Matthew Ridley on 4/14/16.
//  Copyright © 2016 That Conference. All rights reserved.
//

import UIKit
import Foundation
import Fabric
import Crashlytics
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

protocol ContainerDelegateProtocol
{
    func Close()
    func SignedIn()
}

class AuthorizationWebViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet var webView: UIWebView!

    var delegate:ContainerDelegateProtocol?
    var spinner: UIActivityIndicatorView!
    var currentProvider: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.spinner = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
        self.spinner.center = self.view.center
        self.spinner.hidesWhenStopped = true
        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.view.addSubview(self.spinner)
    }
    
    func openOAuthDestination(_ url: URL, provider: String) {
        self.currentProvider = provider
        let request = URLRequest(url: url)
        webView.loadRequest(request)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        self.spinner.startAnimating()
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if var currentURL = webView.request?.url! {
            
            let baseURL = currentURL.host!
            let stringURL = currentURL.absoluteString.replacingOccurrences(of: "/#access_token", with: "?access_token")
            currentURL = URL(string: stringURL)!
                        
            //Only handle when it comes back to That Conference
            if baseURL.contains("thatconference") {
                let fullURL = currentURL.absoluteString
                let result = fullURL.range(of: "access_token" )
                if result != nil {
                    let authToken = AuthToken()
                    authToken.token = currentURL.getQueryItemValueForKey(key: "access_token")
                    authToken.expiration = Date().addDays(7)
                    
                    let expireSeconds = currentURL.getQueryItemValueForKey(key: "expires_in")
                    if (expireSeconds != nil) {
                        let numericValue = Double(expireSeconds!)!
                        authToken.expiration = Date().addingTimeInterval(numericValue)
                    }

                    Authentication.saveAuthToken(authToken)
                    Answers.logLogin(withMethod: "oAuth Login", success: true, customAttributes: [:])
                    delegate?.SignedIn()
                }
            }
        }
        
        self.spinner.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.spinner.stopAnimating()
    }
    
    @IBAction func cancelWasPressed(_ sender: AnyObject) {
        delegate?.Close()
    }
}
