//
//  StateData.swift
//  That Conference
//
//  Created by Steven Yang on 4/5/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import Foundation

class StateData {
    static let instance = StateData()
    public var sessionStore: SessionStore! = SessionStore()
    public var offlineFavoriteSessions: Sessions = Sessions()
    
    private init() {}
}
