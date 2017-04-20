//
//  Sessions.swift
//  That Conference
//
//  Created by Steven Yang on 4/13/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import Foundation

class Sessions: NSObject, NSCoding {
    struct Keys {
        static let Sessions = "sessions"
    }
    
    var sessions: Dictionary<String, Session> = [:]
    
    override init() {}
    
    init(dictionary: [String: AnyObject]) {
        sessions = dictionary[Keys.Sessions] as! Dictionary<String, Session>
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(sessions, forKey: Keys.Sessions)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        sessions = aDecoder.decodeObject(forKey: Keys.Sessions) as! Dictionary<String, Session>
    }
}
