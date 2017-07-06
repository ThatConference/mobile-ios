//
//  CamperContactsViewController.swift
//  That Conference
//
//  Created by Steven Yang on 6/30/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit
import Firebase

class CamperContactsViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    var activityIndicator: UIActivityIndicatorView!

    let conditionRef = Database.database().reference().child("contact-sharing")
    
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

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(CamperContactsViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        
        self.tableView.addSubview(self.refreshControl)
        
        self.revealViewControllerFunc(barButton: menuButton)
        
        loadData()
    }
    
    
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toShareContact", sender: self)
    }
    
    func refresh(_ sender: AnyObject) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func loadData() {
//        let contactAPI = ContactAPI()
//        contactAPI.getContacts()
        
//        conditionRef.observe(.value) { (snap: DataSnapshot) in
//            print(snap.value.debugDescription)
//        }

        //Saving data
        
//        let params: [String: Dictionary<String, Any>] = ["requests": ["UserID": "asfe-sdfgre-vdfv", "DateTime": Date().dateToInt()], "blocks": ["UserID": "asfe-sdfgre-vdfv", "DateTime": Date().dateToInt()]]
//        
//        conditionRef.child(StateData.instance.currentUser.id).setValue(params)
    }
    
    func revealViewControllerFunc(barButton: UIBarButtonItem) {
        if revealViewController() != nil {
            barButton.target = revealViewController()
            barButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().panGestureRecognizer().isEnabled = false
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
}

extension CamperContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CamperContactCell") as? CamperContactTableViewCell {
            return cell
        }
        
        return UITableViewCell()
    }
}
