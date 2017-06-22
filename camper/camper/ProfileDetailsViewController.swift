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
    @IBOutlet weak var publicPhoneLabel: UILabel!
    @IBOutlet weak var publicEmailLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var biographyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadUI()
        // Do any additional setup after loading the view.
    }
    
    // MARK: IBActions
    
    @IBAction func editProfileButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "toEditProfile", sender: nil)
    }
    
    // MARK: Functions
    
    func loadUI() {
        let user = StateData.instance.currentUser
        
        if let headshot = user.headShot {
            profileImageView.loadImageURL(url: URL(string: headshot), cache: IMAGE_CACHE)
        } else {
            profileImageView.image = UIImage(named: "speaker")
        }
        publicPhoneLabel.text = user.publicPhoneString
        publicEmailLabel.text = user.publicEmailString
        websiteLabel.text = user.websiteString
        companyLabel.text = user.companyString
        titleLabel.text = user.titleString
        locationLabel.text = user.locationString
        biographyLabel.text = user.biography
    }
    
}
