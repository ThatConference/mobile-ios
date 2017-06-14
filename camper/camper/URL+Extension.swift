//
//  NSURL.swift
//  That Conference
//
//  Created by Matthew Ridley on 11/21/16.
//  Copyright © 2016 That Conference. All rights reserved.
//

import Foundation

extension URL {
    func getQueryItemValueForKey(key: String) -> String? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        guard let queryItems = components.queryItems else {
            return nil
        }
        
        return queryItems.filter {
            $0.name == key
        }.first?.value
    }
}
