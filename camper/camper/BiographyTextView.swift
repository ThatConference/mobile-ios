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
        
        checkText()
        
//        attributedText = NSAttributedString(string: text ?? "Biography", attributes: [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.black.withAlphaComponent(0.3)])
    }
    
    private func checkText() {
        if (text == "" || text == nil || text == "Biography") {
            let font: UIFont = UIFont(name: "Helvetica Neue", size: 16)!
            
            attributedText = NSAttributedString(string: text ?? "Biography", attributes: [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.black.withAlphaComponent(0.3)])
        } else {
            self.textColor = UIColor.black
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (text == "Biography") {
            self.textColor = UIColor.black
            text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if text == "" {
            let font: UIFont = UIFont(name: "Helvetica Neue", size: 16)!
            
            attributedText = NSAttributedString(string: "Biography", attributes: [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.black.withAlphaComponent(0.3)])
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
