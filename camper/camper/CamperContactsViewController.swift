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
  
    var imageLoader: ImageCacheLoader = ImageCacheLoader()
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
    
    @objc func refresh(_ sender: AnyObject) {
        DispatchQueue.main.async {
            self.loadData()
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
                if (contacts.count <= 0) {
                    self.contactArray = []
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.stopIndicator()
                    }
                    break
                } else {
                    self.contactArray = contacts
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.stopIndicator()
                    }
                    break
                }

            case .failure(let error):
                print(error)
                if let contacts = PersistenceManager.loadContacts(Path.CamperContacts) {
                    StateData.instance.camperContacts = contacts
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.activityIndicator.stopAnimating()
                    }
                    break
                } else {
                    self.contactArray = []
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.stopIndicator()
                    }
                    break
                }
            }
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
    }
}

extension CamperContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CamperContactCell") as? CamperContactTableViewCell {
            let contact = contactArray[indexPath.row]
            cell.contact = contact
            cell.camperNameLabel.text = contact.fullName
            cell.companyLabel.text = contact.companyString
            cell.camperImageView.image = UIImage(named: "profile")
          
            imageLoader.loadImageURL(url: URL(string: contact.headShot ?? "")) { (image) in
              if let updateCell = tableView.cellForRow(at: indexPath) as? CamperContactTableViewCell {
                updateCell.camperImageView.image = image
              }
            }
          
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
