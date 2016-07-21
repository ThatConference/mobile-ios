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
    
    func loadItem(loadedSponsor: Sponsor) {
        sponsor = loadedSponsor
        
        if let url = sponsor?.website
        {
            Website.setTitle(url, forState: .Normal)
        }
        
        self.LogoImage.image = UIImage(named: "blank")
        if var sponsorImage = sponsor.imageUrl
        {
            sponsorImage = sponsorImage.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            if let url = NSURLComponents(string: sponsorImage) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    if let data = NSData(contentsOfURL: url.URL!) {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.LogoImage.image = UIImage(data: data)
                            self.LogoImage.clipsToBounds = true
                        });
                    }
                }
            }
        } else {
            self.LogoImage.hidden = true
        }
        
        SponsorName.text = sponsor.name
        setSocialButtons()
    }

    private func setSocialButtons() {
        var hasOneButton = false
        
        if sponsor?.twitter != nil
        {
            hasOneButton = true
            SocialTwitter.hidden = false
        } else {
            SocialTwitter.hidden = true
        }
        
        if sponsor?.facebook != nil
        {
            hasOneButton = true
            SocialFacebook.hidden = false
        } else {
            SocialFacebook.hidden = true
        }
        
        if sponsor?.googlePlus != nil
        {
            hasOneButton = true
            SocialGoogle.hidden = false
        } else {
            SocialGoogle.hidden = true
        }
        
        if sponsor?.linkedIn != nil
        {
            hasOneButton = true
            SocialLinkedIn.hidden = false
        } else {
            SocialLinkedIn.hidden = true
        }
        
        if sponsor?.gitHub != nil
        {
            hasOneButton = true
            SocialGitHub.hidden = false
        } else {
            SocialGitHub.hidden = true
        }
        
        if sponsor?.instagram != nil
        {
            hasOneButton = true
            SocialInstagram.hidden = false
        } else {
            SocialInstagram.hidden = true
        }
        
        if sponsor?.pinterest != nil
        {
            hasOneButton = true
            SocialPinterest.hidden = false
        } else {
            SocialPinterest.hidden = true
        }
        
        if sponsor?.youTube != nil
        {
            hasOneButton = true
            SocialYouTube.hidden = false
        } else {
            SocialYouTube.hidden = true
        }
        
        SocialSharingView.hidden = !hasOneButton
    }
    
    @IBAction func WebsitePressed(sender: AnyObject) {
        if let url = sponsor?.website
        {
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
    
    @IBAction func TwitterPressed(sender: AnyObject) {
        if let url = sponsor?.twitter
        {
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
    
    @IBAction func FacebookPressed(sender: AnyObject) {
        if let url = sponsor?.facebook
        {
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
    
    @IBAction func GooglePressed(sender: AnyObject) {
        if let url = sponsor?.googlePlus
        {
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
    
    @IBAction func LinkedInPressed(sender: AnyObject) {
        if let url = sponsor?.linkedIn
        {
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
    
    @IBAction func GitHubPressed(sender: AnyObject) {
        if let url = sponsor?.gitHub
        {
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
    
    @IBAction func InstagramPressed(sender: AnyObject) {
        if let url = sponsor?.instagram
        {
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
    
    @IBAction func PinterestPressed(sender: AnyObject) {
        if let url = sponsor?.pinterest
        {
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
    
    @IBAction func YouTubePressed(sender: AnyObject) {
        if let url = sponsor?.youTube
        {
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
}