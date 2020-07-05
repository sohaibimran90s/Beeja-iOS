//
//  AddJournalVC.swift
//  MeditationDemo
//
//  Created by Ehsan on 22/6/20.
//  Copyright © 2020 Ehsan. All rights reserved.
//

import UIKit
import Alamofire

enum JournalOption {
    case TextEntry
    case ImageEntry
    case AudioEntry
    case AudioToTextEntry
}

class AddJournalVC: UIViewController {

    @IBOutlet weak var textBtn: UIButton!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var voiceBtn: UIButton!
    @IBOutlet weak var voiceToTextBtn: UIButton!
    
    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var imageContainerView: UIView!

    
    var kPurchasedAlready = false
    var textContainerVC: TextContainerVC?
    var imageContainerVC: ImageContainerVC?
    var selectedJournalOpt: JournalOption?
    let appPreference = WWMAppPreference()
    var isAddJournal = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Add Text Entry"
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear

        let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(UIImage(named: "CloseBtn.png"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(closeButtonAction), for: UIControl.Event.touchUpInside)
        //button.frame = CGRectMake(0, 0, 53, 31)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        

        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        //self.view.backgroundColor = UIColor(red: 0/255, green: 15/255, blue: 84/255, alpha: 1.0)
        
        textBtn.isSelected = true
        imageContainerView.isHidden = true
        
        self.selectedJournalOpt = JournalOption.TextEntry
    }
    
    @objc func closeButtonAction() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func addTextJournal(sender: UIButton) {
        
        self.selectedJournalOpt = JournalOption.TextEntry
        self.addSelectedJournal()
    }
    
    @IBAction func addImageJournal(sender: UIButton) {
        
        self.selectedJournalOpt = JournalOption.ImageEntry
        self.addSelectedJournal()
    }

    @IBAction func addVoiceJournal(sender: UIButton) {
        
        self.selectedJournalOpt = JournalOption.AudioEntry
        self.addSelectedJournal()
    }

    @IBAction func addVoiceToTextJournal(sender: UIButton) {
        
        self.selectedJournalOpt = JournalOption.AudioToTextEntry
        self.addSelectedJournal()
    }

    func addSelectedJournal() {
        
        let journal = self.selectedJournalOpt
        switch journal {
        case .TextEntry:
            textBtn.isSelected = true
            imageBtn.isSelected = false
            voiceBtn.isSelected = false
            voiceToTextBtn.isSelected = false
            textContainerView.isHidden = false
            imageContainerView.isHidden = true
        case .ImageEntry:
            textBtn.isSelected = false
            imageBtn.isSelected = true
            voiceBtn.isSelected = false
            voiceToTextBtn.isSelected = false
            textContainerView.isHidden = true
            imageContainerView.isHidden = false
        case .AudioEntry:
            textBtn.isSelected = false
            imageBtn.isSelected = false
            voiceBtn.isSelected = true
            voiceToTextBtn.isSelected = false
        case .AudioToTextEntry:
            textBtn.isSelected = false
            imageBtn.isSelected = false
            voiceBtn.isSelected = false
            voiceToTextBtn.isSelected = true
        default:
            print("default")
        }
    }
    
    @IBAction func logExperienceAction(sender: UIButton) {
                
        let journal = self.selectedJournalOpt
        switch journal {
        case .TextEntry:
            self.textJournalLog()
            
        case .ImageEntry:
            self.imageJournalLog()

        //case .AudioEntry:
        //case .AudioToTextEntry:
        default:
            print("default")
        }
    }
    
    func errorAlert(title: String, msg: String) {
        Alert.alertWithOneButton(title: title, message: msg, container: self) { (alert, index) in
        }
    }
    
