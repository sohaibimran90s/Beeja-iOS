//
//  TextContainerVC.swift
//  MeditationDemo
//
//  Created by Ehsan on 23/6/20.
//  Copyright © 2020 Ehsan. All rights reserved.
//

import UIKit

struct TextJournal {
    
    var title: String?
    var textDescription: String?
    var image: [UIImage]?
}


class TextContainerVC: UIViewController, TextCellDelegate, ImageCellDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var charCountLbl: UILabel!
    @IBOutlet weak var textTableView: UITableView!
    @IBOutlet weak var addImageBtn: UIButton!

    var imagePicker = UIImagePickerController()
    var textJournalObj: TextJournal?
    var addedImages: [UIImage] = []
    var noOfLinesInTextView = 5
    var textCellHeight = 80
    var textCellDefaultHeight = 80
    var isPurchasedAccount = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.titleField.setLeftPaddingPoints(20)
        //self.titleField.layer.cornerRadius = 5
        //self.textTableView.layer.cornerRadius = 5
        //self.view.backgroundColor = UIColor(red: 0/255, green: 15/255, blue: 84/255, alpha: 1.0)
        self.textTableView.contentInset = UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0)
        
        self.textJournalObj = TextJournal(title: "", textDescription: "", image: [])
        
        self.isPurchasedAccount = false
        self.checkIfAccountPaid()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func keyReturnPressed(text: String) {
        self.textJournalObj?.textDescription = text
    }
    
    func characterCountInTextView(count: Int) {
        self.charCountLbl.text = String(count) + "/500"
    }
        
    func getTextViewContentHeight(contentHeight: CGFloat) {
        
        let updatedHeight = Int(contentHeight) + 20 // add 20 for extra padding at bottom than actual contentHeight
        self.textCellHeight = (Int(contentHeight) < 70) ? 80 : updatedHeight // maintain default height to avoid less than 80
        self.textTableView.beginUpdates()
        self.textTableView.endUpdates()
    }
    
    func deleteImage(index: Int) {
        
        self.addedImages.remove(at: index)
        self.textTableView.reloadData()
        self.checkIfAccountPaid()
    }
    
    @IBAction func addImageAction(sender: UIButton) {
        
        if (!(self.isPurchasedAccount) && (self.addedImages.count > 0)) {
            Alert.alertWithTwoButton(title: "Warnning", message: "Purchase for more access.", btn1: "Cancel",
                                     btn2: "Buy", container: self, completion: { (alertController, index) in
                                        
                                        if (index == 1) {
                                            self.isPurchasedAccount = true
                                            self.checkIfAccountPaid()
                                        }
            })
            return
        }

        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func checkIfAccountPaid() {
        var titleTxt = "   Add an image"
        if (!(self.isPurchasedAccount) && (self.addedImages.count > 0)) {
            titleTxt = "   Upgrade to add more images"
        }
        
        let attributedString = NSMutableAttributedString(string:titleTxt, attributes:Constant.underLineAttrs)
        self.addImageBtn.setAttributedTitle(attributedString, for: .normal)
    }

    func resizeImageAndAddInTable(info: NSDictionary) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let imageData = image.jpeg(0.5)
        let img = UIImage.init(data: imageData!)
        self.addedImages.append(img!)
        self.textTableView.reloadData()
        self.textTableView.scrollToBottom()
        
        self.checkIfAccountPaid()
    }
    
    func textJournalExperienceLog() -> TextJournal{
        
        self.textJournalObj?.title = self.titleField.text
        self.textJournalObj?.image = self.addedImages
        
        return self.textJournalObj ?? TextJournal(title: "", textDescription: "", image: [])
    }
}

extension TextContainerVC: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat((indexPath.section == 0) ? self.textCellHeight : 200)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.addedImages.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if (indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell")! as! TextTableCell
            cell.delegate = self
            return cell
        }
        else {
            // 0 index reserved for above cell (TextViewTableCell) thats why we need to reduce 1 from indexpath section to start from 0
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell")! as! ImageTableCell
            cell.delegate = self
            cell.setCellImage(image: self.addedImages[indexPath.section - 1], index: indexPath.section - 1)
            return cell
        }
    }
}

extension TextContainerVC: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    }
}


extension TextContainerVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if (info[.originalImage] as? UIImage) != nil {
            //self.selectedImage.image = image
            self.resizeImageAndAddInTable(info: info as NSDictionary)
            dismiss(animated: true, completion: nil)
        }
    }
}

extension TextContainerVC: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.textJournalObj?.title = textField.text
    }
}


