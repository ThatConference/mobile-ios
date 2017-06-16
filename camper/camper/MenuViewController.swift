//
//  MenuViewController.swift
//  That Conference
//
//  Created by Steven Yang on 3/31/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var profileImage: CircleImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func editProfileButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func shareContactButtonPressed(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? FavoritesViewController {
            if segue.identifier == "favoriteSegue" {
                print("Prepare for segue")
                destination.store = StateData.instance.sessionStore
            }
            
        }
    }


}
