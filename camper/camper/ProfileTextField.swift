//
//  ProfileTextField.swift
//  That Conference
//
//  Created by Steven Yang on 6/16/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class ProfileTextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderStyle = .none
        self.backgroundColor = UIColor.clear
        let border = CALayer()
        let width = CGFloat(1.0)
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderColor = UIColor.black.cgColor
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        
        let font: UIFont = UIFont(name: "Helvetica Neue", size: 16)!
        
        self.font = font
        self.textColor = UIColor.black
        
        attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.black.withAlphaComponent(0.3)])
    }

}
