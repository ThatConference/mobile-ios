//
//  CircleButton.swift
//  That Conference
//
//  Created by Steven Yang on 6/14/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class CircleButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(3, 3)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.5
    }
}
