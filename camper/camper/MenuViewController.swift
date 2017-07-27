//
//  MenuViewController.swift
//  That Conference
//
//  Created by Steven Yang on 3/31/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: BorderImageView!
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    
    @IBAction func nameLabelPressed(_ sender: UITapGestureRecognizer) {
        if (Authentication.isLoggedIn()) {
            ISCURRENTUSER = true
            performSegue(withIdentifier: "toProfileDetails", sender: self)
        } else {
            
            let alert = UIAlertController(title: "Log In Needed", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                self.performSegue(withIdentifier: "show_login", sender: self)
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(ok)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func shareContactButtonPressed(_ sender: Any) {
        checkIfSignedIn("toShareContact")
    }
    
    @IBAction func unwindToMainVC(segue:UIStoryboardSegue) { }
    
    func updateUI() {
        nameLabel.text = StateData.instance.currentUser.fullName
        if let headshot = StateData.instance.currentUser.headShot {
            profileImageView.loadImageURL(url: URL(string: headshot))
        } else {
            profileImageView.image = UIImage(named: "speaker")
        }
    }
    
    func checkIfSignedIn(_ segueIdentifier: String) {
        if (Authentication.isLoggedIn()) {
            
            performSegue(withIdentifier: segueIdentifier, sender: self)
        } else {
            
            let alert = UIAlertController(title: "Log In Needed", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                self.performSegue(withIdentifier: "show_login", sender: self)
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(ok)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? FavoritesViewController {
            if segue.identifier == "favoriteSegue" {
                print("Prepare for segue")
                destination.store = StateData.instance.sessionStore
            }
        }
        
        if let destination = segue.destination as? UINavigationController {
            if (segue.identifier == "toProfileDetails") {
                let vc = destination.viewControllers.first as? ProfileDetailsViewController
                vc?.mainUser = StateData.instance.currentUser
            }
        }
    }

}
