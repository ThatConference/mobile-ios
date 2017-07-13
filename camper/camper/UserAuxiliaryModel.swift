//
//  UserAuxiliaryModel.swift
//  That Conference
//
//  Created by Steven Yang on 7/12/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import Foundation

class UserAuxiliaryModel {
    
    struct Keys {
        static let Id = "Id"
        static let FirstName = "FirstName"
        static let LastName = "LastName"
        static let Company = "Company"
        static let HeadShot = "HeadShot"
        static let DisplayHeadShot = "DisplayHeadShot"
        static let AuxiliaryId = "AuxiliaryId"
    }
    
    var id: String!
    var firstName: String!
    var lastName: String!
    var company: String?
    var headShot: String?
    var displayHeadShot: String?
    var auxiliaryID: UInt32!
    
    init(dictionary: [String: AnyObject]) {
        id = dictionary[Keys.Id] as! String
        firstName = dictionary[Keys.FirstName] as! String
        lastName = dictionary[Keys.LastName] as! String
        headShot = dictionary[Keys.HeadShot] as? String
        displayHeadShot = dictionary[Keys.DisplayHeadShot] as? String
        company = dictionary[Keys.Company] as? String
        auxiliaryID = dictionary[Keys.AuxiliaryId] as! UInt32
    }
    
    var fullName: String {
        return "\(firstName!) \(lastName!)"
    }
    
    var displayHeadShotString: String {
        if (displayHeadShot == nil) {
            return ""
        }
        return displayHeadShot!
    }
    
    var companyString: String {
        if (company == nil) {
            return ""
        }
        return company!
    }
    
    var int16AAuxId: UInt16! {
        let a = UInt16(auxiliaryID >> 16)
        return a
    }
    
    var int16BAuxId: UInt16! {
        let b = UInt16(auxiliaryID & 0x00ffff)
        return b
    }
}
