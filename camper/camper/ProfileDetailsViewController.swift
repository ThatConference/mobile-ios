//
//  ProfileDetailsViewController.swift
//  That Conference
//
//  Created by Steven Yang on 6/20/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit
import Firebase

class ProfileDetailsViewController: UIViewController {
    
    @IBOutlet weak var editAccountBarButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var publicPhoneLabel: UILabel!
    @IBOutlet weak var publicEmailLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    
    @IBOutlet weak var slackHandleStackView: UIStackView!
    @IBOutlet weak var slackHandleLabel: UILabel!
    
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
    
    var mainUser: User?
    var selectedContact: Contact?
    var activityIndicator: UIActivityIndicatorView!
    
    let requestRef = Database.database().reference().child("contact-sharing").child(StateData.instance.currentUser.id).child("requests")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator = UIActivityIndicatorView()
        self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        self.activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.4)
        self.activityIndicator.layer.cornerRadius = 10
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.activityIndicator.clipsToBounds = true
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
        
        currentUserSettings(isCurrentUser: ISCURRENTUSER)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        loadUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.title = "YOUR PROFILE"
        
        currentUserSettings(isCurrentUser: ISCURRENTUSER)
        loadUI()
    }
    
    // MARK: IBActions
    
    @IBAction func editProfileButtonPressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "toEditProfile", sender: nil)
    }
    
    @IBAction func addCommentButtonPressed(_ sender: RoundedButton) {
        let contactAPI = ContactAPI()
        
        if let contact = selectedContact {
            var commentText = ""
            if (sender.currentTitle == "Save Personal Comment") {
                if (commentTextView.text == "Comment" || commentTextView.text == "") {
                    
                    // Save Comment here
                    commentText = ""
                    contactAPI.putContact(sharedContactId: contact.sharecontactId!, commentText)
                } else {
                    
                    // Save Comment here
                    commentText = self.commentTextView.text
                    contactAPI.putContact(sharedContactId: contact.sharecontactId!, commentText)
                }
                
                self.commentTextViewStackView.isHidden = true
                self.checkComment(commentText)
            } else {
                self.commentLabel.isHidden = true
                self.commentTextViewStackView.isHidden = false
            }
            
            sender.setCommentTitle()
        }

    }
    
    @IBAction func editCommentButtonPressed(_ sender: UIButton) {
        
        editCommentButton.isHidden = true
        commentLabel.isHidden = true
        commentTextViewStackView.isHidden = false
        addCommentButton.isHidden = false
        addCommentButton.setCommentTitle()
    }
    
    @IBAction func twitterButtonPressed(_ sender: SocialUIButton) {
        if let url = mainUser?.twitter {
            UIApplication.shared.openURL(URL(string: "https://twitter.com/" + url)!)
        }
        
        if let url = selectedContact?.twitter {
            UIApplication.shared.openURL(URL(string: "https://twitter.com/" + url)!)
        }
    }
    
    @IBAction func facebookButtonPressed(_ sender: SocialUIButton) {
        if let url = mainUser?.facebook {
            UIApplication.shared.openURL(URL(string: url)!)
        }
        
        if let url = selectedContact?.facebook {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func googleButtonPressed(_ sender: SocialUIButton) {
        if let url = mainUser?.googlePlus {
            UIApplication.shared.openURL(URL(string: url)!)
        }
        
        if let url = selectedContact?.googlePlus {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func githubButtonPressed(_ sender: SocialUIButton) {
        if let url = mainUser?.github {
            UIApplication.shared.openURL(URL(string: url)!)
        }
        
        if let url = selectedContact?.github {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func pinterestButtonPressed(_ sender: SocialUIButton) {
        if let url = mainUser?.pinterest {
            UIApplication.shared.openURL(URL(string: url)!)
        }
        
        if let url = selectedContact?.pinterest {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func instagramButtonPressed(_ sender: SocialUIButton) {
        if let url = mainUser?.instagram {
            UIApplication.shared.openURL(URL(string: url)!)
        }
        
        if let url = selectedContact?.instagram {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func linkedInButtonPressed(_ sender: SocialUIButton) {
        if let url = mainUser?.linkedIn {
            UIApplication.shared.openURL(URL(string: url)!)
        }
        
        if let url = selectedContact?.linkedIn {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func websiteLabelPressed(_ sender: UITapGestureRecognizer) {
        if let url = mainUser?.website {
            UIApplication.shared.openURL(URL(string: url)!)
        }
        
        if let url = selectedContact?.website {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    // MARK: Functions
    
    func loadUI() {
        if let user = mainUser {
            self.navigationController?.title = "YOUR PROFILE"
            if let headshot = user.headShot {
                profileImageView.loadImageURL(url: URL(string: headshot))
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
            slackHandleLabel.text = user.slackHandleString
        }
        
        if let contact = selectedContact {
            self.navigationController?.title = "CAMPER PROFILE"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "details_icon"), style: .plain, target: self, action: #selector(settingsButtonTapped(_:)))
            if let headshot = contact.headShot {
                profileImageView.loadImageURL(url: URL(string: headshot))
            } else {
                profileImageView.image = UIImage(named: "speaker")
            }
            firstNameLabel.text = contact.firstName
            lastNameLabel.text = contact.lastName
            
            publicPhoneLabel.text = contact.publicPhoneString
            publicEmailLabel.text = contact.publicEmailString
            websiteLabel.text = contact.websiteString
            companyLabel.text = contact.companyString
            titleLabel.text = contact.titleString
            locationLabel.text = contact.locationString
            biographyLabel.text = contact.biography
            slackHandleLabel.text = contact.slackHandleString
        }
    }
    
    func settingsButtonTapped(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let call = UIAlertAction(title: "Call Contact", style: .default) { (UIAlertAction) in
            if let phone = self.selectedContact?.publicPhone {
                if let url = URL(string: "tel://\(phone)") {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        
        let exitOK = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        
        let deleteOK = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
            self.startIndicator()
            if let contact = self.selectedContact {
                let contactAPI = ContactAPI()
                contactAPI.deleteContact(shareContactId: contact.sharecontactId, completionHandler: { (result) in
                    switch (result) {
                    case .success():
                        self.stopIndicator()
                        let alert = UIAlertController(title: "Contact has been deleted", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(exitOK)
                        self.present(alert, animated: true, completion: nil)
                        break
                    case .failure(let error):
                        self.stopIndicator()
                        let alert = UIAlertController(title: "Unable to Delete Contact", message: "Please try again", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(exitOK)
                        self.present(alert, animated: true, completion: nil)
                        print("Error: \(error)")
                    }
                })
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let email = UIAlertAction(title: "Email Contact", style: .default) { (UIAlertAction) in
            if let email = self.selectedContact?.publicEmail {
                let url = URL(string: "mailto:\(email)")
                UIApplication.shared.openURL(url!)
            } else {
                let alert = UIAlertController(title: "Contact has not set a public email yet", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        let delete = UIAlertAction(title: "Delete Contact", style: .default) { (UIAlertAction) in
            let alert = UIAlertController(title: "Delete Contact?", message: "Are you sure you want to delete this contact?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(deleteOK)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        
        actionSheet.addAction(call)
        actionSheet.addAction(email)
        actionSheet.addAction(delete)
        actionSheet.addAction(cancel)
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
    }
    
    func filterViews() {
        if let user = mainUser {
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
            
            if (user.locationString == "") {
                locationLabel.isHidden = true
            } else {
                locationLabel.isHidden = false
            }
            
            if (user.publicPhoneString == "") {
                publicPhoneLabel.isHidden = true
            } else {
                publicPhoneLabel.isHidden = false
            }
            
            if (user.publicEmailString == "") {
                publicEmailLabel.isHidden = true
            } else {
                publicEmailLabel.isHidden = false
            }
            
            if (user.websiteString == "") {
                websiteLabel.isHidden = true
            } else {
                websiteLabel.isHidden = false
            }
            
            if (user.slackHandleString == "") {
                slackHandleStackView.isHidden = true
            } else {
                slackHandleStackView.isHidden = false
            }
            
            if (user.biographyString == "") {
                biographyLabel.isHidden = true
                biographyHeaderLabel.isHidden = true
            } else {
                biographyLabel.isHidden = false
                biographyHeaderLabel.isHidden = false
            }
        }
        
        if let contact = selectedContact {
            if (contact.twitter == nil && contact.facebook == nil && contact.googlePlus == nil && contact.github == nil && contact.pinterest == nil && contact.instagram == nil && contact.linkedIn == nil) {
                
                socialButtonsUIView.isHidden = true
                socialUIViewHeightConstraint.constant = 0
            } else {
                
                socialButtonsUIView.isHidden = false
                socialUIViewHeightConstraint.constant = 101
                
                if (contact.twitter == nil) {
                    self.twitterButtton.hideButton(true)
                } else {
                    self.twitterButtton.hideButton(false)
                }
                
                if (contact.facebook == nil) {
                    self.facebookButton.hideButton(true)
                } else {
                    self.facebookButton.hideButton(false)
                }
                
                if (contact.googlePlus == nil) {
                    self.googleButton.hideButton(true)
                } else {
                    self.googleButton.hideButton(false)
                }
                
                if (contact.github == nil) {
                    self.githubButton.hideButton(true)
                } else {
                    self.githubButton.hideButton(false)
                }
                
                if (contact.pinterest == nil) {
                    self.pinterestButton.hideButton(true)
                } else {
                    self.pinterestButton.hideButton(false)
                }
                
                if (contact.instagram == nil) {
                    self.instagramButton.hideButton(true)
                } else {
                    self.instagramButton.hideButton(false)
                }
                
                if (contact.linkedIn == nil) {
                    self.linkedInButton.hideButton(true)
                } else {
                    self.linkedInButton.hideButton(false)
                }
            }
            
            if (contact.locationString == "") {
                locationLabel.isHidden = true
            } else {
                locationLabel.isHidden = false
            }
            
            if (contact.publicPhoneString == "") {
                publicPhoneLabel.isHidden = true
            } else {
                publicPhoneLabel.isHidden = false
            }
            
            if (contact.publicEmailString == "") {
                publicEmailLabel.isHidden = true
            } else {
                publicEmailLabel.isHidden = false
            }
            
            if (contact.websiteString == "") {
                websiteLabel.isHidden = true
            } else {
                websiteLabel.isHidden = false
            }
            
            if (contact.slackHandleString == "") {
                slackHandleStackView.isHidden = true
            } else {
                slackHandleStackView.isHidden = false
            }
            
            if (contact.biographyString == "") {
                biographyLabel.isHidden = true
                biographyHeaderLabel.isHidden = true
            } else {
                biographyLabel.isHidden = false
                biographyHeaderLabel.isHidden = false
            }
        }
    }
    
    func checkComment(_ commentText: String? = nil) {
        // User comment
        if let contact = selectedContact {
            if (contact.memo == "" || contact.memo == nil) {
                commentLabel.isHidden = true
                editCommentButton.isHidden = true
                addCommentButton.isHidden = false
            } else {
                commentLabel.text = commentTextView.text
                commentLabel.isHidden = false
                editCommentButton.isHidden = false
                addCommentButton.isHidden = true
                if (commentText == nil) {
                    commentTextView.text = contact.memo
                } else {
                    commentTextView.text = commentText
                }
            }
        }
    }
    
    func currentUserSettings(isCurrentUser: Bool) {
        startIndicator()
        if (mainUser != nil) {
            commentHeaderLabel.isHidden = true
            commentTextViewStackView.isHidden = true
            editCommentButton.isHidden = true
            commentLabel.isHidden = true
            addCommentButton.isHidden = true
            filterViews()
            stopIndicator()
        } else {
            
            commentTextViewStackView.isHidden = true
            commentHeaderLabel.isHidden = false
            addCommentButton.isHidden = false
            filterViews()
            checkComment()
            stopIndicator()
        }
    }
    
    func startIndicator() {
        DispatchQueue.main.async(execute: {
            self.activityIndicator.startAnimating()
        })
    }
    
    func stopIndicator() {
        DispatchQueue.main.async(execute: {
            self.activityIndicator.stopAnimating()
        })
    }
}
