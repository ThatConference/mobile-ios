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
    }
    
    private var _id: String!
    private var _headShot: String?
    private var _displayHeadshot: String?
    
    private var _firstName: String!
    private var _lastName: String!
    private var _email: String!
    
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
    var pinterest: String?
    var instagram: String?
    var linkedIn: String?
    
    override init() {
        _firstName = "Guest"
        _lastName = ""
        _email = ""
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
        pinterest = dictionary[Keys.Pinterest] as? String
        instagram = dictionary[Keys.Instagram] as? String
        linkedIn = dictionary[Keys.LinkedIn] as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self._id, forKey: Keys.Id)
        aCoder.encode(self._headShot, forKey: Keys.Id)
        aCoder.encode(self._displayHeadshot, forKey: Keys.Id)
        
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
        aCoder.encode(self.pinterest, forKey: Keys.Pinterest)
        aCoder.encode(self.instagram, forKey: Keys.Instagram)
        aCoder.encode(self.linkedIn, forKey: Keys.LinkedIn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        _id = aDecoder.decodeObject(forKey: Keys.Id) as! String
        _headShot = aDecoder.decodeObject(forKey: Keys.Id) as? String
        _displayHeadshot = aDecoder.decodeObject(forKey: Keys.Id) as? String

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
        pinterest = aDecoder.decodeObject(forKey: Keys.Pinterest) as? String
        instagram = aDecoder.decodeObject(forKey: Keys.Instagram) as? String
        linkedIn = aDecoder.decodeObject(forKey: Keys.LinkedIn) as? String
    }
    
    var fullName: String {
        return "\(_firstName!) \(_lastName!)"
    }
    
    
    var parameter: [String: AnyObject?] {
        
        let params: [String: AnyObject?] = [
            Keys.Id : _id as AnyObject,
            Keys.HeadShot : _headShot as AnyObject,
            Keys.DisplayHeadShot : _displayHeadshot as AnyObject,
            Keys.FirstName : _firstName as AnyObject,
            Keys.LastName : _lastName as AnyObject,
            Keys.Email : _email as AnyObject,
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
            Keys.Pinterest : pinterest as AnyObject,
            Keys.Instagram : instagram as AnyObject,
            Keys.LinkedIn : linkedIn as AnyObject
        ]
        
        return params
    }
    
    
}
