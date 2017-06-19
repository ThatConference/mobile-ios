//
//  EditProfileViewController.swift
//  That Conference
//
//  Created by Steven Yang on 6/16/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: ProfileTextField!
    @IBOutlet weak var lastNameTextField: ProfileTextField!
    @IBOutlet weak var emailTextField: ProfileTextField!
    @IBOutlet weak var phoneTextField: ProfileTextField!
    @IBOutlet weak var cityTextField: ProfileTextField!
    @IBOutlet weak var stateTextField: ProfileTextField!
    @IBOutlet weak var companyTextField: ProfileTextField!
    @IBOutlet weak var titleTextField: ProfileTextField!
    @IBOutlet weak var websiteTextField: ProfileTextField!
    @IBOutlet weak var twitterTextField: ProfileTextField!
    @IBOutlet weak var facebookTextField: ProfileTextField!
    @IBOutlet weak var googleTextField: ProfileTextField!
    @IBOutlet weak var githubTextField: ProfileTextField!
    @IBOutlet weak var pinterestTextField: ProfileTextField!
    @IBOutlet weak var instagramTextField: ProfileTextField!
    @IBOutlet weak var linkedinTextField: ProfileTextField!
    
    @IBOutlet weak var biographyTextView: BiographyTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "unwindToMainVC", sender: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
    }

}
