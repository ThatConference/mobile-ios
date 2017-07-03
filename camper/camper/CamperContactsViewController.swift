//
//  CamperContactsViewController.swift
//  That Conference
//
//  Created by Steven Yang on 6/30/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class CamperContactsViewController: UIViewController {

    @IBOutlet weak var contactImageView: CircleImageView!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}

extension CamperContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
