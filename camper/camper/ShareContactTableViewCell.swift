//
//  ShareContactTableViewCell.swift
//  That Conference
//
//  Created by Steven Yang on 7/5/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class ShareContactTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var selectIconImageView: UIImageView!
    
    var userAux: UserAuxiliaryModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if (selected) {
            selectIconImageView.image = UIImage(named: "selected")
        } else  {
            selectIconImageView.image = UIImage(named: "unselected")
        }
    }
    
    func setUpCell(userAux: UserAuxiliaryModel) {
        self.userAux = userAux
        profileImageView.loadImageURL(url: URL(string: userAux.displayHeadShotString), cache: IMAGE_CACHE)
        contactNameLabel.text = userAux.fullName
        companyLabel.text = userAux.companyString
    }

}
