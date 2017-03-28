import Foundation

class Speaker: NSObject {
    var firstName: String?
    var lastName: String?
    var headShotURL: URL!
    var userName: String?
    var biography: String?
    var website: URL!
    var company: String?
    var title: String?
    var twitter: String?
    var facebook: String?
    var googlePlus: String?
    var linkedIn: String?
    var gitHub: String?
    var lastUpdated: Date?
    
    override init() {}
    
    func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(self.firstName, forKey: "firstName")
        aCoder.encode(self.lastName, forKey: "lastName")
        aCoder.encode(self.headShotURL, forKey: "headShotURL")
        aCoder.encode(self.userName, forKey: "userName")
        aCoder.encode(self.biography, forKey: "biography")
        aCoder.encode(self.website, forKey: "website")
        aCoder.encode(self.company, forKey: "company")
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.twitter, forKey: "twitter")
        aCoder.encode(self.facebook, forKey: "facebook")
        aCoder.encode(self.googlePlus, forKey: "googlePlus")
        aCoder.encode(self.linkedIn, forKey: "linkedIn")
        aCoder.encode(self.gitHub, forKey: "gitHub")
        aCoder.encode(self.lastUpdated, forKey: "lastUpdated")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let firstName = aDecoder.decodeObject(forKey: "firstName") as? String
        let lastName = aDecoder.decodeObject(forKey: "lastName") as? String
        let headShotURL = aDecoder.decodeObject(forKey: "headShotURL") as! URL
        let userName = aDecoder.decodeObject(forKey: "userName") as? String
        let biography = aDecoder.decodeObject(forKey: "biography") as? String
        let website = aDecoder.decodeObject(forKey: "website") as? URL
        let company = aDecoder.decodeObject(forKey: "company") as? String
        let title = aDecoder.decodeObject(forKey: "title") as? String
        let twitter = aDecoder.decodeObject(forKey: "twitter") as? String
        let facebook = aDecoder.decodeObject(forKey: "facebook") as? String
        let googlePlus = aDecoder.decodeObject(forKey: "googlePlus") as? String
        let linkedIn = aDecoder.decodeObject(forKey: "linkedIn") as? String
        let gitHub = aDecoder.decodeObject(forKey: "gitHub") as? String
        let lastUpdated = aDecoder.decodeObject(forKey: "lastUpdated") as? Date
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
                  headShotURL: URL,
                  userName: String?,
                  biography: String?,
                  website: URL?,
                  company: String?,
                  title: String?,
                  twitter: String?,
                  facebook: String?,
                  googlePlus: String?,
                  linkedIn: String?,
                  gitHub: String?,
                  lastUpdated: Date?) {
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
