//
//  ProfileDetailUIView.swift
//  That Conference
//
//  Created by Steven Yang on 6/21/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import Foundation

class ProfileDetailUIView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderColor = UIColor.darkGray.cgColor
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }

}
