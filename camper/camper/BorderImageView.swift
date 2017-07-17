//
//  BorderImageView.swift
//  That Conference
//
//  Created by Steven Yang on 6/22/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class BorderImageView: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(hex: 0xF8F1E4).cgColor
    }

}
