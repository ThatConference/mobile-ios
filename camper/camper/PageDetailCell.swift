//
//  PageDetailCell.swift
//  That Conference
//
//  Created by Matthew Ridley on 5/1/16.
//  Copyright © 2016 That Conference. All rights reserved.
//

import Foundation
import UIKit

class PageDetailCell: UITableViewCell {
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var iconImage: UIImageView!
    
    var speaker: Speaker!
}