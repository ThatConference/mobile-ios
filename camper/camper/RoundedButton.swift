//
//  RoundedButton.swift
//  That Conference
//
//  Created by Steven Yang on 6/16/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 15
    }

    func setCommentTitle() {
        if (self.currentTitle == "Add a Personal Comment") {
            self.setTitle("Save Personal Comment", for: .normal)
        } else {
            self.setTitle("Add a Personal Comment", for: .normal)
        }
    }
    
}
