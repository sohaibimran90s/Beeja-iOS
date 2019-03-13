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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let data = WWMHelperClass.fetchDB(dbName: "DBMeditationComplete") as! [DBMeditationComplete]
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
        WWMHelperClass.showSVHud()
        let param = ["user_id":self.appPreference.getUserID()]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_JOURNALMYPROGRESS, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let arrJournal = result["result"] as? [[String:Any]] {
                    self.journalData.removeAll()
                    var journal = WWMJournalProgressData()
                    for dict in arrJournal {
                        journal = WWMJournalProgressData.init(json: dict)
                        self.journalData.append(journal)
                    }
                }
                self.tableViewJournal.reloadData()
            }else {
                if error != nil {
                    WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                }
            }
            WWMHelperClass.dismissSVHud()
        }
    }

    @IBAction func btnAddJournalAction(_ sender: Any) {
        
        journalView = UINib(nibName: "WWMAddJournalView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAddJournalView
        let window = UIApplication.shared.keyWindow!
        
        journalView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        journalView.btnSubmit.layer.borderWidth = 2.0
        journalView.btnSubmit.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
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
    
    func addJournalAPI() {
        self.view.endEditing(true)
        WWMHelperClass.showSVHud()
        let param = [
            "mood_color":"",
            "mood_text":"",
            "tell_us_why":journalView.txtViewJournal.text!,
            "user_id":self.appPreference.getUserID(),
            "date_time":"\(Int(Date().timeIntervalSince1970*1000))",
            "mood_id":""
        ]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_ADDJOURNAL, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                self.journalView.removeFromSuperview()
                self.getJournalList()
            }else {
                if error != nil {
                    WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                }
            }
            WWMHelperClass.dismissSVHud()
        }
    }

    func showPopUpOnPresentView(title: String, message: String) {
        let alert = UIAlertController(title: title as String,
                                      message: message as String,
                                      preferredStyle: UIAlertController.Style.alert)
        
        
        let OKAction = UIAlertAction(title: "OK",
                                     style: .default, handler: nil)
        
        alert.addAction(OKAction)
        UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true,completion: nil)
        
    }
    
    
}
