import Foundation

class Speaker: NSObject {
    var firstName: String?
    var lastName: String?
    var headShotURL: NSURL!
    var userName: String?
    var biography: String?
    var website: NSURL!
    var company: String?
    var title: String?
    var twitter: String?
    var facebook: String?
    var googlePlus: String?
    var linkedIn: String?
    var gitHub: String?
    var lastUpdated: NSDate?
    
    override init() {}
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.firstName, forKey: "firstName")
        aCoder.encodeObject(self.lastName, forKey: "lastName")
        aCoder.encodeObject(self.headShotURL, forKey: "headShotURL")
        aCoder.encodeObject(self.userName, forKey: "userName")
        aCoder.encodeObject(self.biography, forKey: "biography")
        aCoder.encodeObject(self.website, forKey: "website")
        aCoder.encodeObject(self.company, forKey: "company")
        aCoder.encodeObject(self.title, forKey: "title")
        aCoder.encodeObject(self.twitter, forKey: "twitter")
        aCoder.encodeObject(self.facebook, forKey: "facebook")
        aCoder.encodeObject(self.googlePlus, forKey: "googlePlus")
        aCoder.encodeObject(self.linkedIn, forKey: "linkedIn")
        aCoder.encodeObject(self.gitHub, forKey: "gitHub")
        aCoder.encodeObject(self.lastUpdated, forKey: "lastUpdated")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let firstName = aDecoder.decodeObjectForKey("firstName") as? String
        let lastName = aDecoder.decodeObjectForKey("lastName") as? String
        let headShotURL = aDecoder.decodeObjectForKey("headShotURL") as! NSURL
        let userName = aDecoder.decodeObjectForKey("userName") as? String
        let biography = aDecoder.decodeObjectForKey("biography") as? String
        let website = aDecoder.decodeObjectForKey("website") as! NSURL
        let company = aDecoder.decodeObjectForKey("company") as? String
        let title = aDecoder.decodeObjectForKey("title") as? String
        let twitter = aDecoder.decodeObjectForKey("twitter") as? String
        let facebook = aDecoder.decodeObjectForKey("facebook") as? String
        let googlePlus = aDecoder.decodeObjectForKey("googlePlus") as? String
        let linkedIn = aDecoder.decodeObjectForKey("linkedIn") as? String
        let gitHub = aDecoder.decodeObjectForKey("gitHub") as? String
        let lastUpdated = aDecoder.decodeObjectForKey("lastUpdated") as? NSDate
        self.init(firstName: firstName,
                  lastName: lastName,
                  headShotURL: headShotURL,
                  userName: userName,
                  biography: biography,
                  website: website,
                  company: company,
                  title: title,
                  twitter: twitter,
                  facebook: facebook,
                  googlePlus: googlePlus,
                  linkedIn: linkedIn,
                  gitHub: gitHub,
                  lastUpdated: lastUpdated)
    }
    
    required init(firstName: String?,
                  lastName: String?,
                  headShotURL: NSURL,
                  userName: String?,
                  biography: String?,
                  website: NSURL,
                  company: String?,
                  title: String?,
                  twitter: String?,
                  facebook: String?,
                  googlePlus: String?,
                  linkedIn: String?,
                  gitHub: String?,
                  lastUpdated: NSDate?) {
        self.firstName = firstName
        self.lastName = lastName
        self.headShotURL = headShotURL
        self.userName = userName
        self.biography = biography
        self.website = website
        self.company = company
        self.title = title
        self.twitter = twitter
        self.facebook = facebook
        self.googlePlus = googlePlus
        self.linkedIn = linkedIn
        self.gitHub = gitHub
        self.lastUpdated = lastUpdated
    }
}