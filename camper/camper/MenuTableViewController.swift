//
//  MenuTableViewController.swift
//  That Conference
//
//  Created by Steven Yang on 3/31/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    @IBOutlet weak var logOffImage: UIImageView!
    @IBOutlet weak var logOffLabel: UILabel!
    @IBOutlet weak var logOffCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSignInButton()
    }
    
    func setDirtyData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.dirtyDataSchedule = true;
        appDelegate.dirtyDataFavorites = true;
    }
    
    func setSignInButton() {
        if (Authentication.isLoggedIn()) {
            logOffLabel.text = "Sign Out"
            logOffImage.image = UIImage(named: "logout_icon")
        } else {
            logOffLabel.text = "Sign In"
            logOffImage.image = UIImage(named: "login_icon")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Favorites
        if indexPath.row == 3 {
            checkIfSignedIn("toFavorites")
        }
        
        if indexPath.row == 4 {
            checkIfSignedIn("toCamperContacts")
        }
        
        // Log in/Log Out
        if indexPath.row == 9 {
            if (Authentication.isLoggedIn()) {
                Authentication.removeAuthToken()
                setDirtyData()
                _ = PersistenceManager.deleteDailySchedule(Path.Favorites)
                
                PersistenceManager.saveUser(User(), path: Path.User)
                StateData.instance.currentUser = User()
                let alert = UIAlertController(title: "Signed Out", message: "Sign out was successful. You can now sign in with a different account or continue as a guest.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                performSegue(withIdentifier: "show_login", sender: self)
            }
            
            if let parent = self.parent as? MenuViewController {
                parent.updateUI()
            }
            
            setSignInButton()
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
}
