//
//  User.swift
//  That Conference
//
//  Created by Steven Yang on 6/19/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding {
    struct Keys {
        static let Id = "Id"
        static let HeadShot = "HeadShot"
        static let DisplayHeadShot = "DisplayHeadShot"
        static let FirstName = "FirstName"
        static let LastName = "LastName"
        static let Email = "Email"
        static let Phone = "PhoneNumber"
        static let City = "City"
        static let State = "State"
        static let Company = "Company"
        static let Title = "Title"
        static let Website = "WebSite"
        static let Twitter = "Twitter"
        static let LinkedIn = "LinkedIn"
        static let Facebook = "Facebook"
        static let GooglePlus = "GooglePlus"
        static let Github = "GitHub"
        static let Pinterest = "Pintrest"
        static let Instagram = "Instagram"
        static let Biography = "Biography"
        static let PublicEmail = "PublicEmail"
        static let PublicPhone = "PublicPhone"
        static let PublicThatSlackHandle = "PublicThatSlackHandle"
        static let AuxiliaryId = "AuxiliaryId"
    }
    
    private var _id: String!
    private var _headShot: String?
    private var _displayHeadshot: String?
    
    private var _firstName: String!
    private var _lastName: String!
    private var _email: String!
    private var _auxiliaryId: UInt32!
    
    var publicEmail: String?
    
    var biography: String?
    
    var phone: String?
    var publicPhone: String?
    
    var publicThatSlackHandle: String?
    
    var city: String?
    var state: String?
    var company: String?
    var title: String?
    var website: String?
    var twitter: String?
    var facebook: String?
    var googlePlus: String?
    var github: String?
    var pinterest: String?
    var instagram: String?
    var linkedIn: String?
    
    override init() {
        _id = ""
        _firstName = "Guest"
        _lastName = ""
        _email = ""
        _auxiliaryId = 0
    }
    
    init(dictionary: [String: AnyObject]) {
        _id = dictionary[Keys.Id] as! String
        _headShot = dictionary[Keys.HeadShot] as? String
        _displayHeadshot = dictionary[Keys.DisplayHeadShot] as? String
        _firstName = dictionary[Keys.FirstName] as! String
        _lastName = dictionary[Keys.LastName] as! String
        _email = dictionary[Keys.Email] as! String
        publicEmail = dictionary[Keys.PublicEmail] as? String
        biography = dictionary[Keys.Biography] as? String
        phone = dictionary[Keys.Phone] as? String
        publicPhone = dictionary[Keys.PublicPhone] as? String
        publicThatSlackHandle = dictionary[Keys.PublicThatSlackHandle] as? String
        city = dictionary[Keys.City] as? String
        state = dictionary[Keys.State] as? String
        company = dictionary[Keys.Company] as? String
        title = dictionary[Keys.Title] as? String
        website = dictionary[Keys.Website] as? String
        twitter = dictionary[Keys.Twitter] as? String
        facebook = dictionary[Keys.Facebook] as? String
        googlePlus = dictionary[Keys.GooglePlus] as? String
        github = dictionary[Keys.Github] as? String
        pinterest = dictionary[Keys.Pinterest] as? String
        instagram = dictionary[Keys.Instagram] as? String
        linkedIn = dictionary[Keys.LinkedIn] as? String
        _auxiliaryId = dictionary[Keys.AuxiliaryId] as! UInt32
    }
    
    init(id: String, headShot: String?, displayHeadShot: String?, firstName: String, lastName: String, email: String, publicEmail: String?, biography: String?, phone: String?, publicPhone: String?, publicThatSlackHandle: String?, city: String?, state: String?, company: String?, title: String?, website: String?, twitter: String?, facebook: String?, googlePlus: String?, github: String?, pinterest: String?, instagram: String?, linkedIn: String?, auxiliaryId: UInt32) {
        self._id = id
        self._headShot = headShot
        self._displayHeadshot = displayHeadShot
        self._firstName = firstName
        self._lastName = lastName
        self._email = email
        self.publicEmail = publicEmail
        self.biography = biography
        self.phone = phone
        self.publicPhone = publicPhone
        self.publicThatSlackHandle = publicThatSlackHandle
        self.city = city
        self.state = state
        self.company = company
        self.title = title
        self.website = website
        self.twitter = twitter
        self.facebook = facebook
        self.googlePlus = googlePlus
        self.github = github
        self.pinterest = pinterest
        self.instagram = instagram
        self.linkedIn = linkedIn
        self._auxiliaryId = auxiliaryId
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self._id, forKey: Keys.Id)
        aCoder.encode(self._headShot, forKey: Keys.HeadShot)
        aCoder.encode(self._displayHeadshot, forKey: Keys.DisplayHeadShot)
        
        aCoder.encode(self._firstName, forKey: Keys.FirstName)
        aCoder.encode(self._lastName, forKey: Keys.LastName)
        aCoder.encode(self._email, forKey: Keys.Email)
        aCoder.encode(self.publicEmail, forKey: Keys.PublicEmail)
        aCoder.encode(self.biography, forKey: Keys.Biography)
        aCoder.encode(self.phone, forKey: Keys.Phone)
        aCoder.encode(self.publicPhone, forKey: Keys.PublicPhone)
        aCoder.encode(self.publicThatSlackHandle, forKey: Keys.PublicThatSlackHandle)
        aCoder.encode(self.city, forKey: Keys.City)
        aCoder.encode(self.state, forKey: Keys.State)
        aCoder.encode(self.company, forKey: Keys.Company)
        aCoder.encode(self.title, forKey: Keys.Title)
        aCoder.encode(self.website, forKey: Keys.Website)
        aCoder.encode(self.twitter, forKey: Keys.Twitter)
        aCoder.encode(self.facebook, forKey: Keys.Facebook)
        aCoder.encode(self.googlePlus, forKey: Keys.GooglePlus)
        aCoder.encode(self.github, forKey: Keys.Github)
        aCoder.encode(self.pinterest, forKey: Keys.Pinterest)
        aCoder.encode(self.instagram, forKey: Keys.Instagram)
        aCoder.encode(self.linkedIn, forKey: Keys.LinkedIn)
        aCoder.encode(self._auxiliaryId, forKey: Keys.AuxiliaryId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        _id = aDecoder.decodeObject(forKey: Keys.Id) as! String
        _headShot = aDecoder.decodeObject(forKey: Keys.HeadShot) as? String
        _displayHeadshot = aDecoder.decodeObject(forKey: Keys.DisplayHeadShot) as? String
        
        _firstName = aDecoder.decodeObject(forKey: Keys.FirstName) as! String
        _lastName = aDecoder.decodeObject(forKey: Keys.LastName) as! String
        _email = aDecoder.decodeObject(forKey: Keys.Email) as! String
        publicEmail = aDecoder.decodeObject(forKey: Keys.PublicEmail) as? String
        biography = aDecoder.decodeObject(forKey: Keys.Biography) as? String
        phone = aDecoder.decodeObject(forKey: Keys.Phone) as? String
        publicPhone = aDecoder.decodeObject(forKey: Keys.PublicPhone) as? String
        publicThatSlackHandle = aDecoder.decodeObject(forKey: Keys.PublicThatSlackHandle) as? String
        city = aDecoder.decodeObject(forKey: Keys.City) as? String
        state = aDecoder.decodeObject(forKey: Keys.State) as? String
        company = aDecoder.decodeObject(forKey: Keys.Company) as? String
        title = aDecoder.decodeObject(forKey: Keys.Title) as? String
        website = aDecoder.decodeObject(forKey: Keys.Website) as? String
        twitter = aDecoder.decodeObject(forKey: Keys.Twitter) as? String
        facebook = aDecoder.decodeObject(forKey: Keys.Facebook) as? String
        googlePlus = aDecoder.decodeObject(forKey: Keys.GooglePlus) as? String
        github = aDecoder.decodeObject(forKey: Keys.Github) as? String
        pinterest = aDecoder.decodeObject(forKey: Keys.Pinterest) as? String
        instagram = aDecoder.decodeObject(forKey: Keys.Instagram) as? String
        linkedIn = aDecoder.decodeObject(forKey: Keys.LinkedIn) as? String
        _auxiliaryId = aDecoder.decodeObject(forKey: Keys.AuxiliaryId) as! UInt32
    }
    
    var id: String! {
        return _id
    }
    
    var firstName: String! {
        return _firstName
    }
    
    var lastName: String! {
        return _lastName
    }
    
    var email: String! {
        return _email
    }
    
    var fullName: String! {
        return "\(_firstName!) \(_lastName!)"
    }
    
    var headShot: String? {
        if (_headShot == nil) {
            return nil
        }
        
        return _headShot
    }
    
    var displayHeadShot: String? {
        if (_displayHeadshot == nil) {
            return nil
        }
        
        return _displayHeadshot
    }
    
    var publicPhoneString: String {
        if (publicPhone == nil) {
            return ""
        }
        return publicPhone!
    }
    
    var publicEmailString: String {
        if (publicEmail == nil) {
            return ""
        }
        return publicEmail!
    }
    
    var websiteString: String {
        if (website == nil) {
            return ""
        }
        return website!
    }
    
    var companyString: String {
        if (company == nil) {
            return ""
        }
        return company!
    }
    
    var titleString: String {
        if (title == nil) {
            return ""
        }
        return title!
    }
    
    var locationString: String {
        if (state == nil && city == nil) {
            return ""
        } else if (state == nil) {
            return city!
        } else if (city == nil) {
            return state!
        } else {
            return "\(city!), \(state!)"
        }
    }
    
    var slackHandleString: String {
        if (publicThatSlackHandle == nil) {
            return ""
        }
        return publicThatSlackHandle!
    }
    
    var biographyString: String {
        if (biography == nil) {
            return ""
        }
        return biography!
    }
    
    var auxiliaryId: UInt32! {
        return _auxiliaryId
    }
    
    var int16AAuxId: UInt16! {
        let a = UInt16(auxiliaryId >> 16)
        return a
    }
    
    var int16BAuxId: UInt16! {
        let b = UInt16(auxiliaryId & 0x00ffff)
        return b
    }
    
    var parameter: [String: AnyObject] {
        
        let params: [String: AnyObject] = [
            Keys.Id : _id as AnyObject,
            Keys.FirstName : _firstName as AnyObject,
            Keys.LastName : _lastName as AnyObject,
            Keys.Email : _email as AnyObject,
            Keys.HeadShot : headShot as AnyObject,
            Keys.DisplayHeadShot : displayHeadShot as AnyObject,
            Keys.PublicEmail : publicEmail as AnyObject,
            Keys.Biography : biography as AnyObject,
            Keys.Phone : phone as AnyObject,
            Keys.PublicPhone : publicPhone as AnyObject,
            Keys.PublicThatSlackHandle : publicThatSlackHandle as AnyObject,
            Keys.City : city as AnyObject,
            Keys.State : state as AnyObject,
            Keys.Company : company as AnyObject,
            Keys.Title : title as AnyObject,
            Keys.Website : website as AnyObject,
            Keys.Twitter : twitter as AnyObject,
            Keys.Facebook : facebook as AnyObject,
            Keys.GooglePlus : googlePlus as AnyObject,
            Keys.Github : github as AnyObject,
            Keys.Pinterest : pinterest as AnyObject,
            Keys.Instagram : instagram as AnyObject,
            Keys.LinkedIn : linkedIn as AnyObject,
            Keys.AuxiliaryId : auxiliaryId as AnyObject
        ]
        
        return params
    }
}
