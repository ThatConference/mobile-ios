//
//  SpeakerTableViewCell.swift
//  That Conference
//
//  Created by Steven Yang on 6/14/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class SpeakerTableViewCell: UITableViewCell {

    @IBOutlet weak var speakerImageView: CircleImageView!
    @IBOutlet weak var speakerNameLabel: UILabel!
    @IBOutlet weak var businessLabel: UILabel!
    
    var speaker: Speaker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
