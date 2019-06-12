//
//  WWMMyProgressJournalVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 09/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMMyProgressJournalVC: WWMBaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableViewJournal: UITableView!
    
    var journalView = WWMAddJournalView()
    var journalData = [WWMJournalProgressData]()
    
    var alertJournalPopup = WWMJouranlPopUp()
   // var alertPopupView = WWMAlertController()

    override func viewDidLoad() {
        super.viewDidLoad()

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
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? WWMJournalTableViewCell {
            cell.viewShadow.layer.shadowColor = UIColor.black.cgColor
            cell.viewShadow.layer.shadowOpacity = 0.3
            cell.viewShadow.layer.shadowRadius = 5.0
            cell.viewShadow.layer.cornerRadius = 5.0
            cell.viewShadow.layer.masksToBounds = false
            
            let data = journalData[indexPath.row]
            
            cell.lblJournalDesc.text = data.text
            if data.mood_status.lowercased() == "post" {
                cell.lblMeditationType.text = "Post Meditation"
            }else if data.mood_status.lowercased() == "pre" {
                cell.lblMeditationType.text = "Pre Meditation"
            }else{
                cell.lblMeditationType.text = ""
            }
            
            
            let date = Date(timeIntervalSince1970: Double(data.date_time)!/1000)
            
            let dateFormatter = DateFormatter()
            //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "EEEE, hh:mm a" //Specify your format that you want
            let strWeekDayAndtime = dateFormatter.string(from: date)
            cell.lblWeekDayAndTime.text = strWeekDayAndtime
            
            dateFormatter.dateFormat = "dd"
            
            cell.lblDateDay.text = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "MMM"
            cell.lblDateMonth.text = dateFormatter.string(from: date)
            
            
            
            
            
            return cell
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Roshan")
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func getJournalList() {
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = ["user_id":self.appPreference.getUserID(),
        "med_type" : self.appPreference.getType()]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_JOURNALMYPROGRESS, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let arrJournal = result["result"] as? [[String:Any]] {
                    let moodData = WWMHelperClass.fetchDB(dbName: "DBJournalList") as! [DBJournalList]
                    if moodData.count > 0 {
                        WWMHelperClass.deletefromDb(dbName: "DBJournalList")
                    }
                    
                    
                    self.journalData.removeAll()
                    var journal = WWMJournalProgressData()
                    for dict in arrJournal {
                        journal = WWMJournalProgressData.init(json: dict)
                        self.journalData.append(journal)
                        let dbJournal = WWMHelperClass.fetchEntity(dbName: "DBJournalList") as! DBJournalList
                        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: dict, options:.prettyPrinted)
                        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                        dbJournal.data = myString
                        WWMHelperClass.saveDb()
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
            self.journalData.removeAll()
            var journal = WWMJournalProgressData()
            
            for dict in journalDataDB {
                if let jsonResult = self.convertToDictionary(text: dict.data ?? "") {
                        journal = WWMJournalProgressData.init(json: jsonResult)
                }
                if self.journalData.count < 10 {
                    self.journalData.append(journal)
                }
            }
        }
        WWMHelperClass.showPopupAlertController(sender: self, message: Validatation_JournalOfflineMsg, title: kAlertTitle)
        self.tableViewJournal.reloadData()
    }

    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    @IBAction func btnAddJournalAction(_ sender: Any) {
        
        journalView = UINib(nibName: "WWMAddJournalView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAddJournalView
        let window = UIApplication.shared.keyWindow!
        
        journalView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        journalView.btnSubmit.layer.borderWidth = 2.0
        journalView.btnSubmit.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        journalView.txtViewJournal.delegate = self
        journalView.btnClose.addTarget(self, action: #selector(btnCloseAction(_:)), for: .touchUpInside)
        journalView.btnSubmit.addTarget(self, action: #selector(btnSubmitJournalAction(_:)), for: .touchUpInside)
        journalView.btnEditText.addTarget(self, action: #selector(btnEditTextAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(journalView)

    }
    
    @IBAction func btnCloseAction(_ sender: Any) {
        journalView.removeFromSuperview()
    }
    
    @IBAction func btnSubmitJournalAction(_ sender: Any) {
        if journalView.txtViewJournal.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: "Please enter your journal.", title: kAlertTitle)
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
        //WWMHelperClass.showSVHud()
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
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_ADDJOURNAL, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                self.journalView.removeFromSuperview()
                
                self.xibJournalPopupCall()
                
                //self.getJournalList()
            }else {
                self.journalView.removeFromSuperview()
                self.saveJournalDatatoDB(param: param)
            }
            //WWMHelperClass.dismissSVHud()
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
}
