//
//  LoadImageView.swift
//  That Conference
//
//  Created by Steven Yang on 8/3/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class LoadImageView: UIImageView {
    
    var imageURLString: String?
    
    
    func loadImageURL(url: URL?) {
        
        guard let url = url else {
            self.image = UIImage(named: "profile")
            return
        }
        
        let urlString = ThatConferenceAPI.resourceURL(url.absoluteString)
        let imageURLString: NSString = "\(urlString)" as NSString
        
        self.image = UIImage(named: "profile")
        
        if let image = IMAGE_CACHE.object(forKey: imageURLString) {
            self.image = image
            return
        }
        
        let mainUrl = ThatConferenceAPI.resourceURL(url.absoluteString)
        
        URLSession.shared.dataTask(with: mainUrl) { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                let imageToCache = UIImage(data: data!)
                
                self.image = imageToCache
                
                IMAGE_CACHE.setObject(imageToCache!, forKey: imageURLString)
            }
        }.resume()
    }
}
