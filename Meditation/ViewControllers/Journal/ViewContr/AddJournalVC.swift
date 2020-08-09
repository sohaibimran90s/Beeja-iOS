//
//  AddJournalVC.swift
//  MeditationDemo
//
//  Created by Ehsan on 22/6/20.
//  Copyright © 2020 Ehsan. All rights reserved.
//

import UIKit
import Alamofire
import IQKeyboardManagerSwift

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
    
    let kDataManager = DataManager.sharedInstance

    //=========== for API call Meditation complete
    var mediCompleteObj = MeditationComplete()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Add Text Entry"
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = KDONE
        
        self.logExprnctBtn.layer.cornerRadius = 20
        self.logExprnctBtn.layer.borderColor = UIColor(hexString: "#00EBA9")?.cgColor
        self.logExprnctBtn.layer.borderWidth = 2.0
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(UIImage(named: "CloseBtn.png"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(closeButtonAction), for: UIControl.Event.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.contentHorizontalAlignment = .right
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "Maax-Bold", size: 16.0)!]
        
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
        
        NotificationCenter.default.post(name: Notification.Name(Constant.kNotificationInAudioJournal), object: nil)
        NotificationCenter.default.post(name: Notification.Name(Constant.kNotificationInAudioToTextJournal), object: nil)

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
            self.title = "Add Text Entry"
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
            self.title = "Add Image Entry"
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
            self.title = "Add Voice Entry"
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
            self.title = "Add Voice to Text Entry"
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
                Utilities.paymentController(container: self)
            }
            
        case .AudioToTextEntry:
            if (kDataManager.isPaidAc){
                self.audioToTextJournalLog()
            }
            else {
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
            WWMHelperClass.sendEventAnalytics(contentType: "PRE_JOURNAL ", itemId: "SUBMIT", itemName: "ADD_TEXT_ENTRY")
            jsonBody = RequestBody.addJournalBody(appPreference: self.appPreference, title: textJournal.title ?? "",
                                                  textDescrip: textJournal.textDescription ?? "",
                                                  type: Constant.JournalType.TEXT)
        }
        else {
            WWMHelperClass.sendEventAnalytics(contentType: "POST_JOURNAL ", itemId: "SUBMIT", itemName: "ADD_TEXT_ENTRY")
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
                //Prashant
                //self.navigateToDashboard()
                self.completeMeditationAPI()
//                self.navigationController!.popToRootViewController(animated: true)
                //-------------------------
            }
            return
        }
            
        var imgDataArray: [Data] = []
        for img in imgArray {
            let imageData = img.jpegData(compressionQuality: 0.20)!
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
                    //Prashant
                    //self.navigateToDashboard()
                    self.completeMeditationAPI()
//                    self.navigationController!.popToRootViewController(animated: true)
                    //-------------------------
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
            WWMHelperClass.sendEventAnalytics(contentType: "PRE_JOURNAL ", itemId: "SUBMIT", itemName: "ADD_IMAGE_ENTRY")
            jsonBody = RequestBody.addJournalBody(appPreference: self.appPreference,
                                                      title: "", textDescrip: imageJournal.title ?? "",
                                                      type: Constant.JournalType.IMAGE)
        }
        else {
            WWMHelperClass.sendEventAnalytics(contentType: "POST_JOURNAL ", itemId: "SUBMIT", itemName: "ADD_IMAGE_ENTRY")
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
            let imageData = thumbImg.jpegData(compressionQuality: 0.20)!
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
                    //Prashant
                    //self.navigateToDashboard()
                    self.completeMeditationAPI()
//                    self.navigationController!.popToRootViewController(animated: true)
                    //-------------------------
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
            WWMHelperClass.sendEventAnalytics(contentType: "PRE_JOURNAL ", itemId: "SUBMIT", itemName: "ADD_VOICE_ENTRY")
            jsonBody = RequestBody.addJournalBody(appPreference: self.appPreference,
                                                  title: "",
                                                  textDescrip: audioJournal.caption ?? "", type: Constant.JournalType.VOICE)
        }
        else {
            WWMHelperClass.sendEventAnalytics(contentType: "POST_JOURNAL ", itemId: "SUBMIT", itemName: "ADD_VOICE_ENTRY")
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
                    //Prashant
                    //self.navigateToDashboard()
                    self.completeMeditationAPI()
//                    self.navigationController!.popToRootViewController(animated: true)
                    //-------------------------
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
            WWMHelperClass.sendEventAnalytics(contentType: "PRE_JOURNAL ", itemId: "SUBMIT", itemName: "ADD_VOICE_TO_TEXT_ENTRY")
            jsonBody = RequestBody.addJournalBody(appPreference: self.appPreference,
                                                  title: audioToTextJournal.caption ?? "",
                                                  textDescrip: audioToTextJournal.transcribingText ?? "",
                                                  type: Constant.JournalType.VOICE_TO_TEXT)
        }
        else {
            WWMHelperClass.sendEventAnalytics(contentType: "POST_JOURNAL ", itemId: "SUBMIT", itemName: "ADD_VOICE_TO_TEXT_ENTRY")
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
                    //Prashant
                    //self.navigateToDashboard()
                    self.completeMeditationAPI()
//                    self.navigationController!.popToRootViewController(animated: true)
                    //-------------------------
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
    
    func completeMeditationAPI() {
        
        let nintyFivePercentDB = WWMHelperClass.fetchDB(dbName: "DBNintyFiveCompletionData") as! [DBNintyFiveCompletionData]
        if nintyFivePercentDB.count > 0{
            WWMHelperClass.deleteRowfromDb(dbName: "DBNintyFiveCompletionData", id: "\(nintyFivePercentDB.count - 1)", type: "id")
        }
                
        var param: [String: Any] = [:]
        param = [
            "type": self.appPreference.getType(),
            "step_id": WWMHelperClass.step_id,
            "mantra_id": WWMHelperClass.mantra_id,
            "category_id" : mediCompleteObj.category_Id,
            "emotion_id" : mediCompleteObj.emotion_Id,
            "audio_id" : mediCompleteObj.audio_Id,
            "guided_type" : self.appPreference.getGuideType(),
            "duration" : mediCompleteObj.watched_duration,
            "watched_duration" : mediCompleteObj.watched_duration,
            "rating" : mediCompleteObj.rating,
            "user_id":self.appPreference.getUserID(),
            "meditation_type":mediCompleteObj.type,
            "date_time":"\(Int(Date().timeIntervalSince1970*1000))",
            "tell_us_why":"",
            "prep_time":mediCompleteObj.prepTime,
            "meditation_time":mediCompleteObj.meditationTime,
            "rest_time":mediCompleteObj.restTime,
            "meditation_id": mediCompleteObj.meditationID,
            "level_id":mediCompleteObj.levelID,
            "mood_id": Int(self.appPreference.getMoodId()) ?? 0,
            "complete_percentage": WWMHelperClass.complete_percentage,
            "is_complete": "1",
            "title": "",
            "journal_type": "",
            "challenge_day_id":WWMHelperClass.day_30_name,
            "challenge_type":WWMHelperClass.day_type

            ] as [String : Any]
        
        //print("param meterlog... \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONCOMPLETE, context: "WWMMoodMeterLogVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                self.appPreference.setSessionAvailableData(value: true)
                self.meditationHistoryListAPI()
                WWMHelperClass.complete_percentage = "0"
                self.navigationController?.isNavigationBarHidden = true
                self.navigateToDashboard()
            }else {
                self.saveToDB(param: param)
                self.navigationController?.isNavigationBarHidden = true
                self.navigateToDashboard()
            }
        }
    }
    
    func saveToDB(param:[String:Any]) {
        let meditationDB = WWMHelperClass.fetchEntity(dbName: "DBMeditationComplete") as! DBMeditationComplete
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: param, options:.prettyPrinted)
        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        meditationDB.meditationData = myString
        WWMHelperClass.saveDb()
        //self.logExperience()
    }

    
    //MeditationHistoryList API
        func meditationHistoryListAPI() {
            
            let param = ["user_id": self.appPreference.getUserID()]
            WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONHISTORY+"?page=1", context: "WWMHomeTabVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
                if sucess {
                    if let data = result["data"] as? [String: Any]{
                        if let records = data["records"] as? [[String: Any]]{
                            
                            let meditationHistoryData = WWMHelperClass.fetchDB(dbName: "DBMeditationHistory") as! [DBMeditationHistory]
                            if meditationHistoryData.count > 0 {
                                WWMHelperClass.deletefromDb(dbName: "DBMeditationHistory")
                            }
                            
                            for dict in records{
                                let dbMeditationHistory = WWMHelperClass.fetchEntity(dbName: "DBMeditationHistory") as! DBMeditationHistory
                                let jsonData: Data? = try? JSONSerialization.data(withJSONObject: dict, options:.prettyPrinted)
                                let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                                dbMeditationHistory.data = myString
                                WWMHelperClass.saveDb()
                                
                            }
                        }
                    }
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationMeditationHistory"), object: nil)
                    //print("url MedHist....****** \(URL_MEDITATIONHISTORY+"/page=1") param MedHist....****** \(param) result medHist....****** \(result)")
                    //print("success WWMStartTimerVC meditationhistoryapi in background thread")
                }
            }
        
    }
    
    //Prashant
    //MARK:- mood share
    func navigateToDashboard() {
        
        //print("self.type..... \(self.type)")
        if self.appPreference.getType() == "learn"{
            if self.mediCompleteObj.type == "pre" {
                self.navigationController?.isNavigationBarHidden = false
                self.navigationController?.popToRootViewController(animated: false)
            }else {
                
                if self.appPreference.get21ChallengeName() == "30 Day Challenge"{
                    if WWMHelperClass.day_30_name == "7" || WWMHelperClass.day_30_name == "14" || WWMHelperClass.day_30_name == "21" || WWMHelperClass.day_30_name == "28"{
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMilestoneAchievementVC") as! WWMMilestoneAchievementVC
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else{
                        self.nextVC()
                    }
                }else if self.appPreference.get21ChallengeName() == "8 Weeks Challenge"{
                    self.nextVC()
                }else{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMFAQsVC") as! WWMFAQsVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else{
            if self.mediCompleteObj.type == "pre" {
                self.navigationController?.isNavigationBarHidden = false
                self.navigationController?.popToRootViewController(animated: false)
            }else {
                self.nextVC()
             }
        }
        
        WWMHelperClass.complete_percentage = "0"
        WWMHelperClass.day_type = ""
        WWMHelperClass.day_30_name = ""
    }
    
    func nextVC(){
        if !self.mediCompleteObj.moodData.show_burn && self.mediCompleteObj.moodData.id != -1 {
            let story = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = story.instantiateViewController(withIdentifier: "WWMMoodShareVC") as! WWMMoodShareVC
            vc.moodData = self.mediCompleteObj.moodData
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            
            if (self.appPreference.get21ChallengeName() == "7 Days challenge") && (WWMHelperClass.days21StepNo == "Step 7" || WWMHelperClass.days21StepNo == "Step 14" || WWMHelperClass.days21StepNo == "Step 21") && WWMHelperClass.stepsCompleted == false{
                
                WWMHelperClass.days21StepNo = ""
                WWMHelperClass.stepsCompleted = false
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM21DaySetReminderVC") as! WWM21DaySetReminderVC
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else{
                self.callHomeController()
            }
        }

    }
    
    func callHomeController(){
        self.navigationController?.isNavigationBarHidden = false
        
        if let tabController = self.tabBarController as? WWMTabBarVC {
            tabController.selectedIndex = 4
            for index in 0..<tabController.tabBar.items!.count {
                let item = tabController.tabBar.items![index]
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
                if index == 4 {
                    item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
                }
            }
        }
        self.navigationController?.popToRootViewController(animated: false)
    }
}

