//
//  FamilyEventsTableViewCell.swift
//  That Conference
//
//  Created by Steven Yang on 4/21/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class FamilyEventsTableViewCell: TimeSlotRootTableViewCell {
    @IBOutlet weak var updateFlag: UIImageView!
    @IBOutlet weak var sessionTitle: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var speakerLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var favoriteIcon: UIImageView!
    @IBOutlet weak var cancelledCover: UIView!
    @IBOutlet weak var sessionTitleCancelled: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
