//
//  TextTableCell.swift
//  MeditationDemo
//
//  Created by Ehsan on 24/6/20.
//  Copyright © 2020 Ehsan. All rights reserved.
//

import UIKit

protocol TextCellDelegate {
    func keyReturnPressed(text: String)
    func characterCountInTextView(count: Int)
    func getTextViewContentHeight(contentHeight: CGFloat)
}

let placeHolder = "What's on your mind right now?"
let kCharacterCountLimit = 500

class TextTableCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    
    var delegate : TextCellDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setTextViewPlaceholder()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setTextViewPlaceholder() {
        textView.text = placeHolder
        textView.textColor = UIColor.lightGray
    }
    
    func getHeightOfTextView() {
        
        let contentH = textView.contentSize.height
        self.delegate.getTextViewContentHeight(contentHeight: contentH)
    }
}


extension TextTableCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
//            textView.resignFirstResponder()
//            self.delegate.keyReturnPressed(text: textView.text)
//            return false
//        }
        
        // Set limit of character.
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        self.delegate.characterCountInTextView(count: newText.count) // Count character
        
        let contentH = textView.contentSize.height
        self.delegate.getTextViewContentHeight(contentHeight: contentH)

        return newText.count < kCharacterCountLimit
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeHolder
            textView.textColor = UIColor.lightGray
        }
        
        self.getHeightOfTextView()
        self.delegate.keyReturnPressed(text: textView.text)
    }

}
