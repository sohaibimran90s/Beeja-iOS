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

struct MeditationComplete{
    var moodData = WWMMoodMeterData()
    var selectedIndex = "-1"
    var type = ""   // Pre | Post
    var prepTime = 0
    var meditationTime = 0
    var restTime = 0
    var meditationID = ""
    var levelID = ""
    var backgroundvedioView = WWMBackgroundVedioView()
    var player: AVPlayer?
    var popupTitle: String = ""
    var hidShowMoodMeter = "Show"
    var category_Id = "0"
    var emotion_Id = "0"
    var audio_Id = "0"
    var watched_duration = "0"
    var rating = "0"
    var checkAnalyticStr = ""
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
    
    //=========== for API call Meditation complete
    var mediCompleteObj = MeditationComplete()
    
    
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
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.setHidesBackButton(true, animated: false);
    }
    
    @objc func closeButtonAction() {
        if (self.isAddJournal) {
            self.dismiss(animated: false, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
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

        var jsonBody: Any = ""
        if (self.isAddJournal) {
            jsonBody = RequestBody.addJournalBody(appPreference: self.appPreference, title: textJournal.title ?? "",
                                                  textDescrip: textJournal.textDescription ?? "")
        }
        else {
            jsonBody = RequestBody.meditationCompleteBody(appPreference: self.appPreference, title: textJournal.title ?? "",
                                                          textDescrip: textJournal.textDescription ?? "", medCompObj: self.mediCompleteObj)
        }
        
        WWMHelperClass.showLoaderAnimate(on: self.view)
        DataManager.sharedInstance.addJournalAPI(body: jsonBody) { (isSuccess, journalId, error) in
            if (isSuccess) {
                self.uploadTextAssets(journalId: journalId, textJournalObj: textJournal)
            }
            else {
                WWMHelperClass.hideLoaderAnimate(on: self.view)
                self.errorAlert(title: "Error!", msg: error)
                
                //Prashant
                //save request in core-data
                self.saveJournalDatatoDB(param: jsonBody as! [String:Any])
                //----------------
            }
        }
    }
     
    
    func uploadTextAssets(journalId: Int, textJournalObj: TextJournal) {
        
        guard let imgArray = textJournalObj.image, imgArray.count > 0 else {
            WWMHelperClass.hideLoaderAnimate(on: self.view)
            if (self.isAddJournal){
                self.dismiss(animated: false, completion: nil)
            }
            else {
                self.navigationController!.popToRootViewController(animated: true)
            }
            return
        }
            
        var imgDataArray: [Data] = []
        for img in imgArray {
            let imageData = img.jpegData(compressionQuality: 1.0)!
            imgDataArray.append(imageData)
        }
        
        let jsonBody = RequestBody.journalAssetsBody(journalId: journalId, type: "image")
        DataManager.sharedInstance.uploadImages(imageDataArray: imgDataArray, parameter: jsonBody) { (isSuccess, errorMsg) in
            
            WWMHelperClass.hideLoaderAnimate(on: self.view)

            if (isSuccess) {
                if (self.isAddJournal){
                    self.dismiss(animated: false, completion: nil)
                }
                else {
                    self.navigationController!.popToRootViewController(animated: true)
                }
            }
            else {
               self.errorAlert(title: "", msg: errorMsg)
            }
        }
    }
    
    
    //MARK: API Call ImageJournal

    func imageJournalLog() {
        
        guard let imageJournal = self.imageContainerVC?.imageJournalExperienceLog() else {return}

        var jsonBody: Any = ""
        if (self.isAddJournal) {
            jsonBody = RequestBody.addJournalBody(appPreference: self.appPreference,
                                                      title: "", textDescrip: imageJournal.title ?? "")
        }
        else {
            jsonBody = RequestBody.meditationCompleteBody(appPreference: self.appPreference, title: "",
                                                          textDescrip: imageJournal.title ?? "", medCompObj: self.mediCompleteObj)
        }
        
        WWMHelperClass.showLoaderAnimate(on: self.view)
        DataManager.sharedInstance.addJournalAPI(body: jsonBody) { (isSuccess, journalId, error) in
            if (isSuccess) {
                self.uploadImageAssets(journalId: journalId, imageJournalObj: imageJournal)
            }
            else {
                WWMHelperClass.hideLoaderAnimate(on: self.view)
                self.errorAlert(title: "Error!", msg: error)
                
                //Prashant
                //save request in core-data
                self.saveJournalDatatoDB(param: jsonBody as! [String:Any])
                //----------------
            }
        }
    }
    
    func uploadImageAssets(journalId: Int, imageJournalObj: ImageJournal) {
        
        guard let imgObjArray = imageJournalObj.images, imgObjArray.count > 0 else {return}
            
        var imgDataArray: [Data] = []
        for imgObj in imgObjArray { // convert all UIImage into Data and collect into Array
            
            let thumbImg = imgObj.thumbImg
            let imageData = thumbImg.jpegData(compressionQuality: 1.0)!
            imgDataArray.append(imageData)
        }
        
        var jsonBody = RequestBody.journalAssetsBody(journalId: journalId, type: "image")
        
        var index = 1
        for img in imgObjArray {    // add all captions in json body. Though its not fixed so we need to run loop to add it.
            let captionStr = img.captionTitle
            jsonBody["caption" + String(index)] = captionStr as AnyObject
            index += 1
        }
        
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
   
    //Prashant
    //MARK:- Save to core data
    func saveJournalDatatoDB(param:[String:Any]) {
        let dbJournal = WWMHelperClass.fetchEntity(dbName: "DBJournalData") as! DBJournalData
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: param, options:.prettyPrinted)
        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        dbJournal.journalData = myString
        WWMHelperClass.saveDb()
    }
    //----------------
}

