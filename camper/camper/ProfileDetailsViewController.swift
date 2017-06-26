//
//  ProfileDetailsViewController.swift
//  That Conference
//
//  Created by Steven Yang on 6/20/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class ProfileDetailsViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var publicPhoneLabel: UILabel!
    @IBOutlet weak var publicEmailLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    
    @IBOutlet weak var biographyHeaderLabel: UILabel!
    @IBOutlet weak var biographyLabel: UILabel!
    
    @IBOutlet weak var socialButtonsUIView: ProfileDetailUIView!
    @IBOutlet weak var socialUIViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var twitterButtton: SocialUIButton!
    @IBOutlet weak var facebookButton: SocialUIButton!
    @IBOutlet weak var googleButton: SocialUIButton!
    @IBOutlet weak var githubButton: SocialUIButton!
    @IBOutlet weak var pinterestButton: SocialUIButton!
    @IBOutlet weak var instagramButton: SocialUIButton!
    @IBOutlet weak var linkedInButton: SocialUIButton!
    
    // Comment Section
    
    @IBOutlet weak var editCommentButton: UIButton!
    @IBOutlet weak var commentSectionUIView: UIView!
    @IBOutlet weak var commentHeaderLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentTextView: CommentUITextView!
    @IBOutlet weak var commentTextViewStackView: UIStackView!
    @IBOutlet weak var addCommentButton: RoundedButton!
    
    var user: User!
    var covfefe = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUserSettings(isCurrentUser: ISCURRENTUSER)
        loadUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.title = "Your Profile"
        
        currentUserSettings(isCurrentUser: ISCURRENTUSER)
        loadUI()
        
    }
    
    // MARK: IBActions
    
    @IBAction func editProfileButtonPressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "toEditProfile", sender: nil)
    }
    
    @IBAction func addCommentButtonPressed(_ sender: RoundedButton) {
            if (sender.currentTitle == "Save Personal Comment") {
                if (commentTextView.text == "Comment") {
                    self.covfefe = ""
                } else {
                    self.covfefe = self.commentTextView.text
                }
                
                self.commentTextViewStackView.isHidden = true
                self.checkComment()
            } else {
                self.commentLabel.isHidden = true
                self.commentTextViewStackView.isHidden = false
            }
        
        sender.setCommentTitle()
    }
    
    @IBAction func editCommentButtonPressed(_ sender: UIButton) {
        
        editCommentButton.isHidden = true
        commentLabel.isHidden = true
        commentTextViewStackView.isHidden = false
        addCommentButton.isHidden = false
        addCommentButton.setCommentTitle()
    }
    
    @IBAction func twitterButtonPressed(_ sender: SocialUIButton) {
        if let url = user.twitter {
            UIApplication.shared.openURL(URL(string: "https://twitter.com/" + url)!)
        }
    }
    
    @IBAction func facebookButtonPressed(_ sender: SocialUIButton) {
        if let url = user.facebook {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func googleButtonPressed(_ sender: SocialUIButton) {
        if let url = user.googlePlus {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func githubButtonPressed(_ sender: SocialUIButton) {
        if let url = user.github {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func pinterestButtonPressed(_ sender: SocialUIButton) {
        if let url = user.pinterest {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func instagramButtonPressed(_ sender: SocialUIButton) {
        if let url = user.instagram {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func linkedInButtonPressed(_ sender: SocialUIButton) {
        if let url = user.linkedIn {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func websiteLabelPressed(_ sender: UITapGestureRecognizer) {
        if let url = user.website {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    // MARK: Functions
    
    func loadUI() {
        if let headshot = user.headShot {
            profileImageView.loadImageURL(url: URL(string: headshot), cache: IMAGE_CACHE)
        } else {
            profileImageView.image = UIImage(named: "speaker")
        }
        firstNameLabel.text = user.firstName
        lastNameLabel.text = user.lastName
        
        publicPhoneLabel.text = user.publicPhoneString
        publicEmailLabel.text = user.publicEmailString
        websiteLabel.text = user.websiteString
        companyLabel.text = user.companyString
        titleLabel.text = user.titleString
        locationLabel.text = user.locationString
        biographyLabel.text = user.biography
    }
    
    
    func filterViews() {
        
        if (user.twitter == nil && user.facebook == nil && user.googlePlus == nil && user.github == nil && user.pinterest == nil && user.instagram == nil && user.linkedIn == nil) {
            
            socialButtonsUIView.isHidden = true
            socialUIViewHeightConstraint.constant = 0
        } else {
            
            socialButtonsUIView.isHidden = false
            socialUIViewHeightConstraint.constant = 101
            
            if (user.twitter == nil) {
                self.twitterButtton.hideButton(true)
            } else {
                self.twitterButtton.hideButton(false)
            }
            
            if (user.facebook == nil) {
                self.facebookButton.hideButton(true)
            } else {
                self.facebookButton.hideButton(false)
            }
            
            if (user.googlePlus == nil) {
                self.googleButton.hideButton(true)
            } else {
                self.googleButton.hideButton(false)
            }
            
            if (user.github == nil) {
                self.githubButton.hideButton(true)
            } else {
                self.githubButton.hideButton(false)
            }
            
            if (user.pinterest == nil) {
                self.pinterestButton.hideButton(true)
            } else {
                self.pinterestButton.hideButton(false)
            }
            
            if (user.instagram == nil) {
                self.instagramButton.hideButton(true)
            } else {
                self.instagramButton.hideButton(false)
            }
            
            if (user.linkedIn == nil) {
                self.linkedInButton.hideButton(true)
            } else {
                self.linkedInButton.hideButton(false)
            }
        }
        
        if (user.biographyString == "") {
            biographyLabel.isHidden = true
            biographyHeaderLabel.isHidden = true
        } else {
            biographyLabel.isHidden = false
            biographyHeaderLabel.isHidden = false
        }
    }
    
    func checkComment() {
        // User comment
        if (covfefe == "") {
            commentLabel.isHidden = true
            editCommentButton.isHidden = true
            addCommentButton.isHidden = false
        } else {
            commentLabel.text = commentTextView.text
            commentLabel.isHidden = false
            editCommentButton.isHidden = false
            addCommentButton.isHidden = true
            commentTextView.text = covfefe
        }
    }
    
    func currentUserSettings(isCurrentUser: Bool) {
        if (isCurrentUser) {
            user = StateData.instance.currentUser
            commentHeaderLabel.isHidden = true
            commentTextViewStackView.isHidden = true
            editCommentButton.isHidden = true
            commentLabel.isHidden = true
            addCommentButton.isHidden = true
            filterViews()
        } else {
            
            // Erase
            user = StateData.instance.currentUser
            
            commentTextViewStackView.isHidden = true
            commentHeaderLabel.isHidden = false
            addCommentButton.isHidden = false
            filterViews()
            checkComment()
        }
    }
    
}
