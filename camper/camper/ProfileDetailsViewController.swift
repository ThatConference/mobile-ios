//
//  ProfileDetailsViewController.swift
//  That Conference
//
//  Created by Steven Yang on 6/20/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class ProfileDetailsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func editProfileButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "toEditProfile", sender: nil)
    }
    
}
