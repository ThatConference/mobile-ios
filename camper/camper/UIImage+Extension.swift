//
//  UIImage+Extension.swift
//  That Conference
//
//  Created by Steven Yang on 6/14/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import Foundation

extension UIImageView {
    func loadImageURL(url: URL?) {
        
        self.image = UIImage(named: "profile")

        DispatchQueue.global().async {
            
            if (url == nil) {
                self.image = UIImage(named: "profile")
            } else {
                let urlString = ThatConferenceAPI.resourceURL(url!.absoluteString)
                if let image = IMAGE_CACHE.object(forKey: String(describing: urlString) as NSString) {
                    DispatchQueue.main.async {
                        self.image = image
                    }
                } else {
                    
                    if let headshot = url {
                        let url = ThatConferenceAPI.resourceURL(headshot.absoluteString)
                        if let data = try? Data(contentsOf: url) {
                            DispatchQueue.main.async {
                                let imageToCache = UIImage(data: data)
                                IMAGE_CACHE.setObject(imageToCache!, forKey: String(describing: urlString) as NSString)
                                self.image = imageToCache
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.image = UIImage(named: "profile")
                            }
                        }
                    }
                }
            }
        }
    }
}
