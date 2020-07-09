//
//  ImageContainerVC.swift
//  MeditationDemo
//
//  Created by Ehsan on 23/6/20.
//  Copyright © 2020 Ehsan. All rights reserved.
//

import UIKit

struct ImageJournal {

    var title: String?
    var images: [CellImageObject]?
}

class ImageContainerVC: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var addImageBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var thumbCollectionView: UICollectionView!
    
    var imagePicker = UIImagePickerController()
    var actualImageList: [CellImageObject] = []
    var imageList: [CellImageObject] = []
    var isPurchasedAccount = false
    //var textJournalObj: TextJournal?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.isPurchasedAccount = false
        self.loadImageObjectList()
        
    }
    
    func loadImageObjectList() {
        
        self.imageList.removeAll()
        
        for index in 0...4 {
        
            if (self.actualImageList.count > index) {
                let obj = self.actualImageList[index]
                self.imageList.append(obj)
            }
            else {
                var image = (self.isPurchasedAccount) ? UIImage() : UIImage(named: "Locked.png")
                if (index == 0){ // first thumb icon should be blank (free thumb icon)
                    image = UIImage()
                }
                
                let imgObj = CellImageObject(caption: "", thumbImg: image ?? UIImage(), deleteIconActive: false)
                self.imageList.append(imgObj)
            }
        }
    }
        
    
    func resizeImageAndAddInMainImgV(info: NSDictionary) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let imageData = image.jpeg(0.5)
        let img = UIImage.init(data: imageData!)

        if let imgData = img {
            self.setMainImage(image: imgData)
        }
    }

    func setMainImage(image: UIImage) {
        self.addImageBtn.isHidden = true
        self.mainImageView.image = image
    }
        
    @IBAction func addImageAction(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveImageAction(sender: UIButton) {
        
        if (self.actualImageList.count == 5) {
            return
        }
        
        if (!(self.isPurchasedAccount) && (self.actualImageList.count > 0)) {
            Alert.alertWithTwoButton(title: "Warnning", message: "Purchase for more access.", btn1: "Cancel",
                                     btn2: "Buy", container: self, completion: { (alertController, index) in
                                        
                                        if (index == 1) {
                                            self.isPurchasedAccount = true
                                            self.paymentRequiredCheck()
                                            self.loadImageObjectList()
                                            self.thumbCollectionView.reloadData()
                                        }
            })
            return
        }
        
        
        if (self.titleTextField.text == ""){
            Alert.alertWithOneButton(title: "", message: "Please fill title to save.", container: self) { (alert, index) in
            }
            return
        }

        
        if let image = self.mainImageView.image {
            
            let imgObj = CellImageObject(caption: self.titleTextField.text ?? "", thumbImg: image, deleteIconActive: true)
            self.mainImageView.image = nil
            self.titleTextField.text = ""

            self.actualImageList.append(imgObj)
            self.loadImageObjectList()
            self.thumbCollectionView.reloadData()
            self.paymentRequiredCheck()
            
            self.addImageBtn.isHidden = (self.actualImageList.count == 5) ? true : false
        }
    }
    
    func deleteItem(index: Int) {
        self.actualImageList.remove(at: index)
        self.loadImageObjectList()
        self.thumbCollectionView.reloadData()
        self.paymentRequiredCheck()
        self.addImageBtn.isHidden = (self.actualImageList.count == 5) ? true : false
    }
    
    func paymentRequiredCheck() {
        var titleTxt = "Save Image"
        if (!(self.isPurchasedAccount) && (self.actualImageList.count > 0)) {
            titleTxt = "Upgrade to save more images"
        }
        
        let attributedString = NSMutableAttributedString(string:titleTxt, attributes:Constant.underLineAttrs)
        self.saveBtn.setAttributedTitle(attributedString, for: .normal)
    }
    
    func imageJournalExperienceLog() -> ImageJournal?{
        
        if (self.actualImageList.count == 0) {
            Alert.alertWithOneButton(title: "", message: "Please add image.", container: self) { (alert, index) in
            }
            return nil
        }
                
        var imageJournal = ImageJournal()
        imageJournal.title = self.actualImageList[0].captionTitle//self.titleTextField.text
        imageJournal.images = self.actualImageList
        return imageJournal
    }
}

extension ImageContainerVC: ThumbCollectionCellDelegate{

    func deleteThumbImage(index: Int) {
        self.deleteItem(index: index)
    }
}

extension ImageContainerVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                                layout collectionViewLayout: UICollectionViewLayout,
                                sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let multiplier: CGFloat = (self.view.frame.size.width > 360) ? 1.03 : 1
        return CGSize(width: (self.view.frame.size.width/5) * multiplier, height: CGFloat(70))
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbImageCell", for: indexPath) as! ThumbImgCollectionCell
        cell.delegate = self
        cell.setItemOnCell(index: indexPath.row, imageObj: self.imageList[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //let imgObj = self.imageList[indexPath.row]
    }

}

extension ImageContainerVC: UICollectionViewDelegate {
    
}

extension ImageContainerVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if (info[.originalImage] as? UIImage) != nil {
            self.resizeImageAndAddInMainImgV(info: info as NSDictionary)
            dismiss(animated: true, completion: nil)
        }
    }
}
