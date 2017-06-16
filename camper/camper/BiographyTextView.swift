//
//  BiographyTextView.swift
//  That Conference
//
//  Created by Steven Yang on 6/16/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class BiographyTextView: UITextView, UITextViewDelegate {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
        textContainer.lineFragmentPadding = 2
        
        attributedText = NSAttributedString(string:text ?? "", attributes: [NSForegroundColorAttributeName : UIColor.black.withAlphaComponent(0.6)])
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if text == "Biography" {
            self.textColor = UIColor.black
            text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if text == "" {
            attributedText = NSAttributedString(string: "Biography", attributes: [NSForegroundColorAttributeName : UIColor.black.withAlphaComponent(0.6)])
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text.isEqual("\n")) {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
}
