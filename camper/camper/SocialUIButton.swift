//
//  SocialUIButton.swift
//  That Conference
//
//  Created by Steven Yang on 6/23/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class SocialUIButton: UIButton {
    
    func hideButton(_ hideBool: Bool) {
        if (hideBool) {
            self.isHidden = true
        } else {
            self.isHidden = false
        }
    }

}
