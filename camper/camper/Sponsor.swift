import Foundation

class Sponsor : NSObject, NSCoding {
    var name: String?
    var sponsorLevel: String?
    var levelOrder: Int?
    var imageUrl: String?
    var website: String?
    var twitter: String?
    var facebook: String?
    var googlePlus: String?
    var linkedIn: String?
    var gitHub: String?
    var pinterest: String?
    var instagram: String?
    var youTube: String?
    
    override init() {}
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: "Name")
        aCoder.encodeObject(self.sponsorLevel, forKey: "SponsorLevel")
        aCoder.encodeObject(self.levelOrder, forKey: "LevelOrder")
        aCoder.encodeObject(self.imageUrl, forKey: "ImageUrl")
        aCoder.encodeObject(self.website, forKey: "Website")
        aCoder.encodeObject(self.twitter, forKey: "Twitter")
        aCoder.encodeObject(self.facebook, forKey: "Facebook")
        aCoder.encodeObject(self.googlePlus, forKey: "GooglePlus")
        aCoder.encodeObject(self.linkedIn, forKey: "LinkedIn")
        aCoder.encodeObject(self.gitHub, forKey: "GitHub")
        aCoder.encodeObject(self.pinterest, forKey: "Pinterest")
        aCoder.encodeObject(self.instagram, forKey: "Instagram")
        aCoder.encodeObject(self.youTube, forKey: "YouTube")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey("Name") as! String
        let sponsorLevel = aDecoder.decodeObjectForKey("SponsorLevel") as! String
        let levelOrder = aDecoder.decodeObjectForKey("LevelOrder") as! Int
        let imageUrl = aDecoder.decodeObjectForKey("ImageUrl") as! String
        let website = aDecoder.decodeObjectForKey("Website") as! String
        let twitter = aDecoder.decodeObjectForKey("Twitter") as! String
        let facebook = aDecoder.decodeObjectForKey("Facebook") as! String
        let googlePlus = aDecoder.decodeObjectForKey("GooglePlus") as! String
        let linkedIn = aDecoder.decodeObjectForKey("LinkedIn") as! String
        let gitHub = aDecoder.decodeObjectForKey("GitHub") as! String
        let pinterest = aDecoder.decodeObjectForKey("Pinterest") as! String
        let instagram = aDecoder.decodeObjectForKey("Instagram") as! String
        let youTube = aDecoder.decodeObjectForKey("YouTube") as! String
        
        self.init(name: name,
                  sponsorLevel: sponsorLevel,
                  levelOrder: levelOrder,
                  imageUrl: imageUrl,
                  website: website,
                  twitter: twitter,
                  facebook: facebook,
                  googlePlus: googlePlus,
                  linkedIn: linkedIn,
                  gitHub: gitHub,
                  pinterest: pinterest,
                  instagram: instagram,
                  youTube: youTube)
    }
    
    required init(name: String,
                  sponsorLevel: String,
                  levelOrder: Int,
                  imageUrl: String,
                  website: String,
                  twitter: String,
                  facebook: String,
                  googlePlus: String,
                  linkedIn: String,
                  gitHub: String,
                  pinterest: String,
                  instagram: String,
                  youTube: String) {
        self.name = name
        self.sponsorLevel = sponsorLevel
        self.levelOrder = levelOrder
        self.imageUrl = imageUrl
        self.website = website
        self.twitter = twitter
        self.facebook = facebook
        self.googlePlus = googlePlus
        self.linkedIn = linkedIn
        self.gitHub = gitHub
        self.pinterest = pinterest
        self.instagram = instagram
        self.youTube = youTube
    }
}