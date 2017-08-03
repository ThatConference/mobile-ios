//
//  UIImage+Extension.swift
//  That Conference
//
//  Created by Steven Yang on 6/14/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import Foundation

//extension UIImageView {
//    func loadImageURL(url: URL?) {
//        
//        guard let url = url else {
//            self.image = UIImage(named: "profile")
//            return
//        }
//        
//        let urlString = ThatConferenceAPI.resourceURL(url.absoluteString)
//        
//        self.image = UIImage(named: "profile")
//        
//        if let image = IMAGE_CACHE.object(forKey: String(describing: urlString) as NSString) {
//            DispatchQueue.main.async {
//                self.image = image
//                return
//            }
//        }
//
//        let mainUrl = ThatConferenceAPI.resourceURL(url.absoluteString)
//        if let data = try? Data(contentsOf: mainUrl) {
//            DispatchQueue.main.async {
//                let imageToCache = UIImage(data: data)
//                IMAGE_CACHE.setObject(imageToCache!, forKey: String(describing: urlString) as NSString)
//                self.image = imageToCache
//            }
//        } else {
//            DispatchQueue.main.async {
//                self.image = UIImage(named: "profile")
//            }
//        }
//    }
//}


