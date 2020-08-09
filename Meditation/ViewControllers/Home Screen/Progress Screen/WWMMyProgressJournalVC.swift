//
//  WWMMyProgressJournalVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 09/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import XLPagerTabStrip

class WWMMyProgressJournalVC: WWMBaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableViewJournal: UITableView!
    
    var journalView = WWMAddJournalView()
    var journalData = [WWMJournalProgressData]()
    var alertPopupView1 = WWMAlertController()
    
    var alertJournalPopup = WWMJouranlPopUp()
    // var alertPopupView = WWMAlertController()
    var tap = UITapGestureRecognizer()
    let reachable = Reachabilities()
    
    var itemInfo: IndicatorInfo = "View"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tap = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = KNEXT
    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        journalView.txtViewJournal.resignFirstResponder()
    }
    
    @objc func KeyPadTap() -> Void {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getJournalList()
    }
    
    // MARK:- UITableView Delegates Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journalData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Prashant
        let data = journalData[indexPath.row]
        if data.assets_images.count > 0 {
            let cellImage = tableView.dequeueReusableCell(withIdentifier: "WWMJournalImageTableViewCell") as! WWMJournalImageTableViewCell
            cellImage.assignValues(data: data)
            return cellImage
        }
        else if data.assets_audios.count > 0 {
            let cellAudio = tableView.dequeueReusableCell(withIdentifier: "WWMJournalAudioTableViewCell") as! WWMJournalAudioTableViewCell
            cellAudio.assignValues(data: data)
            return cellAudio
        }
        //------------------------
            
        else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? WWMJournalTableViewCell {
                cell.viewShadow.layer.shadowColor = UIColor.black.cgColor
                cell.viewShadow.layer.shadowOpacity = 0.3
                cell.viewShadow.layer.shadowRadius = 5.0
                cell.viewShadow.layer.cornerRadius = 5.0
                cell.viewShadow.layer.masksToBounds = false
                
                cell.lblJournalDesc.adjustsFontSizeToFitWidth = false
                cell.lblJournalDesc.lineBreakMode = .byTruncatingTail
                
                cell.lblJournalDesc.text = data.text
                
                if data.mood_status.lowercased() == "post" {
                    cell.lblMeditationType.text = KPOSTMEDITATION
                }else if data.mood_status.lowercased() == "pre" {
                    cell.lblMeditationType.text = KPREMEDITATION
                }else if cell.lblJournalDesc.text?.contains("Journaling works best when we simply pour out a stream of consciousness into our") ?? false{
                    cell.lblMeditationType.text = "How to journal"
                }else if cell.lblJournalDesc.text?.contains("Keeping a journal is an amazing way to start and end your day") ?? false{
                    cell.lblMeditationType.text = "Why Journal"
                }else{
                    cell.lblMeditationType.text = "Journal Entry"
                }
                
                let date = Date(timeIntervalSince1970: Double(data.date_time)!/1000)
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.current
                dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
                dateFormatter.timeZone = TimeZone(abbreviation: dateFormatter.timeZone.abbreviation() ?? "GMT")
                
                dateFormatter.dateFormat = "EEEE, hh:mm a" //Spegicify your format that you want
                let strWeekDayAndtime = dateFormatter.string(from: date)
                cell.lblWeekDayAndTime.text = strWeekDayAndtime
                
                dateFormatter.dateFormat = "dd"
                
                cell.lblDateDay.text = dateFormatter.string(from: date)
                
                dateFormatter.dateFormat = "MMM"
                cell.lblDateMonth.text = dateFormatter.string(from: date)
                
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Prashant
        //1. text only
        let data = journalData[indexPath.row]
        if data.assets_images.count == 0 && data.assets_audios.count == 0 {
            WWMHelperClass.sendEventAnalytics(contentType: "JOURNAL ", itemId: "JOURNAL_DETAIL_VIEW", itemName: "VIEW_TEXT_ENTRY")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMyProgressJournalDetailVC") as! WWMMyProgressJournalDetailVC
            let cell = tableView.cellForRow(at: indexPath) as! WWMJournalTableViewCell

            vc.lblTitle = cell.lblMeditationType.text ?? ""
            vc.lblDesc = cell.lblJournalDesc.text ?? ""
            vc.lblDateDay1 = cell.lblDateDay.text ?? ""
            vc.lblDateMonth1 = cell.lblDateMonth.text ?? ""
            vc.lblWeekDayAndTime1 = cell.lblWeekDayAndTime.text ?? ""

            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if data.assets_images.count > 0 {
            //2. image and text
            WWMHelperClass.sendEventAnalytics(contentType: "JOURNAL ", itemId: "JOURNAL_DETAIL_VIEW", itemName: "VIEW_IMAGE_ENTRY")
            let story = UIStoryboard.init(name: "JournalDetails", bundle: nil)
            let vc = story.instantiateViewController(withIdentifier: "WWMMyProgressJournalImageDetailVC") as! WWMMyProgressJournalImageDetailVC
            let cell = tableView.cellForRow(at: indexPath) as! WWMJournalImageTableViewCell
            
            vc.lblTitle = cell.lblMeditationType.text ?? ""
            vc.lblDesc = cell.lblJournalDesc.text ?? ""
            vc.lblDateDay1 = cell.lblDateDay.text ?? ""
            vc.lblDateMonth1 = cell.lblDateMonth.text ?? ""
            vc.lblWeekDayAndTime1 = cell.lblWeekDayAndTime.text ?? ""
            vc.arrImages = data.assets_images
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if data.assets_audios.count > 0 {
            //3. audio and text
            WWMHelperClass.sendEventAnalytics(contentType: "JOURNAL ", itemId: "JOURNAL_DETAIL_VIEW", itemName: "VIEW_VOICE_ENTRY")
            let story = UIStoryboard.init(name: "JournalDetails", bundle: nil)
            let vc = story.instantiateViewController(withIdentifier: "WWMMyProgressJournalAudioDetailVC") as! WWMMyProgressJournalAudioDetailVC
            let cell = tableView.cellForRow(at: indexPath) as! WWMJournalAudioTableViewCell
            
            vc.lblTitle = cell.lblMeditationType.text ?? ""
            vc.lblDesc = cell.lblJournalDesc.text ?? ""
            vc.lblDateDay1 = cell.lblDateDay.text ?? ""
            vc.lblDateMonth1 = cell.lblDateMonth.text ?? ""
            vc.lblWeekDayAndTime1 = cell.lblWeekDayAndTime.text ?? ""
            vc.arrAudio = data.assets_audios
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        //--------------------------
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        //Prashant
        let data = journalData[indexPath.row]
        if data.assets_images.count > 0 {
            return 200
        }
        else if data.assets_audios.count > 0 {
            return 160
        }
        else {
            return 105
        }
        //------------------------------
    }
    
    
    func getJournalList() {
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = ["user_id" : self.appPreference.getUserID(),
                     "med_type" : self.appPreference.getType()]
        
        //print("jounallist.... \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_JOURNALMYPROGRESS, context: "WWMMyProgressJournalVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let arrJournal = result["result"] as? [[String:Any]] {
                    var moodData = WWMHelperClass.fetchDB(dbName: "DBJournalList") as! [DBJournalList]
                    if moodData.count > 0 {
                        var flag = false
                        for i in 0..<moodData.count {
                            let db = moodData[i]
                            //print("db.meditation_type+++ \(db.meditation_type) self.appPreference.getType()+++ \(self.appPreference.getType())")
                            if db.meditation_type == "\(self.appPreference.getType())" {
                                moodData.remove(at: i)
                                let dbJournal = WWMHelperClass.fetchEntity(dbName: "DBJournalList") as! DBJournalList
                                let jsonData: Data? = try? JSONSerialization.data(withJSONObject: arrJournal, options:.prettyPrinted)
                                let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                                dbJournal.data = myString
                                dbJournal.meditation_type = "\(self.appPreference.getType())"
                                WWMHelperClass.saveDb()
                                flag = true
                                break
                            }
                        }
                        if !flag {
                            let dbJournal = WWMHelperClass.fetchEntity(dbName: "DBJournalList") as! DBJournalList
                            let jsonData: Data? = try? JSONSerialization.data(withJSONObject: arrJournal, options:.prettyPrinted)
                            let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                            dbJournal.data = myString
                            dbJournal.meditation_type = "\(self.appPreference.getType())"
                            WWMHelperClass.saveDb()
                        }
                    }else {
                        let dbJournal = WWMHelperClass.fetchEntity(dbName: "DBJournalList") as! DBJournalList
                        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: arrJournal, options:.prettyPrinted)
                        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                        dbJournal.data = myString
                        dbJournal.meditation_type = "\(self.appPreference.getType())"
                        WWMHelperClass.saveDb()
                    }
                    
                    self.journalData.removeAll()
                    for dict in arrJournal {
                        let journal = WWMJournalProgressData.init(json: dict)
//                        if let imageData = dict["assets_images"] as? [String : Any] {
//                            journal.assets_images = WWMJournalImageData.init(json: imageData)
//                        }
                        self.journalData.append(journal)
                    }
                    self.tableViewJournal.reloadData()
                    
                }else {
                    self.fetchDataFromDB()
                }
                
            }else {
                self.fetchDataFromDB()
            }
            //WWMHelperClass.dismissSVHud()
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    func fetchDataFromDB() {
        let journalDataDB = WWMHelperClass.fetchDB(dbName: "DBJournalList") as! [DBJournalList]
        if journalDataDB.count > 0 {
            
            //print("self.appPreference.getType()... \(self.appPreference.getType()) journalDataDB.count... \(journalDataDB.count)")
            for dict in journalDataDB {
                if dict.meditation_type == "\(self.appPreference.getType())" {
                    if let jsonResult = self.convertToDictionaryArray(text: dict.data ?? "") {
                        
                        self.journalData.removeAll()
                        for dict in jsonResult {
                            let journal = WWMJournalProgressData.init(json: dict)
                            if self.journalData.count < 10 {
                                self.journalData.append(journal)
                            }
                        }
                    }
                }
            }
        }
        
        if !reachable.isConnectedToNetwork() {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validatation_JournalOfflineMsg, title: kAlertTitle)
        }
        self.tableViewJournal.reloadData()
    }
    
    
    func convertToDictionaryArray(text: String) -> [[String: Any]]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    @IBAction func btnAddJournalAction(_ sender: Any) {
        
        // Ehsan
        let vc = UIStoryboard(name: "Journal", bundle: nil).instantiateViewController(withIdentifier: "AddJournal") as! AddJournalVC
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .overFullScreen
        vc.isAddJournal = true
        self.present(navController, animated: false, completion: nil)
        
        return
        
        if KUSERDEFAULTS.bool(forKey: "getPrePostMoodBool"){
            
            
            let getPostJournalCount = self.appPreference.getPostJournalCount()
            if getPostJournalCount == 0{
                self.getFreeMoodMeterAlert(freeMoodMeterCount: "", title: KSUBSPLANEXP, subTitle: KNOFREEJOURNAL, type: "post")
            }else{
                
                //self.getFreeMoodMeterAlert(freeMoodMeterCount: "", title: KSUBSPLANEXP, subTitle: "\(KYOUHAVE) \(getPostJournalCount) \(KNOFREEJOURNALMSG)", type: "Post")
                
                if KUSERDEFAULTS.bool(forKey: "getPrePostMoodBool"){
                    xibJournalView()
                    
                }else{
                    self.alertPopupView1.removeFromSuperview()
                    
                }
            }
        }else{
            xibJournalView()
        }
    }
    
    func getFreeMoodMeterAlert(freeMoodMeterCount: String, title: String, subTitle: String, type: String){
        self.alertPopupView1 = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        self.alertPopupView1.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        
        self.alertPopupView1.lblTitle.numberOfLines = 0
        self.alertPopupView1.btnOK.layer.borderWidth = 2.0
        self.alertPopupView1.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        self.alertPopupView1.lblTitle.text = title
        self.alertPopupView1.lblSubtitle.text = subTitle
        self.alertPopupView1.btnClose.isHidden = true
        
        self.alertPopupView1.btnOK.addTarget(self, action: #selector(btnAlertDoneAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertPopupView1)
    }
    
    @objc func btnAlertDoneAction(_ sender: Any){
        
        if KUSERDEFAULTS.bool(forKey: "getPrePostMoodBool"){
            let getPostJournalCount = self.appPreference.getPostJournalCount()
            if getPostJournalCount == 0{
                self.alertPopupView1.removeFromSuperview()
            }else{
                xibJournalView()
            }
        }else{
            self.alertPopupView1.removeFromSuperview()
        }
    }
    
    func xibJournalView(){
        journalView = UINib(nibName: "WWMAddJournalView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAddJournalView
        let window = UIApplication.shared.keyWindow!
        
        journalView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        journalView.addGestureRecognizer(self.tap)
        
        journalView.btnSubmit.alpha = 0
        journalView.viewJournal.alpha = 0
        journalView.lblEntryText.alpha = 0
        journalView.lblTextCount.alpha = 0
        
        journalView.btnSubmit.layer.borderWidth = 2.0
        journalView.btnSubmit.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        journalView.btnSubmit.isUserInteractionEnabled = true
        
        journalView.txtViewJournal.delegate = self
        journalView.btnClose.addTarget(self, action: #selector(btnCloseAction(_:)), for: .touchUpInside)
        journalView.btnSubmit.addTarget(self, action: #selector(btnSubmitJournalAction(_:)), for: .touchUpInside)
        journalView.btnEditText.addTarget(self, action: #selector(btnEditTextAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(journalView)
        
        self.animatedLblEntryText()
    }
    
    
    func animatedLblEntryText(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.journalView.lblEntryText.alpha = 1
            self.journalView.lblEntryText.center.y = self.journalView.lblEntryText.center.y - 70
        }, completion: { _ in
            self.animatedViewJournal()
        })
    }
    
    func animatedViewJournal(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.journalView.viewJournal.alpha = 1
            self.journalView.viewJournal.center.y = self.journalView.viewJournal.center.y - 50
            self.journalView.lblTextCount.alpha = 1
            self.journalView.lblTextCount.center.y = self.journalView.lblTextCount.center.y - 50
        }, completion: { _ in
            self.animatedBtnSubmit()
        })
        
    }
    
    func animatedBtnSubmit(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.journalView.btnSubmit.alpha = 1
            self.journalView.btnSubmit.center.y = self.journalView.btnSubmit.center.y - 50
        }, completion: nil)
    }
    
    @IBAction func btnCloseAction(_ sender: Any) {
        journalView.removeFromSuperview()
    }
    
    @IBAction func btnSubmitJournalAction(_ sender: Any) {
        if journalView.txtViewJournal.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: KENTERJOURNAL, title: kAlertTitle)
        }else {
            self.addJournalAPI()
        }
    }
    
    @IBAction func btnEditTextAction(_ sender: Any) {
        journalView.txtViewJournal.isEditable = true
        journalView.txtViewJournal.becomeFirstResponder()
    }
    
    
    func xibJournalPopupCall(){
        alertJournalPopup = UINib(nibName: "WWMJouranlPopUp", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMJouranlPopUp
        let window = UIApplication.shared.keyWindow!
        
        alertJournalPopup.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        UIView.transition(with: alertJournalPopup, duration: 1.0, options: .transitionCrossDissolve, animations: {
            window.rootViewController?.view.addSubview(self.alertJournalPopup)
        }) { (Bool) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.alertJournalPopup.removeFromSuperview()
                self.getJournalList()
            }
        }
    }
    
    
    func addJournalAPI() {
        self.view.endEditing(true)
        
        // Analytics
        WWMHelperClass.sendEventAnalytics(contentType: "PROGRESS_JOURNAL", itemId: "ENTRY_RECORDED", itemName: "")
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
            "mood_color":"",
            "mood_text":"",
            "tell_us_why":journalView.txtViewJournal.text!,
            "user_id":self.appPreference.getUserID(),
            "date_time":"\(Int(Date().timeIntervalSince1970*1000))",
            "mood_id":"",
            "med_type" : self.appPreference.getType()
        ]
        
        //print("journal param.... \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_ADDJOURNAL, context: "WWMMyProgressJournalVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                self.xibJournalPopupCall()
                self.journalView.removeFromSuperview()
                
            }else {
                self.journalView.removeFromSuperview()
                self.saveJournalDatatoDB(param: param)
            }
            
            if KUSERDEFAULTS.bool(forKey: "getPrePostMoodBool"){
                self.appPreference.setPostJournalCount(value: self.appPreference.getPostJournalCount() - 1)
            }
            
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    func saveJournalDatatoDB(param:[String:Any]) {
        let dbJournal = WWMHelperClass.fetchEntity(dbName: "DBJournalData") as! DBJournalData
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: param, options:.prettyPrinted)
        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        dbJournal.journalData = myString
        WWMHelperClass.saveDb()
        self.xibJournalPopupCall()
    }
    func showPopUpOnPresentView(title: String, message: String) {
        
        
        alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView.btnOK.layer.borderWidth = 2.0
        alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        alertPopupView.lblTitle.text = title
        alertPopupView.lblSubtitle.text = message
        alertPopupView.btnClose.isHidden = true
        
        window.rootViewController?.view.addSubview(alertPopupView)
        
        
        
        
        //        let alert = UIAlertController(title: title as String,
        //                                      message: message as String,
        //                                      preferredStyle: UIAlertController.Style.alert)
        //
        //
        //        let OKAction = UIAlertAction(title: "OK",
        //                                     style: .default, handler: nil)
        //
        //        alert.addAction(OKAction)
        //        UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true,completion: nil)
        
    }
}


extension WWMMyProgressJournalVC: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        journalView.lblTextCount.text = "\(journalView.txtViewJournal.text.count)/1500"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (journalView.txtViewJournal.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 1501
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //self.view.removeGestureRecognizer(tap)
        journalView.btnSubmit.isUserInteractionEnabled = false
        if journalView.txtViewJournal.text == "" {
            journalView.btnSubmit.isUserInteractionEnabled = true
            WWMHelperClass.showPopupAlertController(sender: self, message: KENTERJOURNAL, title: kAlertTitle)
        }else {
            journalView.btnSubmit.isUserInteractionEnabled = false
            self.addJournalAPI()
        }
    }
}


extension WWMMyProgressJournalVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        itemInfo
    }
}
