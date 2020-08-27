//
//  ImageTableCell.swift
//  MeditationDemo
//
//  Created by Ehsan on 24/6/20.
//  Copyright © 2020 Ehsan. All rights reserved.
//

import UIKit

protocol ImageCellDelegate {
    func deleteImage(index: Int)
}

class ImageTableCell: UITableViewCell {

    @IBOutlet weak var addImageView: UIImageView!
    @IBOutlet weak var crossBtn: UIButton!
    
    var delegate: ImageCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellImage(image: UIImage, index: Int) {
        
        self.crossBtn.tag = index
        self.addImageView.image = image
    }
    
    @IBAction func deleteImage(sender: UIButton) {
        self.delegate.deleteImage(index: sender.tag)
    }

}
