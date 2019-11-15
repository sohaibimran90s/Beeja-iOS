//
//  WWMMoodJournalVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 18/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class WWMMoodJournalVC: WWMBaseViewController {

    @IBOutlet weak var txtViewLog: UITextView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var lblTextCount: UILabel!
    
    let appPreffrence = WWMAppPreference()
    
    var type = ""   // Pre | Post
    var prepTime = 0
    var meditationTime = 0
    var restTime = 0
    var meditationID = ""
    var levelID = ""
    var moodData = WWMMoodMeterData()
    var category_Id = "0"
    var emotion_Id = "0"
    var audio_Id = "0"
    var watched_duration = "0"
    var rating = "0"
    
    var tap = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = KNEXT
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.view.addGestureRecognizer(gesture)

        self.setUpUI()
    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        self.txtViewLog.resignFirstResponder()
    }
    
    @objc func KeyPadTap() -> Void {
        self.view.endEditing(true)
    }
    
    func setUpUI() {
        
        self.txtViewLog.delegate = self
        
        let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let attributeString = NSMutableAttributedString(string: KSKIP,
                                                        attributes: attributes)
        btnSkip.setAttributedTitle(attributeString, for: .normal)
        
        self.btnSubmit.layer.borderWidth = 2.0
        self.btnSubmit.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        self.txtViewLog.layer.borderColor = UIColor.lightGray.cgColor
        self.txtViewLog.layer.borderWidth = 1.0
        self.txtViewLog.layer.cornerRadius = 2.0
    }
    
    // MARK:- Button Action
    
    @IBAction func btnEditTextAction(_ sender: Any) {
        self.txtViewLog.isEditable = true
        self.txtViewLog.becomeFirstResponder()
    }
    
    @IBAction func btnSkipAction(_ sender: Any) {
        // Analytics
        WWMHelperClass.sendEventAnalytics(contentType: "JOURNALENTRY", itemId: "SKIPPED", itemName: "")
        
        self.txtViewLog.text = ""
        
        DispatchQueue.global(qos: .background).async {
            self.completeMeditationAPI()
        }
        self.logExperience()
    }
    
    @IBAction func btnSubmitAction(_ sender: Any) {
        if  txtViewLog.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: KTIMETOUPDATEJOUR, title: kAlertTitle)
        }else {
            
            if KUSERDEFAULTS.bool(forKey: "getPrePostMoodBool"){
                if self.type == "pre"{
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
            
            DispatchQueue.global(qos: .background).async {
                self.completeMeditationAPI()
            }
            // Analytics
            WWMHelperClass.sendEventAnalytics(contentType: "JOURNALENTRY", itemId: "POPULATED", itemName: "")
            self.logExperience()
        }
    }

    
    func completeMeditationAPI() {

        var param: [String: Any] = [:]
        
        print("WWMHelperClass.selectedType... \(WWMHelperClass.selectedType)")
        
        if WWMHelperClass.selectedType == "learn"{
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
                "mood_id":self.moodData.id == -1 ? "1" : self.moodData.id,
                ] as [String : Any]

        }else{
            param = [
                "type":self.userData.type,
                "category_id" : self.category_Id,
                "emotion_id" : self.emotion_Id,
                "audio_id" : self.audio_Id,
                "guided_type" : self.userData.guided_type,
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
                "mood_id":self.moodData.id == -1 ? "1" : self.moodData.id,
                "complete_percentage": WWMHelperClass.complete_percentage
                ] as [String : Any]
        }
        
        print("journal param... \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONCOMPLETE, context: "WWMMoodJournalVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let _ = result["success"] as? Bool {
                    print("success moodjournalvc background meditationcomplete api...")
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
        
        if WWMHelperClass.selectedType == "learn"{
            if WWMHelperClass.step_id == 12{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMFAQsVC") as! WWMFAQsVC
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                callHomeController()
            }
        }else{
            callHomeController()
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
                print("url MedHist....****** \(URL_MEDITATIONHISTORY+"/page=1") param MedHist....****** \(param) result medHist....****** \(result)")
                print("success moodjournalVC meditationhistoryapi in background thread")
            }
        }
    }
}

extension WWMMoodJournalVC: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        self.lblTextCount.text = "\(self.txtViewLog.text.count)/1500"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (txtViewLog.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 1501
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //self.view.removeGestureRecognizer(tap)
        if  txtViewLog.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: KTIMETOUPDATEJOUR, title: kAlertTitle)
        }else {
            DispatchQueue.global(qos: .background).async {
                self.completeMeditationAPI()
            }
            // Analytics
            WWMHelperClass.sendEventAnalytics(contentType: "JOURNALENTRY", itemId: "POPULATED", itemName: "")
            self.logExperience()
        }
    }
}

