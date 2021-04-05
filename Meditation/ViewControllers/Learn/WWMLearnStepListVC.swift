//
//  WWMLearnStepListVC.swift
//  Meditation
//
//  Created by Prema Negi on 16/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import CoreData
import XLPagerTabStrip

class WWMLearnStepListVC: WWMBaseViewController, IndicatorInfoProvider {

    var itemInfo: IndicatorInfo = "View"
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var layoutMoodWidth: NSLayoutConstraint!
    @IBOutlet weak var layoutExpressMoodViewWidth: NSLayoutConstraint!
    @IBOutlet weak var lblExpressMood: UILabel!

    let appPreffrence = WWMAppPreference()
    var selectedIndex = 0
    var total_paid: Int = 0
    var learnStepsListData: [LearnStepsListData] = []
    var alertPopup = WWMAlertPopUp()
    var alertPopupView1 = WWMAlertController()
    let reachable = Reachabilities()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !self.appPreference.getFor8Weeks(){
            appPreference.set21ChallengeName(value: "12 Steps")
        }
        
        self.offlineDatatoServerCall()
        //BASS-976
        self.fetchStepFaqDataFromDB(time_stamp: self.appPreffrence.getStepFAQTimeStamp())
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationLearnSteps(notification:)), name: Notification.Name("notificationLearnSteps"), object: nil)
        self.appPreference.setMoodId(value: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //self.navigationController?.isNavigationBarHidden = true
        //self.setUpNavigationBarForDashboard(title: "Learn")
        self.fetchStepsDataFromDB()
    }
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    @objc func notificationLearnSteps(notification: Notification) {
           self.fetchStepsDataFromDB()
       }
    
    //MARK: insert offline data to server
    func offlineDatatoServerCall(){

        let nintyFivePercentDB = WWMHelperClass.fetchDB(dbName: "DBNintyFiveCompletionData") as! [DBNintyFiveCompletionData]
        if nintyFivePercentDB.count > 0{
            
            for data in nintyFivePercentDB{
                
                //print("nintyFivePercentDB.count++++====== \(nintyFivePercentDB.count)")
                
                if let jsonResult = self.convertToDictionary1(text: data.data ?? "") {
                    
                    //print("data....++++++===== \(data.data) id++++++++==== \(data.id)")
                    
                    self.completeMeditationAPI(mood_id: jsonResult["mood_id"] as? String ?? "", user_id: jsonResult["user_id"] as? String ?? "", rest_time: "\(jsonResult["rest_time"] as? Int ?? 0)", emotion_id: jsonResult["emotion_id"] as? String ?? "", tell_us_why: jsonResult["tell_us_why"] as? String ?? "", prep_time: "\(jsonResult["prep_time"] as? Int ?? 0)", meditation_time: "\(jsonResult["meditation_time"] as? Int ?? 0)", watched_duration: jsonResult["watched_duration"] as? String ?? "", level_id: jsonResult["level_id"] as? String ?? "", complete_percentage: "\(jsonResult["complete_percentage"] as? Int ?? 0)", rating: jsonResult["rating"] as? String ?? "", meditation_type: jsonResult["meditation_type"] as? String ?? "", category_id: jsonResult["category_id"] as? String ?? "", meditation_id: jsonResult["meditation_id"] as? String ?? "", date_time: jsonResult["date_time"] as? String ?? "", type: jsonResult["type"] as? String ?? "", guided_type: jsonResult["guided_type"] as? String ?? "", audio_id: jsonResult["audio_id"] as? String ?? "", step_id: "\(jsonResult["step_id"] as? Int ?? 1)", mantra_id: "\(jsonResult["mantra_id"] as? Int ?? 1)", id: "\(data.id ?? "")", is_complete: jsonResult["is_complete"] as? String ?? "0", challenge_day_id: jsonResult["challenge_day_id"] as? String ?? "", challenge_type: jsonResult["challenge_type"] as? String ?? "")
                }
            }
        }
    }
    
    func completeMeditationAPI(mood_id: String, user_id: String, rest_time: String, emotion_id: String, tell_us_why: String, prep_time: String, meditation_time: String, watched_duration: String, level_id: String, complete_percentage: String, rating: String, meditation_type: String, category_id: String, meditation_id: String, date_time: String, type: String, guided_type: String, audio_id: String, step_id: String, mantra_id: String, id: String, is_complete: String, challenge_day_id: String, challenge_type: String) {
        
        var param: [String: Any] = [:]
        param = [
            "type": type,
            "step_id": step_id,
            "mantra_id": mantra_id,
            "category_id": category_id,
            "emotion_id": emotion_id,
            "audio_id": audio_id,
            "guided_type": guided_type,
            "duration" : watched_duration,
            "watched_duration": watched_duration,
            "rating": rating,
            "user_id": user_id,
            "meditation_type": meditation_type,
            "date_time": date_time,
            "tell_us_why": tell_us_why,
            "prep_time": prep_time,
            "meditation_time": meditation_time,
            "rest_time": rest_time,
            "meditation_id": meditation_id,
            "level_id": level_id,
            "mood_id": Int(self.appPreference.getMoodId()) ?? 0,
            "complete_percentage": complete_percentage,
            "is_complete": is_complete,
            "title": "",
            "journal_type": "",
            "challenge_day_id":challenge_day_id,
            "challenge_type":challenge_type
            ] as [String : Any]
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONCOMPLETE, context: "WWMTabBarVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                
                if type == "guided"{
                    DispatchQueue.global(qos: .background).async {
                        self.getGuidedListAPI()
                    }
                }else if challenge_day_id != ""{
                    DispatchQueue.global(qos: .background).async {
                        self.getLearnAPI()
                    }
                }
                WWMHelperClass.deleteRowfromDb(dbName: "DBNintyFiveCompletionData", id: id, type: "id")
            }
        }
    }//insert offline data to server*
    
    //MARK: Fetch Steps Data From DB
    func fetchStepsDataFromDB() {
        var flag = 0
        for i in 0..<self.learnStepsListData.count{
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
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        NotificationCenter.default.removeObserver(self, name: Notification.Name("notificationLearnSteps"), object: nil)
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
    
    func getAnnualPopUp(){
        self.alertPopupView1 = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        self.alertPopupView1.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        
        self.alertPopupView1.lblTitle.numberOfLines = 0
        self.alertPopupView1.btnOK.layer.borderWidth = 2.0
        self.alertPopupView1.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        self.alertPopupView1.lblTitle.text = KSUBSPLANEXP
        self.alertPopupView1.lblSubtitle.text = KLEARNANNUALSUBS
        self.alertPopupView1.btnClose.setTitle("no thanks", for: .normal)
        self.alertPopupView1.btnOK.setTitle("ok", for: .normal)
        
        self.alertPopupView1.btnClose.addTarget(self, action: #selector(btnCloseAction(_:)), for: .touchUpInside)
        self.alertPopupView1.btnOK.addTarget(self, action: #selector(btnAlertDoneAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertPopupView1)
    }
    
    @objc func btnCloseAction(_ sender: Any){
        self.alertPopupView1.removeFromSuperview()
    }
    
    @objc func btnAlertDoneAction(_ sender: Any){
        self.alertPopupView1.removeFromSuperview()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMUpgradeBeejaVC") as! WWMUpgradeBeejaVC
        vc.isCallHome = "LearnStepListVC"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: StepFAQ
    func fetchStepFaqDataFromDB(time_stamp: Any) {
        let stepFaqDataDB = WWMHelperClass.fetchDB(dbName: "DBStepFaq") as! [DBStepFaq]
        if stepFaqDataDB.count > 0 {
            
            for dict in stepFaqDataDB {
                                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                let systemTimeStamp: String = dict.last_time_stamp ?? "\(Int(Date().timeIntervalSince1970))"
                let apiTimeStamp: String = "\(time_stamp)"

                if systemTimeStamp == "nil" || apiTimeStamp == "nil"{
                    DispatchQueue.global(qos: .background).async {
                        self.stepFaqAPI()
                    }
                    return
                }
                
                let systemDate = Date(timeIntervalSince1970: Double(systemTimeStamp)!)
                let apiDate = Date(timeIntervalSince1970: Double(apiTimeStamp)!)
                
                
                //print("date1... \(systemDate) date2... \(apiDate)")
                if systemDate < apiDate{
                    DispatchQueue.global(qos: .background).async {
                        self.stepFaqAPI()
                    }
                }
            }
        }else{
            DispatchQueue.global(qos: .background).async {
                self.stepFaqAPI()
            }
        }
    }
    
    //MARK: API call
    func stepFaqAPI() {
        
        WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_STEPFAQ, context: "WWMFAQsVC", headerType: kGETHeader, isUserToken: true) { (result, error, sucess) in
            if let _ = result["success"] as? Bool {
                
                //print("StepFaq WWMLearnStepListVC in background thread... faqs data..... \(result)")
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
        
        //print("self.total_paid... \(self.total_paid)")
        if self.appPreffrence.getExpiryDate(){
            cell.imgLock.isHidden = true
            cell.imgLock.image = UIImage(named: "")
            cell.isUserInteractionEnabled = true
        }else{
            if indexPath.row > 2{
                cell.imgLock.isHidden = false
                cell.imgLock.image = UIImage(named: "lock1")
                
                cell.lblNoOfSteps.backgroundColor = UIColor.white.withAlphaComponent(0.3)
                cell.lblUprLine.backgroundColor = UIColor.white.withAlphaComponent(0.3)
                cell.lblBelowLine.backgroundColor = UIColor.white.withAlphaComponent(0.3)
                cell.lblNoOfSteps.textColor = UIColor.black.withAlphaComponent(0.5)
            }else{
                cell.imgLock.image = UIImage(named: "")
                cell.imgLock.isHidden = true
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
        
        if !self.appPreffrence.getExpiryDate(){
            if sender.tag > 2{
                self.getAnnualPopUp()
                return
            }
        }

        if reachable.isConnectedToNetwork() {
            self.pushViewController(sender_Tag: sender.tag)
        }else{
            WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
        }
    }
    
    func pushViewController(sender_Tag: Int){
        
        var flag = 0
        var position = 0
        
        if self.learnStepsListData[sender_Tag].completed{
            self.appPreference.setType(value: "learn")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnGetSetVC") as! WWMLearnGetSetVC
            
            self.appPreffrence.setLearnMin_limit(value: self.learnStepsListData[sender_Tag].min_limit)
            self.appPreffrence.setLearnMax_limit(value: self.learnStepsListData[sender_Tag].max_limit)
            self.navigationController?.pushViewController(vc, animated: true)
            
            return
        }else{
            for i in 0..<sender_Tag{
                let date_completed = self.learnStepsListData[i].date_completed
                if date_completed != ""{
                    let dateCompare = WWMHelperClass.dateComparison1(expiryDate: date_completed)
                    if dateCompare.0 == 1{
                        flag = 1
                        break
                    }
                }
            }
        }
        
        if flag == 1{
            self.xibCall(title1: KLEARNONESTEP)
            return
        }
        
        for i in 0..<sender_Tag{
            if !self.learnStepsListData[i].completed{
                flag = 2
                position = i
                break
            }
        }
        
        if flag == 2{
            
            //print("first play the \(self.learnStepsListData[position].step_name)")
            
            self.xibCall(title1: "\(KLEARNJUMPSTEP) \(self.learnStepsListData[position].step_name) \(KLEARNJUMPSTEP1)")
        }else{
            self.appPreference.setType(value: "learn")
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnGetSetVC") as! WWMLearnGetSetVC
            
            self.appPreffrence.setLearnMin_limit(value: self.learnStepsListData[sender_Tag].min_limit)
            self.appPreffrence.setLearnMax_limit(value: self.learnStepsListData[sender_Tag].max_limit)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
