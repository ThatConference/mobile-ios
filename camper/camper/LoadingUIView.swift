//
//  LoadingUIView.swift
//  That Conference
//
//  Created by Steven Yang on 7/13/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class LoadingUIView: UIView {

    var activityIndicator: UIActivityIndicatorView!
    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 300, height: 40)
        label.text = "Scanning for Campers Near You"
        label.textColor = UIColor.black.withAlphaComponent(0.6)
        label.font = UIFont(name: "Neutraface Text", size: 16.0)
        label.textAlignment = .center
        let cgPoint = CGPoint(x: self.center.x, y: self.center.y - 100)
        label.center = cgPoint
        self.addSubview(label)
        
        self.activityIndicator = UIActivityIndicatorView()
        self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        self.activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.4)
        self.activityIndicator.layer.cornerRadius = 10
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.activityIndicator.clipsToBounds = true
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.center = self.center
        self.addSubview(activityIndicator)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hide(completed: @escaping () -> ()) {
        
        UIView.animate(withDuration: 0.5) {
            self.backgroundColor = UIColor.white.withAlphaComponent(0.0)
            self.isHidden = true
            completed()
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

}
