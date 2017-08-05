//
//  CircleImage.swift
//  That Conference
//
//  Created by Steven Yang on 6/14/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class CircleImageView: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
    
    func addBorder() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(hex: 0xE7D4B1).cgColor
    }
}
