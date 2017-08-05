//
//  LoadImageView.swift
//  That Conference
//
//  Created by Steven Yang on 8/3/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

typealias ImageCacheLoaderCompletionHandler = ((UIImage) -> ())

class ImageCacheLoader {
  
  var task: URLSessionDownloadTask!
  var session: URLSession!
  
  init() {
    session = URLSession.shared
    task = URLSessionDownloadTask()
  }
  
    func loadImageURL(url: URL?, completionHandler: @escaping ImageCacheLoaderCompletionHandler) {
        let placeholder = UIImage(named: "profile")
      
        guard let url = url else {
          DispatchQueue.main.async {
            completionHandler(placeholder!)
          }
          return
        }
        
        let urlString = ThatConferenceAPI.resourceURL(url.absoluteString)
        let imageURLString: NSString = "\(urlString)" as NSString
        
        if let image = IMAGE_CACHE.object(forKey: imageURLString) {
          DispatchQueue.main.async {
            completionHandler(image)
          }
        }
        
        let mainUrl = ThatConferenceAPI.resourceURL(url.absoluteString)
        
        session.dataTask(with: mainUrl) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }

            let img: UIImage! = UIImage(data: data!)
            IMAGE_CACHE.setObject(img, forKey: imageURLString as NSString)
            DispatchQueue.main.async {
              completionHandler(img)
            }
        }.resume()
    }
}
