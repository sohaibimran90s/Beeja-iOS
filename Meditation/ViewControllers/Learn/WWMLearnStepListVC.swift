//
//  WWMLearnStepListVC.swift
//  Meditation
//
//  Created by Prema Negi on 16/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMLearnStepListVC: WWMBaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var layoutMoodWidth: NSLayoutConstraint!
    @IBOutlet weak var layoutExpressMoodViewWidth: NSLayoutConstraint!
    @IBOutlet weak var lblExpressMood: UILabel!

    let appPreffrence = WWMAppPreference()
    var selectedIndex = 0
    var total_paid: Int = 0
    
    var learnStepsListData: [LearnStepsListData] = []
    var alertPopup = WWMAlertPopUp()
    
    let reachable = Reachabilities()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar(isShow: false, title: "")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.setAnimationForExpressMood()
        }
        
        DispatchQueue.global(qos: .background).async {
            self.fetchStepFaqDataFromDB(time_stamp: self.appPreffrence.getStepFAQTimeStamp())
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationLearnSteps(notification:)), name: Notification.Name("notificationLearnSteps"), object: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.isNavigationBarHidden = true
        self.fetchStepsDataFromDB()
        
    }
    
    @objc func notificationLearnSteps(notification: Notification) {
           self.fetchStepsDataFromDB()
       }
    
    //MARK: Fetch Steps Data From DB
    func fetchStepsDataFromDB() {
        let getStepsDataDB = WWMHelperClass.fetchDB(dbName: "DBSteps") as! [DBSteps]
        
        if getStepsDataDB.count > 0 {
            print("self.stepFaqDataDB... \(getStepsDataDB.count)")
            self.learnStepsListData.removeAll()
            for dict in getStepsDataDB {
                
                var jsonData: [String: Any] = [:]
                
                jsonData["step_name"] = dict.step_name
                jsonData["id"] = dict.id
                jsonData["date_completed"] = dict.date_completed
                jsonData["title"] = dict.title
                jsonData["timer_audio"] = dict.timer_audio
                jsonData["description"] = dict.description1
                jsonData["step_audio"] = dict.step_audio
                jsonData["outro_audio"] = dict.outro_audio
                jsonData["completed"] = dict.completed
                
                let learnStepsListData = LearnStepsListData.init(json: jsonData)
                self.learnStepsListData.append(learnStepsListData)
                
                print("jsonData... \(jsonData)")
            }
            
            //* logic for expanding the cell which we have to play
            var flag = 0
            
            for i in 0..<self.learnStepsListData.count{
                print("date_completed... \(self.learnStepsListData[i].date_completed)")
                print("completed... \(self.learnStepsListData[i].completed)")
                
                if i !=  self.learnStepsListData.count - 1{
                    if self.learnStepsListData[i].completed == true{
                        self.selectedIndex = i + 1
                        flag = 1
                    }
                }
            }
            
            if flag == 0{
                self.selectedIndex = 0
            }
            //*end here
            
            print("WWMHelperClass.total_paid... \(WWMHelperClass.total_paid)")
            print("learnStepsListData count... \(self.learnStepsListData.count)")
            self.tableView.reloadData()
            
            NotificationCenter.default.removeObserver(self, name: Notification.Name("notificationLearnSteps"), object: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.lblExpressMood.transform = CGAffineTransform(rotationAngle:CGFloat(+Double.pi/2))
        self.layoutMoodWidth.constant = 90
    }
    
    func setAnimationForExpressMood() {
        
        UIView.animate(withDuration: 2.5, delay: 0.0, options: .curveEaseInOut, animations: {
            self.layoutExpressMoodViewWidth.constant = 40
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    @IBAction func btnExpressMoodAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterVC") as! WWMMoodMeterVC
        vc.type = "pre"
        vc.meditationID = "0"
        vc.levelID = "0"
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func btnIntroClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC
        
        vc.value = "learnStepList"
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    
    @IBAction func btnSideMenuClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSideMenuVC") as! WWMSideMenuVC
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func xibCall(title1: String){
        alertPopup = UINib(nibName: "WWMAlertPopUp", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertPopUp
        let window = UIApplication.shared.keyWindow!
        
        alertPopup.lblTitle.text = title1
        alertPopup.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        UIView.transition(with: alertPopup, duration: 1.0, options: .transitionCrossDissolve, animations: {
            window.rootViewController?.view.addSubview(self.alertPopup)
        }) { (Bool) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.alertPopup.removeFromSuperview()
            }
        }
    }
    
    //MARK: StepFAQ
    func fetchStepFaqDataFromDB(time_stamp: Any) {
        let stepFaqDataDB = WWMHelperClass.fetchDB(dbName: "DBStepFaq") as! [DBStepFaq]
        if stepFaqDataDB.count > 0 {
            
            for dict in stepFaqDataDB {
                                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                let currentDateString = dateFormatter.string(from: Date())
                let systemTimeStamp: String = dict.last_time_stamp ?? currentDateString
                let apiTimeStamp: String = "\(time_stamp)"

                 print("dict.last_time_stamp... \(dict.last_time_stamp!) systemTimeStamp.... \(systemTimeStamp) apiTimeStamp... \(apiTimeStamp)")
                
                let systemDate = Date(timeIntervalSince1970: Double(systemTimeStamp)!)
                let apiDate = Date(timeIntervalSince1970: Double(apiTimeStamp)!)
                
                
                print("date1... \(systemDate) date2... \(apiDate)")
                if systemDate < apiDate{
                    self.stepFaqAPI()
                }
            }
        }else{
            self.stepFaqAPI()
        }
    }
    
    //MARK: API call
    func stepFaqAPI() {
                
        
        WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_STEPFAQ, context: "WWMFAQsVC", headerType: kGETHeader, isUserToken: true) { (result, error, sucess) in
            if let _ = result["success"] as? Bool {
                
                print("StepFaq WWMLearnStepListVC in background thread...")
                print("faqs data..... \(result)")
                if let data = result["data"] as? [[String: Any]]{
                    
                    let stepFaqData = WWMHelperClass.fetchDB(dbName: "DBStepFaq") as! [DBStepFaq]
                    if stepFaqData.count > 0 {
                        WWMHelperClass.deletefromDb(dbName: "DBStepFaq")
                    }
                    
                    for dict in data {
                        let dbStepFaqData = WWMHelperClass.fetchEntity(dbName: "DBStepFaq") as! DBStepFaq
                        
                        let timeInterval = Int(Date().timeIntervalSince1970)
                        print("timeInterval.... \(timeInterval)")
                        
                        dbStepFaqData.last_time_stamp = "\(timeInterval)"
                        
                        if let id = dict["step_id"]{
                            dbStepFaqData.step_id = "\(id)"
                        }
                        if let answers = dict["answers"] as? String{
                            dbStepFaqData.answers = answers
                        }
                        
                        if let question = dict["question"] as? String{
                            dbStepFaqData.question = question
                        }
                        
                        WWMHelperClass.saveDb()
                    }
                    
                }
            }
        }
    }//end stepFaqAPI
}

extension WWMLearnStepListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.learnStepsListData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "WWMLearnStepListTVC") as! WWMLearnStepListTVC
        
        cell.lblNoOfSteps.layer.cornerRadius = 12
        cell.lblStepDescription.text = self.learnStepsListData[indexPath.row].Description
        cell.lblNoOfSteps.text = "\(self.learnStepsListData[indexPath.row].id)"
        cell.lblSteps.text = self.learnStepsListData[indexPath.row].step_name
        cell.lblStepsTitle.text = self.learnStepsListData[indexPath.row].title

        if selectedIndex == indexPath.row{
            cell.lblStepDescription.isHidden = false
            cell.btnProceed.isHidden = false
            
            cell.backImgView.backgroundColor = UIColor(red: 14.0/255.0, green: 31.0/255.0, blue: 104.0/255.0, alpha: 0.7)
            cell.imgArraow.image = UIImage(named: "upArrow")
        }else{
            cell.lblStepDescription.isHidden = true
            cell.btnProceed.isHidden = true
            
            cell.backImgView.backgroundColor = UIColor(red: 0.0/255.0, green: 18.0/255.0, blue: 82.0/255.0, alpha: 1.0)
            cell.imgArraow.image = UIImage(named: "downArrow")
        }
        
        if indexPath.row == 0{
            cell.lblUprLine.isHidden = true
        }else{
            cell.lblUprLine.isHidden = false
        }
        
        if self.learnStepsListData[indexPath.row].completed == true{
            
            cell.lblNoOfSteps.backgroundColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0)
            cell.lblUprLine.backgroundColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0)
            cell.lblBelowLine.backgroundColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0)
        }else{
            cell.lblNoOfSteps.backgroundColor = UIColor.white
            cell.lblUprLine.backgroundColor = UIColor.white
            cell.lblBelowLine.backgroundColor = UIColor.white
        }
        
        cell.btnProceed.addTarget(self, action: #selector(btnProceedClicked), for: .touchUpInside)
        cell.btnProceed.tag = indexPath.row
        
        print("self.total_paid... \(self.total_paid)")
        if self.appPreffrence.getExpiryDate(){
            cell.imgLock.image = UIImage(named: "")
            cell.isUserInteractionEnabled = true
        }else{
            if indexPath.row > 2{
                cell.imgLock.image = UIImage(named: "lock")
                
                cell.lblNoOfSteps.backgroundColor = UIColor.white.withAlphaComponent(0.3)
                cell.lblUprLine.backgroundColor = UIColor.white.withAlphaComponent(0.3)
                cell.lblBelowLine.backgroundColor = UIColor.white.withAlphaComponent(0.3)
                cell.lblNoOfSteps.textColor = UIColor.black.withAlphaComponent(0.5)
            }else{
                cell.imgLock.image = UIImage(named: "")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndex == indexPath.row{
            return UITableView.automaticDimension
        }else{
            return 68
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        self.tableView.reloadData()
    }
    
    @objc func btnProceedClicked(_ sender: UIButton){
        
        WWMHelperClass.step_audio = self.learnStepsListData[sender.tag].step_audio
        WWMHelperClass.timer_audio = self.learnStepsListData[sender.tag].timer_audio
        WWMHelperClass.outro_audio = self.learnStepsListData[sender.tag].outro_audio
        WWMHelperClass.step_id = self.learnStepsListData[sender.tag].id
        WWMHelperClass.step_title = self.learnStepsListData[sender.tag].title
        WWMHelperClass.total_paid = self.total_paid
        
        var flag = 0
        var position = 0
        var dateCompareLoopCount = 0
        var senderTag = -1

        if self.appPreffrence.getExpiryDate(){
            dateCompareLoopCount = self.learnStepsListData.count - 1
        }else{
            dateCompareLoopCount = 2
            if sender.tag > 2{
                self.xibCall(title1: KLEARNANNUALSUBS)
                return
            }
        }
        
        for i in 0...dateCompareLoopCount{
            
            let date_completed = self.learnStepsListData[i].date_completed
            if date_completed != ""{
                let dateCompare = WWMHelperClass.dateComparison1(expiryDate: date_completed)
                if dateCompare.0 == 1{
                    senderTag = i
                    flag = 1
                    break
                }
            }
        }
        
        if flag == 1{
            
            print("sender.Tag.... \(sender.tag) senderTag.... \(senderTag)")
            
            if sender.tag == senderTag{
                
                if reachable.isConnectedToNetwork() {
                    WWMHelperClass.selectedType = "learn"
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnGetSetVC") as! WWMLearnGetSetVC
                    self.navigationController?.pushViewController(vc, animated: true)
                 }else {
                    WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                }
                
            }else{
                self.xibCall(title1: KLEARNONESTEP)
            }
            print("already played the step")
            
        }else{
            for i in 0..<sender.tag{
                if !self.learnStepsListData[i].completed{
                    flag = 2
                    position = i
                    break
                }
            }
                
            if flag == 2{
                print("first play the \(self.learnStepsListData[position].step_name)")
                
                self.xibCall(title1: "\(KLEARNJUMPSTEP) \(self.learnStepsListData[position].step_name) \(KLEARNJUMPSTEP1)")
            }else{
                
                if reachable.isConnectedToNetwork() {
                    WWMHelperClass.selectedType = "learn"
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnGetSetVC") as! WWMLearnGetSetVC
                    self.navigationController?.pushViewController(vc, animated: true)
                 }else {
                    WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                }
            }
        }
    }
}
