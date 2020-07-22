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
    @IBOutlet weak var logExprnctBtn: UIButton!

    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var audioContainerView: UIView!
    @IBOutlet weak var audioToTextContainerView: UIView!

    
    var textContainerVC: TextContainerVC?
    var imageContainerVC: ImageContainerVC?
    var audioContainerVC: AudioContainerVC?
    var audioToTextContainerVC: AudioToTextContainerVC?

    var selectedJournalOpt: JournalOption?
    let appPreference = WWMAppPreference()
    var isAddJournal = false
    
    //var kPurchasedAlready = false
    let kDataManager = DataManager.sharedInstance

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
        audioContainerView.isHidden = true
        audioToTextContainerView.isHidden = true

        self.selectedJournalOpt = JournalOption.TextEntry
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.setHidesBackButton(true, animated: false);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        kDataManager.isPaidAc = self.appPreference.getExpiryDate()

        if (kDataManager.isPaidAc) {

            self.textContainerVC?.checkIfAccountPaid()
            self.imageContainerVC?.updateUI()
            self.audioContainerVC?.purchasedUpdate()
            self.audioToTextContainerVC?.purchasedUpdate()
            
            self.checkForPaidAccount()
            
            voiceBtn.setImage(UIImage(named: "VoiceDisabled.png"), for: UIControl.State.normal)
            voiceToTextBtn.setImage(UIImage(named: "VoicetoTextDisabled.png"), for: UIControl.State.normal)
        }
        else {
            voiceBtn.setImage(UIImage(named: "VoiceLockedDis.png"), for: UIControl.State.normal)
            voiceToTextBtn.setImage(UIImage(named: "VoicetoTextLockedDis.png"), for: UIControl.State.normal)
        }
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
            audioContainerView.isHidden = true
            audioToTextContainerView.isHidden = true
            self.checkForPaidAccount()//New
            
        case .ImageEntry:
            textBtn.isSelected = false
            imageBtn.isSelected = true
            voiceBtn.isSelected = false
            voiceToTextBtn.isSelected = false
            textContainerView.isHidden = true
            audioContainerView.isHidden = true
            audioToTextContainerView.isHidden = true
            imageContainerView.isHidden = false
            self.checkForPaidAccount()//New
            
        case .AudioEntry:
            textBtn.isSelected = false
            imageBtn.isSelected = false
            voiceBtn.isSelected = true
            voiceToTextBtn.isSelected = false
            textContainerView.isHidden = true
            imageContainerView.isHidden = true
            audioContainerView.isHidden = false
            audioToTextContainerView.isHidden = true
            self.checkForPaidAccount()//New
            
        case .AudioToTextEntry:
            textBtn.isSelected = false
            imageBtn.isSelected = false
            voiceBtn.isSelected = false
            voiceToTextBtn.isSelected = true
            textContainerView.isHidden = true
            imageContainerView.isHidden = true
            audioContainerView.isHidden = true
            audioToTextContainerView.isHidden = false
            self.checkForPaidAccount()//New
            
        default:
            print("default")
        }
        
        NotificationCenter.default.post(name: Notification.Name(Constant.kNotificationInAudioJournal), object: nil)
        NotificationCenter.default.post(name: Notification.Name(Constant.kNotificationInAudioToTextJournal), object: nil)
    }

    func checkForPaidAccount() { //New
        
        var logBtnTitle = ""
        let journal = self.selectedJournalOpt
        switch journal {
        case .TextEntry:
            logBtnTitle = "Log Experience"

        case .ImageEntry:
            logBtnTitle = "Log Experience"

        case .AudioEntry:
            self.voiceBtnUpdate()
            self.voiceToTextBtnUpdate()
            logBtnTitle = (kDataManager.isPaidAc) ? "Log Experience" : "Upgrade to Premium"
            self.audioContainerVC?.updateAudioView()

        case .AudioToTextEntry:
            self.voiceToTextBtnUpdate()
            self.voiceBtnUpdate()
            logBtnTitle = (kDataManager.isPaidAc) ? "Log Experience" : "Upgrade to Premium"
            self.audioToTextContainerVC?.updateAudioToTextView()
            
        default:
            print("default")
        }
        
        logExprnctBtn.setTitle(logBtnTitle, for: UIControl.State.normal)
    }

    func voiceBtnUpdate() {
        let selectedBtnImg = (kDataManager.isPaidAc) ? "Voice.png" : "VoiceLockedEn.png"
        voiceBtn.setImage(UIImage(named: selectedBtnImg), for: UIControl.State.selected)
        
        let normalBtnImg = (kDataManager.isPaidAc) ? "VoiceDisabled.png" : "VoiceLockedDis.png"
        voiceBtn.setImage(UIImage(named: normalBtnImg), for: UIControl.State.normal)
    }
    
    func voiceToTextBtnUpdate() {
        let selectedBtnImg = (kDataManager.isPaidAc) ? "VoicetoText.png" : "VoicetoTextLockedEn.png"
        voiceToTextBtn.setImage(UIImage(named: selectedBtnImg), for: UIControl.State.selected)
        
        let normalBtnImg = (kDataManager.isPaidAc) ? "VoicetoTextDisabled.png" : "VoicetoTextLockedDis.png"
        voiceToTextBtn.setImage(UIImage(named: normalBtnImg), for: UIControl.State.normal)
    }
    
    /*func upgradeToPremium() {
        Alert.alertWithTwoButton(title: "Warnning", message: "Purchase For this section.", btn1: "Cancel",
                                 btn2: "Buy", container: self, completion: { (alertController, index) in
                                    
                                    if (index == 1) {
                                        self.kDataManager.isPaidAc = true
                                        self.audioContainerVC?.purchasedUpdate()
                                        self.audioToTextContainerVC?.purchasedUpdate()
                                        self.checkForPaidAccount()
                                    }
        })
    }*/

    
    @IBAction func logExperienceAction(sender: UIButton) {
                
        let journal = self.selectedJournalOpt
        switch journal {
        case .TextEntry:
            self.textJournalLog()
            
        case .ImageEntry:
            self.imageJournalLog()

        case .AudioEntry:
            if (kDataManager.isPaidAc){
                self.audioJournalLog()
            }
            else {
                //self.upgradeToPremium()
                Utilities.paymentController(container: self)
            }
            
        case .AudioToTextEntry:
            if (kDataManager.isPaidAc){
                self.audioToTextJournalLog()
            }
            else {
                //self.upgradeToPremium()
                Utilities.paymentController(container: self)
            }

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
                                                  textDescrip: textJournal.textDescription ?? "",
                                                  type: Constant.JournalType.TEXT)
        }
        else {
            jsonBody = RequestBody.meditationCompleteBody(appPreference: self.appPreference, title: textJournal.title ?? "",
                                                          textDescrip: textJournal.textDescription ?? "", medCompObj: self.mediCompleteObj, type: Constant.JournalType.TEXT)
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
        
        let jsonBody = RequestBody.journalAssetsBody(journalId: journalId, type: Constant.JournalType.IMAGE)
        DataManager.sharedInstance.uploadAssets(imageDataArray: imgDataArray, parameter: jsonBody) { (isSuccess, errorMsg) in
            
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
                                                      title: "", textDescrip: imageJournal.title ?? "",
                                                      type: Constant.JournalType.IMAGE)
        }
        else {
            jsonBody = RequestBody.meditationCompleteBody(appPreference: self.appPreference, title: "",
                                                          textDescrip: imageJournal.title ?? "", medCompObj: self.mediCompleteObj,
                                                          type: Constant.JournalType.IMAGE)
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
        for imgObj in imgObjArray { // convert all UIImage into Data and collect into Array
            
            let thumbImg = imgObj.thumbImg
            let imageData = thumbImg.jpegData(compressionQuality: 1.0)!
            imgDataArray.append(imageData)
        }
        
        var jsonBody = RequestBody.journalAssetsBody(journalId: journalId, type: Constant.JournalType.IMAGE)
        
        var index = 1
        for img in imgObjArray {    // add all captions in json body. Though its not fixed so we need to run loop to add it.
            let captionStr = img.captionTitle
            jsonBody["caption" + String(index)] = captionStr as AnyObject
            index += 1
        }
        
        DataManager.sharedInstance.uploadAssets(imageDataArray: imgDataArray, parameter: jsonBody) { (isSuccess, errorMsg) in
            
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


    //MARK: API Call AudioJournal
    func audioJournalLog() {
        
        guard let audioJournal = self.audioContainerVC?.audioJournalExperienceLog() else {return}
        
        var jsonBody: Any = ""
        if (self.isAddJournal) {
            jsonBody = RequestBody.addJournalBody(appPreference: self.appPreference,
                                                  title: "",
                                                  textDescrip: audioJournal.caption ?? "", type: Constant.JournalType.VOICE)
        }
        else {
            jsonBody = RequestBody.meditationCompleteBody(appPreference: self.appPreference,
                                                          title: "",
                                                          textDescrip: audioJournal.caption ?? "",
                                                          medCompObj: self.mediCompleteObj, type: Constant.JournalType.VOICE)
        }

        WWMHelperClass.showLoaderAnimate(on: self.view)
        DataManager.sharedInstance.addJournalAPI(body: jsonBody) { (isSuccess, journalId, error) in
            
            WWMHelperClass.hideLoaderAnimate(on: self.view)
            if (isSuccess) {
                self.uploadAudioAssets(journalId: journalId, audioJournalObj: audioJournal)
            }
            else {
                self.errorAlert(title: "Error!", msg: error)
            }
        }
    }
    
    func uploadAudioAssets(journalId: Int, audioJournalObj: AudioJournal) {
        
        guard let fileUrl = audioJournalObj.audioFilePath else {return}
        var audioDataArray: [Data] = []

        do {
            let audioData = try Data(contentsOf:fileUrl, options: [.alwaysMapped , .uncached ] )
            audioDataArray.append(audioData)
        }
        catch {
            print(error)
            return
        }
        
        var jsonBody = RequestBody.journalAssetsBody(journalId: journalId, type: Constant.JournalType.VOICE)
        jsonBody["caption"] = audioJournalObj.caption as AnyObject?
        
        DataManager.sharedInstance.uploadAssets(imageDataArray: audioDataArray, parameter: jsonBody) { (isSuccess, errorMsg) in
            
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


        
//MARK: API Call AudioToTextJournal
    func audioToTextJournalLog() {
        
        guard let audioToTextJournal = self.audioToTextContainerVC?.audioToTextJournalExperienceLog() else {return}

        var jsonBody: Any = ""
        if (self.isAddJournal) {
            jsonBody = RequestBody.addJournalBody(appPreference: self.appPreference,
                                                  title: audioToTextJournal.caption ?? "",
                                                  textDescrip: audioToTextJournal.transcribingText ?? "",
                                                  type: Constant.JournalType.VOICE_TO_TEXT)
        }
        else {
            jsonBody = RequestBody.meditationCompleteBody(appPreference: self.appPreference,
                                                          title: audioToTextJournal.caption ?? "",
                                                          textDescrip: audioToTextJournal.transcribingText ?? "",
                                                          medCompObj: self.mediCompleteObj, type: Constant.JournalType.VOICE_TO_TEXT)
        }

        WWMHelperClass.showLoaderAnimate(on: self.view)
        DataManager.sharedInstance.addJournalAPI(body: jsonBody) { (isSuccess, journalId, error) in
            
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
                self.errorAlert(title: "Error!", msg: error)
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
        else if segue.identifier == "AudioEntryIdentifier" {
            if let viewController2 = segue.destination as? AudioContainerVC {
                self.audioContainerVC = viewController2
            }
        }
        else if segue.identifier == "AudioToTextEntryIdentifier" {
            if let viewController2 = segue.destination as? AudioToTextContainerVC {
                self.audioToTextContainerVC = viewController2
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

