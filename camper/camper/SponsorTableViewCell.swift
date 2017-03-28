import UIKit

class SponsorTableViewCell: UITableViewCell {
    @IBOutlet var LogoImage: UIImageView!
    @IBOutlet var SponsorName: UILabel!
    @IBOutlet var Website: UIButton!
    @IBOutlet var SocialTwitter: UIButton!
    @IBOutlet var SocialFacebook: UIButton!
    @IBOutlet var SocialGoogle: UIButton!
    @IBOutlet var SocialLinkedIn: UIButton!
    @IBOutlet var SocialGitHub: UIButton!
    @IBOutlet var SocialInstagram: UIButton!
    @IBOutlet var SocialPinterest: UIButton!
    @IBOutlet var SocialYouTube: UIButton!
    @IBOutlet var SocialSharingView: UIView!
    
    var sponsor: Sponsor!
    
    func loadItem(_ loadedSponsor: Sponsor) {
        sponsor = loadedSponsor
        
        if let url = sponsor?.website
        {
            Website.setTitle(url, for: UIControlState())
        }
        
        self.LogoImage.image = UIImage(named: "blank")
        if var sponsorImage = sponsor.imageUrl
        {
            sponsorImage = sponsorImage.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            if let url = URLComponents(string: sponsorImage) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url.url!) {
                        DispatchQueue.main.async(execute: {
                            self.LogoImage.image = UIImage(data: data)
                            self.LogoImage.clipsToBounds = true
                        });
                    }
                }
            }
        } else {
            self.LogoImage.isHidden = true
        }
        
        SponsorName.text = sponsor.name
        setSocialButtons()
    }

    fileprivate func setSocialButtons() {
        var hasOneButton = false
        
        if sponsor?.twitter != nil
        {
            hasOneButton = true
            SocialTwitter.isHidden = false
        } else {
            SocialTwitter.isHidden = true
        }
        
        if sponsor?.facebook != nil
        {
            hasOneButton = true
            SocialFacebook.isHidden = false
        } else {
            SocialFacebook.isHidden = true
        }
        
        if sponsor?.googlePlus != nil
        {
            hasOneButton = true
            SocialGoogle.isHidden = false
        } else {
            SocialGoogle.isHidden = true
        }
        
        if sponsor?.linkedIn != nil
        {
            hasOneButton = true
            SocialLinkedIn.isHidden = false
        } else {
            SocialLinkedIn.isHidden = true
        }
        
        if sponsor?.gitHub != nil
        {
            hasOneButton = true
            SocialGitHub.isHidden = false
        } else {
            SocialGitHub.isHidden = true
        }
        
        if sponsor?.instagram != nil
        {
            hasOneButton = true
            SocialInstagram.isHidden = false
        } else {
            SocialInstagram.isHidden = true
        }
        
        if sponsor?.pinterest != nil
        {
            hasOneButton = true
            SocialPinterest.isHidden = false
        } else {
            SocialPinterest.isHidden = true
        }
        
        if sponsor?.youTube != nil
        {
            hasOneButton = true
            SocialYouTube.isHidden = false
        } else {
            SocialYouTube.isHidden = true
        }
        
        SocialSharingView.isHidden = !hasOneButton
    }
    
    @IBAction func WebsitePressed(_ sender: AnyObject) {
        if let url = sponsor?.website
        {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func TwitterPressed(_ sender: AnyObject) {
        if let url = sponsor?.twitter
        {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func FacebookPressed(_ sender: AnyObject) {
        if let url = sponsor?.facebook
        {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func GooglePressed(_ sender: AnyObject) {
        if let url = sponsor?.googlePlus
        {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func LinkedInPressed(_ sender: AnyObject) {
        if let url = sponsor?.linkedIn
        {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func GitHubPressed(_ sender: AnyObject) {
        if let url = sponsor?.gitHub
        {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func InstagramPressed(_ sender: AnyObject) {
        if let url = sponsor?.instagram
        {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func PinterestPressed(_ sender: AnyObject) {
        if let url = sponsor?.pinterest
        {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func YouTubePressed(_ sender: AnyObject) {
        if let url = sponsor?.youTube
        {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
}
