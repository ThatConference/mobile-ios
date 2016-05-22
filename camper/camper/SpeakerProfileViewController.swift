//
//  SpeakerProfileViewController.swift
//  That Conference
//
//  Created by Matthew Ridley on 4/27/16.
//  Copyright © 2016 That Conference. All rights reserved.
//

import UIKit

class SpeakerProfileViewController : UIViewController {
    var speaker: Speaker!
    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var speakerName: UILabel!
    @IBOutlet var jobTitle: UILabel!
    @IBOutlet var company: UILabel!
    @IBOutlet var biography: UITextView!
    @IBOutlet var website: UIButton!
    
    @IBOutlet var twitterButton: UIButton!
    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var googleButton: UIButton!
    @IBOutlet var linkedInButton: UIButton!
    @IBOutlet var gitHubButton: UIButton!
    
    @IBAction func websiteButton(sender: AnyObject) {
        if let url = speaker.website
        {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func twitterButton(sender: AnyObject) {
        if let url = speaker.twitter
        {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://twitter.com/" + url)!)
        }
    }
    
    @IBAction func facebookButton(sender: AnyObject) {
        if let url = speaker.facebook
        {
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
    
    @IBAction func googleButton(sender: AnyObject) {
        if let url = speaker.googlePlus
        {
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
    
    @IBAction func linkedinButton(sender: AnyObject) {
        if let url = speaker.linkedIn
        {
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
    
    @IBAction func githubButton(sender: AnyObject) {
        if let url = speaker.gitHub
        {
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        if let headshot = speaker.headShotURL
        {
            let url = ThatConferenceAPI.resourceURL(headshot.absoluteString)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let data = NSData(contentsOfURL: url) //make sure your image in this url does exist, otherwise unwrap in a if let check
                dispatch_async(dispatch_get_main_queue(), {
                    self.profileImage.image = UIImage(data: data!)
                });
            }
        }
    
        speakerName.text = "\(speaker.firstName) \(speaker.lastName)"
        jobTitle.text = speaker.title
        company.text = speaker.company
        
        website.titleLabel?.text = ""
        if let speakerWebsite = speaker.website
        {
            website.setTitle(speakerWebsite.absoluteString, forState: UIControlState.Normal)
        }
        
        if let bioText = speaker.biography
        {
            biography.text = bioText
            biography.scrollRangeToVisible(NSRange(location: 0, length: 0))
        }
        
        setSocialButtons()
    }
    
    private func setSocialButtons() {
        if speaker.twitter == nil
        {
            twitterButton.hidden = true
        }
        if speaker.facebook == nil
        {
            facebookButton.hidden = true
        }
        if speaker.googlePlus == nil
        {
            googleButton.hidden = true
        }
        if speaker.linkedIn == nil
        {
            linkedInButton.hidden = true
        }
        if speaker.gitHub == nil
        {
            gitHubButton.hidden = true
        }
    }
}