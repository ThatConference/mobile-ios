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
        
//        self.font = GameForFonts.mediumRegular
        self.textColor = UIColor.black
        
        
//        attributedPlaceholder = NSAttributedString(string:placeholder!, attributes: [NSFontAttributeName : GameForFonts.mediumRegular!, NSForegroundColorAttributeName : GameForColors.mainVeryDark.withAlphaComponent(0.6)])
    }

}
