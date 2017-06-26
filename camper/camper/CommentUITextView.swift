//
//  CommentUITextView.swift
//  That Conference
//
//  Created by Steven Yang on 6/23/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class CommentUITextView: UITextView, UITextViewDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
        textContainer.lineFragmentPadding = 1
        
        checkText()
    }

    private func checkText() {
        if (text == "" || text == nil || text == "Comment") {
            let font: UIFont = UIFont(name: "Helvetica Neue", size: 13)!
            
            attributedText = NSAttributedString(string: "Comment", attributes: [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.black.withAlphaComponent(0.3)])
        } else {
            self.textColor = UIColor.black
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (text == "Comment") {
            self.textColor = UIColor.black
            text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (text == "") {
            let font: UIFont = UIFont(name: "Helvetica Neue", size: 13)!
            
            attributedText = NSAttributedString(string: "Comment", attributes: [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.black.withAlphaComponent(0.3)])
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
