//
//  CamperContactTableViewCell.swift
//  That Conference
//
//  Created by Steven Yang on 7/3/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class CamperContactTableViewCell: UITableViewCell {

    @IBOutlet weak var camperImageView: CircleImageView!
    @IBOutlet weak var camperNameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    
    var contact: Contact!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpCell(contact: Contact) {
        self.contact = contact
        camperImageView.loadImageURL(url: URL(string: contact.headShot ?? ""))
        camperNameLabel.text = contact.fullName
        companyLabel.text = contact.companyString
    }
}
