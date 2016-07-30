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
        
        self.spinner = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
        self.spinner.center = self.view.center
        self.spinner.hidesWhenStopped = true
        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(self.spinner)
    }
    
    func openOAuthDestination(url: NSURL, provider: String) {
        self.currentProvider = provider
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        self.spinner.startAnimating()
        return true
    }
    
    let expires = "expires_in="
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if let currentURL = webView.request?.URL! {
            let baseURL = currentURL.host!
            
            //Only handle when it comes back to That Conference
            if baseURL.containsString("thatconference") {
                let fullURL = currentURL.absoluteString
                let result = fullURL.rangeOfString("token",
                                                      options: NSStringCompareOptions.LiteralSearch,
                                                      range: fullURL.startIndex..<fullURL.endIndex,
                                                      locale: nil)
                if let range = result {
                    let start = range.startIndex.advancedBy(6)
                    let queryString = fullURL[start..<fullURL.endIndex]
                    let queryArray = queryString.characters.split{$0 == "&"}.map(String.init)
                    
                    //Save Values to KeyChain
                    let authToken = AuthToken()
                    authToken.token = queryArray[0]
                    
                    for index in 0...queryArray.count - 1 {
                        let value = queryArray[index]
                        let location_Expires = value.rangeOfString(expires, options: NSStringCompareOptions.LiteralSearch,
                                                                   range: value.startIndex..<value.endIndex,
                                                                   locale: nil)
                        if (location_Expires?.count >= 0) {
                            let expireStart = value.startIndex.advancedBy(expires.characters.count)
                            let expireSeconds = value[expireStart..<value.endIndex]
                            let numericValue = Double(expireSeconds)!
                            authToken.expiration = NSDate().dateByAddingTimeInterval(numericValue)
                        }
                    }
                    
                    Authentication.saveAuthToken(authToken)
                    Answers.logLoginWithMethod("oAuth Login", success: true, customAttributes: [:])
                    delegate?.SignedIn()
                }
            }
        }
        
        self.spinner.stopAnimating()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        self.spinner.stopAnimating()
    }
    
    @IBAction func cancelWasPressed(sender: AnyObject) {
        delegate?.Close()
    }
}