    //MARK: API Call TextJournal
    func textJournalLog() {

        guard let textJournal = self.textContainerVC?.textJournalExperienceLog() else {return}

        if (textJournal.title == ""){
            self.errorAlert(title: "", msg: "Please fill title to experience journal log.")
            return
        }

        if (textJournal.textDescription == ""){
            self.errorAlert(title: "", msg: "Please fill description to experience journal log.")
            return
        }
                    
        var jsonBody: Any = ""
        if (self.isAddJournal) {
            jsonBody = RequestBody.addJournalBody(appPreference: self.appPreference, title: textJournal.title ?? "",
                                                  textDescrip: textJournal.textDescription ?? "")
        }
        else {
            jsonBody = RequestBody.meditationCompleteBody(appPreference: self.appPreference, title: textJournal.title ?? "",
                                                  textDescrip: textJournal.textDescription ?? "")
        }
        
        WWMHelperClass.showLoaderAnimate(on: self.view)
        DataManager.sharedInstance.addJournalAPI(body: jsonBody) { (isSuccess, journalId, error) in
            if (isSuccess) {
                self.uploadTextAssets(journalId: journalId, textJournalObj: textJournal)
            }
            else {
                WWMHelperClass.hideLoaderAnimate(on: self.view)
                self.errorAlert(title: "Error!", msg: error)
            }
        }
    }
     
    
    func uploadTextAssets(journalId: Int, textJournalObj: TextJournal) {
        
        guard let imgArray = textJournalObj.image, imgArray.count > 0 else {return}
            
        var imgDataArray: [Data] = []
        for img in imgArray {
            let imageData = img.jpegData(compressionQuality: 1.0)!
            imgDataArray.append(imageData)
        }
        
        let jsonBody = RequestBody.journalAssetsBody(journalId: journalId, type: "image")
        DataManager.sharedInstance.uploadImages(imageDataArray: imgDataArray, parameter: jsonBody) { (isSuccess, errorMsg) in
            
            WWMHelperClass.hideLoaderAnimate(on: self.view)

            if (isSuccess) {
                self.dismiss(animated: false, completion: nil)
            }
            else {
               self.errorAlert(title: "", msg: errorMsg)
            }
        }
    }
    
    
    //MARK: API Call ImageJournal

    func imageJournalLog() {

        guard let imageJournal = self.imageContainerVC?.imageJournalExperienceLog() else {return}

        if (imageJournal.title == ""){
            self.errorAlert(title: "", msg: "Please fill title to experience journal log.")
            return
        }

        if (imageJournal.images!.count == 0){
            self.errorAlert(title: "", msg: "Please add image.")
            return
        }

        var jsonBody: Any = ""
        if (self.isAddJournal) {
            jsonBody = RequestBody.addJournalBody(appPreference: self.appPreference,
                                                      title: "", textDescrip: imageJournal.title ?? "")
        }
        else {
            jsonBody = RequestBody.meditationCompleteBody(appPreference: self.appPreference,
                                                      title: "", textDescrip: imageJournal.title ?? "")
        }
        
        WWMHelperClass.showLoaderAnimate(on: self.view)
        DataManager.sharedInstance.addJournalAPI(body: jsonBody) { (isSuccess, journalId, error) in
            if (isSuccess) {
                self.uploadImageAssets(journalId: journalId, imageJournalObj: imageJournal)
            }
            else {
                WWMHelperClass.hideLoaderAnimate(on: self.view)
                self.errorAlert(title: "Error!", msg: error)
            }
        }
    }
    
    func uploadImageAssets(journalId: Int, imageJournalObj: ImageJournal) {
        
        guard let imgObjArray = imageJournalObj.images, imgObjArray.count > 0 else {return}
            
        var imgDataArray: [Data] = []
        for imgObj in imgObjArray {
            
            let thumbImg = imgObj.thumbImg
            let imageData = thumbImg.jpegData(compressionQuality: 1.0)!
            imgDataArray.append(imageData)
        }
        
        let jsonBody = RequestBody.journalAssetsBody(journalId: journalId, type: "image")
        DataManager.sharedInstance.uploadImages(imageDataArray: imgDataArray, parameter: jsonBody) { (isSuccess, errorMsg) in
            
            WWMHelperClass.hideLoaderAnimate(on: self.view)

            if (isSuccess) {
                self.dismiss(animated: false, completion: nil)
            }
            else {
               self.errorAlert(title: "", msg: errorMsg)
            }
        }
    }


        

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "TextEntryIdentifier" {
            if let viewController1 = segue.destination as? TextContainerVC {
                self.textContainerVC = viewController1
            }
        }
        else if segue.identifier == "ImageEntryIdentifier" {
            if let viewController2 = segue.destination as? ImageContainerVC {
                self.imageContainerVC = viewController2
            }
        }
    }
   
}

