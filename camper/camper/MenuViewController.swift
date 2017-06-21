//
//  MenuViewController.swift
//  That Conference
//
//  Created by Steven Yang on 3/31/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = PersistenceManager.loadUser(Path.User) {
            StateData.instance.currentUser = user
            updateUI()
        }
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    func updateUI() {
        nameLabel.text = StateData.instance.currentUser.fullName
        if let headshot = StateData.instance.currentUser.headShot {
            profileImageView.loadImageURL(url: URL(string: headshot), cache: IMAGE_CACHE)
        } else {
            profileImageView.image = UIImage(named: "speaker")
        }
    }
    
    @IBAction func nameLabelPressed(_ sender: UITapGestureRecognizer) {
            if (Authentication.isLoggedIn()) {
                performSegue(withIdentifier: "toProfileDetails", sender: nil)
            } else {
                performSegue(withIdentifier: "show_login", sender: self)
            }
    }
    
    
    @IBAction func shareContactButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func unwindToMainVC(segue:UIStoryboardSegue) { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? FavoritesViewController {
            if segue.identifier == "favoriteSegue" {
                print("Prepare for segue")
                destination.store = StateData.instance.sessionStore
            }
        }
    }


}
