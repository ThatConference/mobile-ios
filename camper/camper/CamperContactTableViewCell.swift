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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpCell() {
        
    }
}
