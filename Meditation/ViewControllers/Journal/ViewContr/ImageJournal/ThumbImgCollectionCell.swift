//
//  ThumbImgCollectionCell.swift
//  MeditationDemo
//
//  Created by Ehsan on 25/6/20.
//  Copyright © 2020 Ehsan. All rights reserved.
//

import UIKit

protocol ThumbCollectionCellDelegate {
    func deleteThumbImage(index: Int)
}

class CellImageObject {
    var captionTitle: String
    var thumbImg: UIImage
    var deleteIconActive: Bool
    
    init(caption: String, thumbImg: UIImage, deleteIconActive: Bool) {
        self.captionTitle = caption
        self.thumbImg = thumbImg
        self.deleteIconActive = deleteIconActive
    }
}

class ThumbImgCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var delegate: ThumbCollectionCellDelegate!
    
    
    func setItemOnCell(index: Int, imageObj: CellImageObject) {
        if (index == 0) {
            self.thumbImage.contentMode = UIView.ContentMode.scaleAspectFill;
        }
        
        self.thumbImage.contentMode = (imageObj.deleteIconActive) ? UIView.ContentMode.scaleAspectFill : UIView.ContentMode.center
        self.deleteBtn.tag = index
        self.thumbImage.image = imageObj.thumbImg
        self.deleteBtn.isHidden = (imageObj.deleteIconActive) ? false : true
    }
    
    
    @IBAction func deleteAction(sender: UIButton) {
        
        self.delegate.deleteThumbImage(index: sender.tag)
        
    }
}
