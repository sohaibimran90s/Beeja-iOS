//
//  WWMMoodMeterLogVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 10/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import AVFoundation
import IQKeyboardManagerSwift

class WWMMoodMeterLogVC: WWMBaseViewController {

    var moodData = WWMMoodMeterData()
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var lblExpressMood: UILabel!
    @IBOutlet weak var btnBurnMood: UIButton!
    @IBOutlet weak var btnLogExperience: UIButton!
    @IBOutlet weak var txtViewLog: UITextView!
    @IBOutlet weak var lblTextCount: UILabel!

    let appPreffrence = WWMAppPreference()
    
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
    
    var alertPopup = WWMAlertPopUp()
    
    var tap = UITapGestureRecognizer()
    var selectedIndex = "-1"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = KDONE
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.view.addGestureRecognizer(gesture)

        self.setUpUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.player?.pause()
        self.stopPlayer()
    }
    
    //MARK: Stop Payer
    func stopPlayer() {
        if let play = self.player {
            //print("stopped")
            play.pause()
            self.player = nil
            //print("player deallocated")
        } else {
            //print("player was already deallocated")
        }
    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        self.txtViewLog.resignFirstResponder()
    }
    
    @objc func KeyPadTap() -> Void {
        self.view.endEditing(true)
    }

    func setUpUI() {
        self.navigationController?.isNavigationBarHidden = true
        
        let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let attributeString = NSMutableAttributedString(string: KSKIP,
                                                        attributes: attributes)
        btnSkip.setAttributedTitle(attributeString, for: .normal)
        
        self.btnBurnMood.layer.borderWidth = 2.0
        self.btnBurnMood.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.btnLogExperience.layer.borderWidth = 2.0
        self.btnLogExperience.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        self.txtViewLog.delegate = self
        
        if moodData.name != ""{
            self.lblExpressMood.text = "\(moodData.name)"
        }else{
            self.lblExpressMood.text = ""
        }
        
        //print("oodData.show_burn... \(moodData.show_burn)")
        if !moodData.show_burn {
            btnBurnMood.isHidden = true
        }
        
        if self.type == "pre"{
            if !moodData.show_burn {
                btnBurnMood.isHidden = true
                btnLogExperience.isHidden = false
            }else{
                btnBurnMood.isHidden = false
                btnLogExperience.isHidden = true
            }
        }
        
        if moodData.name != "" {
            self.txtViewLog.text = "I am feeling \(moodData.name.uppercased()) because"
            self.checkAnalyticStr = self.txtViewLog.text
            self.lblTextCount.text = "\(self.txtViewLog.text.count)/1500"
        }
        
        self.txtViewLog.layer.cornerRadius = 5.0
    }
    
    // MARK:- Button Action
    
    @IBAction func btnEditTextAction(_ sender: Any) {
        self.txtViewLog.isEditable = true
        self.txtViewLog.becomeFirstResponder()
    }
    
    @IBAction func btnSkipAction(_ sender: Any) {
        self.txtViewLog.text = ""
        
        DispatchQueue.global(qos: .background).async {
            self.completeMeditationAPI()
        }
        
        self.logExperience()
    }
    
    @IBAction func btnBurnMoodAction(_ sender: Any) {
        self.createBackground(name: "Burn", type: "mov")
    }
    
    func createBackground(name: String, type: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else { return }
        
        player = AVPlayer(url: URL(fileURLWithPath: path))
        player?.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none;
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        self.view.layer.addSublayer(playerLayer)
        player?.seek(to: CMTime.zero)
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        player?.play()
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        if self.type == "pre" {
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.popToRootViewController(animated: false)
        }else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodJournalVC") as! WWMMoodJournalVC
                vc.type = self.type
                vc.prepTime = self.prepTime
                vc.meditationTime = self.meditationTime
                vc.restTime = self.restTime
                vc.meditationID = self.meditationID
                vc.levelID = self.levelID
                vc.moodData = self.moodData
                vc.category_Id = self.category_Id
                vc.emotion_Id = self.emotion_Id
                vc.audio_Id = self.audio_Id
                vc.rating = self.rating
                vc.watched_duration = self.watched_duration
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnLogExperienceAction(_ sender: Any) {
        if  txtViewLog.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_JournalMessage, title: kAlertTitle)
        }else {
        
            self.getPrePostMoodData()
            
            DispatchQueue.global(qos: .background).async {
                self.completeMeditationAPI()
            }
            self.logExperience()
        }
    }
    
    func getPrePostMoodData(){
        if KUSERDEFAULTS.bool(forKey: "getPrePostMoodBool"){
            if self.type == "pre" {
                let getPreJournalCount = self.appPreference.getPreJournalCount()
                if getPreJournalCount < 7 && getPreJournalCount != 0{
                    self.appPreference.setPreJournalCount(value: self.appPreference.getPreJournalCount() - 1)
                }
            }else{
                let getPostJournalCount = self.appPreference.getPostJournalCount()
                if getPostJournalCount < 7 && getPostJournalCount != 0{
                    self.appPreference.setPostJournalCount(value: self.appPreference.getPostJournalCount() - 1)
                }
            }
        }
    }
    
    func xibCall(){
        alertPopup = UINib(nibName: "WWMAlertPopUp", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertPopUp
        let window = UIApplication.shared.keyWindow!
        
        alertPopup.lblTitle.text = self.popupTitle
        alertPopup.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        UIView.transition(with: alertPopup, duration: 1.0, options: .transitionCrossDissolve, animations: {
            window.rootViewController?.view.addSubview(self.alertPopup)
        }) { (Bool) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.alertPopup.removeFromSuperview()
                self.navigateToDashboard()
            }
        }
    }
    
    func completeMeditationAPI() {
        
        let nintyFivePercentDB = WWMHelperClass.fetchDB(dbName: "DBNintyFiveCompletionData") as! [DBNintyFiveCompletionData]
        if nintyFivePercentDB.count > 0{
            WWMHelperClass.deleteRowfromDb(dbName: "DBNintyFiveCompletionData", id: "\(nintyFivePercentDB.count - 1)", type: "id")
        }
        
        var param: [String: Any] = [:]
        
        if self.appPreference.getType() == "learn"{
            param = [
                "type":"learn",
                "step_id": WWMHelperClass.step_id,
                "mantra_id": WWMHelperClass.mantra_id,
                "category_id" : self.category_Id,
                "emotion_id" : self.emotion_Id,
                "audio_id" : self.audio_Id,
                "guided_type" : self.userData.guided_type,
                "duration" : self.watched_duration,
                "rating" : self.rating,
                "user_id":self.appPreference.getUserID(),
                "meditation_type":type,
                "date_time":"\(Int(Date().timeIntervalSince1970*1000))",
                "tell_us_why":txtViewLog.text ?? "",
                "prep_time":prepTime,
                "meditation_time":meditationTime,
                "rest_time":restTime,
                "meditation_id": self.meditationID,
                "level_id":self.levelID,
                "mood_id": Int(self.appPreference.getMoodId()) ?? 0,
                "complete_percentage": WWMHelperClass.complete_percentage,
                "is_complete": "1",
                "journal_type": ""
                ] as [String : Any]
        }else{
            param = [
                "type": self.appPreffrence.getType(),
                "category_id" : self.category_Id,
                "emotion_id" : self.emotion_Id,
                "audio_id" : self.audio_Id,
                "guided_type" : self.appPreffrence.getGuideType(),
                "watched_duration" : self.watched_duration,
                "rating" : self.rating,
                "user_id":self.appPreference.getUserID(),
                "meditation_type":type,
                "date_time":"\(Int(Date().timeIntervalSince1970*1000))",
                "tell_us_why":txtViewLog.text ?? "",
                "prep_time":prepTime,
                "meditation_time":meditationTime,
                "rest_time":restTime,
                "meditation_id": self.meditationID,
                "level_id":self.levelID,
                "mood_id": Int(self.appPreference.getMoodId()) ?? 0,
                "complete_percentage": WWMHelperClass.complete_percentage,
                "is_complete": "1",
                "journal_type": ""
                ] as [String : Any]
        }
        
        //print("param meterlog... \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONCOMPLETE, context: "WWMMoodMeterLogVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let _ = result["success"] as? Bool {
                    //print("success moodmeterlogvc background api run")
                    self.appPreffrence.setSessionAvailableData(value: true)
                    self.meditationHistoryListAPI()

                    WWMHelperClass.complete_percentage = "0"
                    
                    //self.logExperience()
                }else {
                    self.saveToDB(param: param)
                }
            }else {
                self.saveToDB(param: param)
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
    
    func logExperience() {
        
        // Analytics
        if self.txtViewLog.text == "" {
            WWMHelperClass.sendEventAnalytics(contentType: "JOURNALENTRY", itemId: "SKIPPED", itemName: "")
        }else if self.txtViewLog.text == self.checkAnalyticStr {
            WWMHelperClass.sendEventAnalytics(contentType: "JOURNALENTRY", itemId: "EMPTY", itemName: "")
        }else {
            WWMHelperClass.sendEventAnalytics(contentType: "JOURNALENTRY", itemId: "POPULATED", itemName: "")
        }
        
        if self.txtViewLog.text != "" {
            if self.selectedIndex != "-1"{
                self.popupTitle = KMEDITATIONUPDATED
            }else{
                self.popupTitle = KJOURNALUPDATED
            }
            
            self.xibCall()
        }else {
            if self.hidShowMoodMeter == "Show"{
                if self.selectedIndex != "-1"{
                    self.popupTitle = KMOODTRACKERUPDATED
                    self.xibCall()
                }else{
                    self.navigateToDashboard()
                }
            }else{
                self.navigateToDashboard()
            }
        }
    }
    
    
    func navigateToDashboard() {
        
        //print("self.type..... \(self.type)")
        if self.appPreference.getType() == "learn"{
            if self.type == "pre" {
                self.navigationController?.isNavigationBarHidden = false
                self.navigationController?.popToRootViewController(animated: false)
            }else {
                
                if self.appPreference.get21ChallengeName() == "30 Day Challenge"{
                    self.nextVC()
                }else{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMFAQsVC") as! WWMFAQsVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else{
            if self.type == "pre" {
                self.navigationController?.isNavigationBarHidden = false
                self.navigationController?.popToRootViewController(animated: false)
            }else {
                self.nextVC()
             }
        }
    }
    
    func nextVC(){
        if !self.moodData.show_burn && self.moodData.id != -1 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodShareVC") as! WWMMoodShareVC
            vc.moodData = self.moodData
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
    
    //MeditationHistoryList API
    func meditationHistoryListAPI() {
        
        let param = ["user_id": self.appPreffrence.getUserID()]
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
                //print("url MedHist....****** \(URL_MEDITATIONHISTORY+"/page=1") param MedHist....****** \(param) result medHist....****** \(result) success WWMStartTimerVC meditationhistoryapi in background thread")
            }
        }
    }
}

extension WWMMoodMeterLogVC: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        self.lblTextCount.text = "\(self.txtViewLog.text.count)/1500"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (txtViewLog.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 1501
    }
}
