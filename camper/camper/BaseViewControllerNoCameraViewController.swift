//
//  BaseViewControllerNoCameraViewController.swift
//  That Conference
//
//  Created by Steven Yang on 7/12/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import CoreLocation
import UIKit

class BaseViewControllerNoCameraViewController: UIViewController {

    var refreshControl: UIRefreshControl!
    var activityIndicator: UIActivityIndicatorView!
    var loadingView: LoadingUIView!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndicator = UIActivityIndicatorView()
        self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        self.activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.4)
        self.activityIndicator.layer.cornerRadius = 10
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.activityIndicator.clipsToBounds = true
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        locationManager = CLLocationManager()
        
        let status = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func startIndicator() {
        DispatchQueue.main.async(execute: {
            self.activityIndicator.startAnimating()
        })
    }
    
    func stopIndicator() {
        DispatchQueue.main.async(execute: {
            self.activityIndicator.stopAnimating()
        })
    }
    
    func simpleAlert(title: String, body: String) {
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    func revealViewControllerFunc(barButton: UIBarButtonItem) {
        if revealViewController() != nil {
            barButton.target = revealViewController()
            barButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().panGestureRecognizer().isEnabled = false
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func loadingScreen() {
        loadingView = LoadingUIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        
        loadingView.startIndicator()

        self.view.addSubview(loadingView)
    }
    
    func hideLoadingScreen() {
        self.loadingView.hide() {
            self.loadingView.stopIndicator()
            self.loadingView.removeFromSuperview()
        }
    }
}
