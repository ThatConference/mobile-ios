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
    @IBOutlet var SocialSharingView: UIView!
    
    var sponsor: Sponsor!
    
    func loadItem(loadedSponsor: Sponsor) {
        sponsor = loadedSponsor
        
        if let url = sponsor?.website
        {
            Website.setTitle(url, forState: .Normal)
        }
        
        if var sponsorImage = sponsor.imageUrl
        {
            sponsorImage = sponsorImage.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            if let url = NSURLComponents(string: sponsorImage) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    if let data = NSData(contentsOfURL: url.URL!) {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.LogoImage.image = UIImage(data: data)
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
        SocialTwitter.hidden = true
        SocialFacebook.hidden = true
        SocialGoogle.hidden = true
        SocialLinkedIn.hidden = true
        SocialGitHub.hidden = true
        
        if sponsor?.twitter != nil
        {
            hasOneButton = true
            SocialTwitter.hidden = false
        }
        if sponsor?.facebook != nil
        {
            hasOneButton = true
            SocialFacebook.hidden = false
        }
        if sponsor?.googlePlus != nil
        {
            hasOneButton = true
            SocialGoogle.hidden = false
        }
        if sponsor?.linkedIn != nil
        {
            hasOneButton = true
            SocialLinkedIn.hidden = false
        }
        if sponsor?.gitHub != nil
        {
            hasOneButton = true
            SocialGitHub.hidden = false
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
}