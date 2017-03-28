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
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "Name")
        aCoder.encode(self.sponsorLevel, forKey: "SponsorLevel")
        aCoder.encode(self.levelOrder, forKey: "LevelOrder")
        aCoder.encode(self.imageUrl, forKey: "ImageUrl")
        aCoder.encode(self.website, forKey: "Website")
        aCoder.encode(self.twitter, forKey: "Twitter")
        aCoder.encode(self.facebook, forKey: "Facebook")
        aCoder.encode(self.googlePlus, forKey: "GooglePlus")
        aCoder.encode(self.linkedIn, forKey: "LinkedIn")
        aCoder.encode(self.gitHub, forKey: "GitHub")
        aCoder.encode(self.pinterest, forKey: "Pinterest")
        aCoder.encode(self.instagram, forKey: "Instagram")
        aCoder.encode(self.youTube, forKey: "YouTube")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "Name") as! String
        let sponsorLevel = aDecoder.decodeObject(forKey: "SponsorLevel") as! String
        let levelOrder = aDecoder.decodeObject(forKey: "LevelOrder") as! Int
        let imageUrl = aDecoder.decodeObject(forKey: "ImageUrl") as! String
        let website = aDecoder.decodeObject(forKey: "Website") as! String
        let twitter = aDecoder.decodeObject(forKey: "Twitter") as! String
        let facebook = aDecoder.decodeObject(forKey: "Facebook") as! String
        let googlePlus = aDecoder.decodeObject(forKey: "GooglePlus") as! String
        let linkedIn = aDecoder.decodeObject(forKey: "LinkedIn") as! String
        let gitHub = aDecoder.decodeObject(forKey: "GitHub") as! String
        let pinterest = aDecoder.decodeObject(forKey: "Pinterest") as! String
        let instagram = aDecoder.decodeObject(forKey: "Instagram") as! String
        let youTube = aDecoder.decodeObject(forKey: "YouTube") as! String
        
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
