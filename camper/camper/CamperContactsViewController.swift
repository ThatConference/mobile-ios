//
//  CamperContactsViewController.swift
//  That Conference
//
//  Created by Steven Yang on 6/30/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit
import Firebase

class CamperContactsViewController: BaseViewControllerNoCameraViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!

    let conditionRef = Database.database().reference().child("contact-sharing")
    var contactArray: [Contact] = []
    var selectedContact: Contact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        refreshControl.addTarget(self, action: #selector(CamperContactsViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        
        self.tableView.addSubview(self.refreshControl)
        
        self.revealViewControllerFunc(barButton: menuButton)
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        startIndicator()
        
        if (self.refreshControl != nil) {
            self.refreshControl.endRefreshing()
        }
        
        let contactAPI = ContactAPI()
        
        contactAPI.getContacts { (result) in
            switch (result) {
            case .success(let contacts):
                self.contactArray = contacts
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.stopIndicator()
                }
                break
            case .failure(let error):
                print(error)
                self.contactArray = []
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.stopIndicator()
                }
                break
            }
        
//        if let contacts = PersistenceManager.loadContacts(Path.CamperContacts) {
//            StateData.instance.camperContacts = contacts
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                self.activityIndicator.stopAnimating()
//            }
//        } else {
//            let contactAPI = ContactAPI()
//
//            contactAPI.getContacts { (result) in
//                switch (result) {
//                case .success(let contacts):
//                    self.contactArray = contacts
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                        self.activityIndicator.stopAnimating()
//                    }
//                    break
//                case .failure(let error):
//                    print(error)
//                    self.contactArray = []
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                        self.activityIndicator.stopAnimating()
//                    }
//                    break
//                }
//            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UINavigationController {
            if (segue.identifier == "toProfileDetails") {
                let vc = destination.viewControllers.first as? ProfileDetailsViewController
                ISCURRENTUSER = false
                vc?.selectedContact = selectedContact
            }
        }
//        
//        if let destination = segue.destination as? ProfileDetailsViewController {
//            if (segue.identifier == "toProfileDetails") {
//                ISCURRENTUSER = false
//                destination.selectedContact = selectedContact
//            }
//        }
    }
}

extension CamperContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CamperContactCell") as? CamperContactTableViewCell {
            let contact = contactArray[indexPath.row]
            cell.setUpCell(contact: contact)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CamperContactTableViewCell {
            selectedContact = cell.contact
            performSegue(withIdentifier: "toProfileDetails", sender: self)
        }
    }
}
