//
//  WWM30DaysChallengeVC.swift
//  Meditation
//
//  Created by Prema Negi on 17/04/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class WWM30DaysChallengeVC: WWMBaseViewController, IndicatorInfoProvider {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHC: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblReminder: UILabel!
    @IBOutlet weak var lblMeditationCount: UILabel!
    @IBOutlet weak var lblLine: UILabel!
    @IBOutlet weak var lblBelowTitle: UILabel!
    @IBOutlet weak var btnStartChallenge: UIButton!
    @IBOutlet weak var lblMeditationCountTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewReminder: UIView!
    @IBOutlet weak var viewExpired: UIView!
    @IBOutlet weak var viewExpiredTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewRetake: UIView!
    @IBOutlet weak var viewRetakeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewHeaderHC: NSLayoutConstraint!
    @IBOutlet weak var viewMeditationDaysHC: NSLayoutConstraint!
    @IBOutlet weak var viewCollectionViewHC: NSLayoutConstraint!
    @IBOutlet weak var btnIntro: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnReminder: UIButton!
    
    let reachable = Reachabilities()
    var itemInfo: IndicatorInfo = "View"
    var daysListData: [ThirtyDaysListData] = []
    var checkExpireRetake = 0
    var lastChallengeDate = ""
    var completed30DayCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.appPreference.setFor8Weeks(value: false)
        appPreference.set21ChallengeName(value: "30 Day Challenge")
        DispatchQueue.main.async {
            self.setUpView()
        }
    }
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    func setUpView(){
        
        //to check if 30 challenge is expire or not
        if self.appPreference.get30DaysIsExpired(){
            self.checkExpireRetake = 1
        }
        
        //to check if 30 challenge is to retake
        if day30Count() == 30{
            self.checkExpireRetake = 2
        }
        
        if self.checkExpireRetake == 0{
            //Working
            self.viewExpired.isHidden = true
            self.viewRetake.isHidden = true
            self.viewReminder.isHidden = false
            self.lblMeditationCount.text = "Day \(completed30DayCount)/30"
            self.lblMeditationCountTopConstraint.constant = 16
            self.viewCollectionViewHC.constant = 403
            self.viewMeditationDaysHC.constant = 530
            self.viewExpiredTopConstraint.constant = 8
            self.lblLine.isHidden = false
            self.btnStartChallenge.isHidden = false
            self.lblBelowTitle.text = "Psst, we have little surprises everytime you complete a milestone."
            
            if self.appPreference.getInvitationCount() > 4{
                self.viewHeaderHC.constant = 86
                self.btnShare.isHidden = true
            }else{
                self.viewHeaderHC.constant = 126
                self.btnShare.isHidden = false
            }
            
        }else if self.checkExpireRetake == 1{
            //Expired
            self.viewExpired.isHidden = false
            self.viewRetake.isHidden = true
            self.viewReminder.isHidden = true
            self.viewHeaderHC.constant = 90
            self.lblMeditationCount.text = ""
            self.lblMeditationCountTopConstraint.constant = 6
            self.viewCollectionViewHC.constant = 310
            self.viewMeditationDaysHC.constant = 360
            self.viewExpiredTopConstraint.constant = 16
            self.lblLine.isHidden = true
            self.btnStartChallenge.isHidden = true
            self.lblBelowTitle.text = ""
        }else{
            //Retake
            self.viewExpired.isHidden = true
            self.viewRetake.isHidden = false
            self.viewReminder.isHidden = true
            self.viewHeaderHC.constant = 82
            self.lblMeditationCount.text = "Day 30/30"
            self.lblMeditationCountTopConstraint.constant = 16
            self.viewCollectionViewHC.constant = 310
            self.viewMeditationDaysHC.constant = 390
            self.viewRetakeTopConstraint.constant = 16
            self.lblLine.isHidden = true
            self.btnStartChallenge.isHidden = true
            self.lblBelowTitle.text = ""
        }
        
        if WWMHelperClass.hasTopNotch{
            self.collectionViewHC.constant = 290
            self.viewCollectionViewHC.constant = self.viewCollectionViewHC.constant + 30
            self.viewMeditationDaysHC.constant = self.viewMeditationDaysHC.constant + 30
        }else{
            self.collectionViewHC.constant = 260
        }
        
        self.checkIntroCompleted()
    }
    
    //to check if the challenge is expired or not
    func day30Count() -> Int{
        for index in 0..<self.daysListData.count{
            if self.daysListData[index].date_completed != ""{
                completed30DayCount = completed30DayCount + 1
            }
        }
        return completed30DayCount
    }
    
    //to check if to show intro button or not
    func checkIntroCompleted(){
        
        let underLineColor: UIColor = UIColor.init(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0)
        let underLineStyle = NSUnderlineStyle.single.rawValue
        let labelAtributes:[NSAttributedString.Key : Any]  = [NSAttributedString.Key.underlineStyle: underLineStyle,
            NSAttributedString.Key.underlineColor: underLineColor
        ]
        let underlineAttributedString = NSAttributedString(string: "Set a Daily Reminder", attributes: labelAtributes)
        lblReminder.attributedText = underlineAttributedString
        
        let intro_completed = self.appPreference.get30IntroCompleted()
        if intro_completed{
            self.btnIntro.isHidden = true
        }else{
            self.btnIntro.isHidden = false
        }
        
        var settingData = DBSettings()
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
            if settingData.thirtyDaysReminder != ""{
                self.btnReminder.isHidden = true
                self.lblReminder.isHidden = true
            }else{
                self.btnReminder.isHidden = false
                self.lblReminder.isHidden = false
            }
        }
        
        self.setLblTitle()
    }
    
    //to check if 12 steps completed today
    func setLblTitle(){
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        //print("getDate12Step... \(self.appPreference.getDate12Step() ) date... \(dateFormatter.string(from: Date()))")
        if self.appPreference.getDate12Step() == dateFormatter.string(from: Date()){
            self.lblTitle.text = "Tomorrow is the first day of your challenge"
        }else{
            self.lblTitle.text = "Continue on your meditation journey and challenge yourself to create life-long habits."
        }
    }
    
    //MARK: Challenge Expired button
    @IBAction func btnExpiredClicked(_ sender: UIButton){
        self.retakeChallengeApi()
    }
    
    //MARK: Challenge Retake button
    @IBAction func btnRetakeClicked(_ sender: UIButton){
        self.retakeChallengeApi()
    }
    
    //MARK: Set a Reminder button
    @IBAction func btnReminderClicked(_ sender: UIButton){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM21DaySetReminder1VC") as! WWM21DaySetReminder1VC
        
        vc.isSetting = true
        vc.type = "30_days"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Share the love
    @IBAction func btnShareLoveClicked(_ sender: UIButton){
        if !reachable.isConnectedToNetwork() {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validatation_JournalOfflineMsg, title: kAlertTitle)
        }else{
            
            if self.appPreference.getExpiryDate(){
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMShareLoveVC") as! WWMShareLoveVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    //Start Challenge
    @IBAction func btnStartChalClicked(_ sender: UIButton){
        
        self.pushViewController(sender_Tag: self.startChallengeFunc())
    }
    
    @IBAction func btnIntroVideoClicked(_ sender: UIButton){
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC

        vc.emotionKey = "30days"
        vc.challenge_type = "30days"
        vc.value = "30days"
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    //start challenge from button
    func startChallengeFunc() -> Int{
        for i in 0..<self.daysListData.count{
            let date_completed = self.daysListData[i].date_completed
            if date_completed == ""{
                return i
            }
        }
        return 0
    }
}

extension WWM30DaysChallengeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.daysListData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let imgLeft = cell.viewWithTag(1) as! UIImageView
       // let imgRight = cell.viewWithTag(4) as! UIImageView
        let imgLock = cell.viewWithTag(5) as! UIImageView
        let viewBackLbl = cell.viewWithTag(2)!
        let lblChallNo = cell.viewWithTag(3) as! UILabel
    
        viewBackLbl.layer.borderWidth = 2.0
        lblChallNo.text = "\(self.daysListData[indexPath.item].day_name)"
        
        imgLock.layer.cornerRadius = 8
        imgLock.layer.borderColor = UIColor.black.cgColor
        imgLock.layer.borderWidth = 2
        
        if self.daysListData[indexPath.item].completed{
            viewBackLbl.backgroundColor = UIColor.init(hexString: "#00eba9")!
            viewBackLbl.layer.borderColor = UIColor.clear.cgColor
            imgLeft.image = UIImage(named: "lineGreen")
            lblChallNo.textColor = UIColor.black
        }else{
            viewBackLbl.layer.borderColor = UIColor.white.cgColor
            viewBackLbl.backgroundColor = UIColor.clear
            imgLeft.image = UIImage(named: "lineWhite")
            lblChallNo.textColor = UIColor.white
        }
        
        if self.daysListData[indexPath.item].is_milestone{
            imgLeft.isHidden = true
            imgLock.isHidden = false
        }else{
            imgLeft.isHidden = false
            imgLock.isHidden = true
        }
        
        if indexPath.item == self.daysListData.count - 1{
            imgLeft.isHidden = true
        }
        
        //to display the current highlighted view to play
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.locale = Locale(identifier: formatter.locale.identifier)
        formatter.dateFormat = "yyyy-MM-dd"
        let lastDateString: String = getLastChallengeDate().0
        
        if lastDateString != ""{
            let lastDate = formatter.date(from: lastDateString)
            let currentDateString = formatter.string(from: Date())
            let currentDate = formatter.date(from: currentDateString)
            
            if indexPath.item < self.daysListData.count - 1{
                if currentDate! > lastDate!{
                    if indexPath.item == getLastChallengeDate().1 + 1{
                        viewBackLbl.layer.borderColor = UIColor.init(hexString: "#00eba9")?.cgColor
                        viewBackLbl.backgroundColor = UIColor.clear
                        imgLeft.image = UIImage(named: "lineWhite")
                        lblChallNo.textColor = UIColor.white
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.collectionView.frame.size.width)/7
        return CGSize.init(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        appPreference.set21ChallengeName(value: "30 Day Challenge")
        WWMHelperClass.sendEventAnalytics(contentType: "CHALLENGE", itemId: "CHALLENGE_ACTIONED_LEAR", itemName: "30DAYS")
        WWMHelperClass.sendEventAnalytics(contentType: "CHALLENGE", itemId: "CHALLENGE_30DAYS", itemName: "\(indexPath.item)")
        self.pushViewController(sender_Tag: indexPath.item)
    }
    
    //last challenge date played
    func getLastChallengeDate() -> (String, Int){
        
        var index1 = 0
        for index in 0..<self.daysListData.count{
            if self.daysListData[index].date_completed != ""{
                let dateString = self.daysListData[index].date_completed.components(separatedBy: " ")
                self.lastChallengeDate = dateString[0]
                index1 = index
            }
        }
        return (self.lastChallengeDate, index1)
    }
    
    func pushViewController(sender_Tag: Int){
        
        let obj = WWMLearnStepListVC()
        var flag = 0
        var position = 0
                
        if self.daysListData[sender_Tag].completed{
            self.appPreference.setType(value: "learn")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTodaysChallengeVC") as! WWMTodaysChallengeVC
            
            WWMHelperClass.day_type = "30days"
            WWMHelperClass.day_30_name = self.daysListData[sender_Tag].day_name
            vc.daysListData = self.daysListData[sender_Tag]
            self.navigationController?.pushViewController(vc, animated: true)
            
            return
        }else{
            for i in 0..<sender_Tag{
                let date_completed = self.daysListData[i].date_completed
                if date_completed != ""{
                    let dateCompare = WWMHelperClass.dateComparison1(expiryDate: date_completed)
                    if dateCompare.0 == 1{
                        flag = 1
                        break
                    }
                }
            }
        }
        
        //its mean you have done todays challenge
        if flag == 1{
            obj.xibCall(title1: KLEARNONESTEP)
            return
        }
        
        for i in 0..<sender_Tag{
            if !self.daysListData[i].completed{
                flag = 2
                position = i
                break
            }
        }
        
        //its mean you have not done previous step
        if flag == 2{
            obj.xibCall(title1: "\(KLEARNJUMPSTEP) \(self.daysListData[position].day_name) \(KLEARNJUMPSTEP1)")
        }else{
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTodaysChallengeVC") as! WWMTodaysChallengeVC
            
            WWMHelperClass.day_type = "30days"
            WWMHelperClass.day_30_name = self.daysListData[sender_Tag].day_name
            vc.daysListData = self.daysListData[sender_Tag]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension WWM30DaysChallengeVC{
    func retakeChallengeApi() {
        
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
            "user_id"  : self.appPreference.getUserID(),
            "guided_id": "",
            "type"     : "30days",
            "action"   : "flushdata"
            ] as [String : Any]
        
        //print("retakeChallenge param... \(param)")
        
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_RETAKE, context: "WWM21DayChallengeVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                //print("retake api... \(result)")
                self.appPreference.setType(value: "learn")
                self.appPreference.setGuideTypeFor3DTouch(value: "learn")
                self.appPreference.set21ChallengeName(value: "30 Day Challenge")
                self.getLearnAPI1()
            }else {
                WWMHelperClass.hideLoaderAnimate(on: self.view)
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                }
            }
        }
    }
    
    func getLearnAPI1() {
        
        //self.learnStepsListData.removeAll()
        let param = ["user_id": self.appPreference.getUserID()] as [String : Any]
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_LEARN_, context: "WWMLearnStepListVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            
            if let _ = result["success"] as? Bool {
                DispatchQueue.main.async {
                    WWMHelperClass.hideLoaderAnimate(on: self.view)
                }
                
                if let total_paid = result["total_paid"] as? Double{
                    WWMHelperClass.total_paid = Int(round(total_paid))
                }
                
                if let data = result["data"] as? [[String: Any]]{
                    print("learn result... \(result) getLearnAPI count... \(data.count)")
                    
                    let getDBLearn = WWMHelperClass.fetchDB(dbName: "DBLearn") as! [DBLearn]
                    if getDBLearn.count > 0 {
                        WWMHelperClass.deletefromDb(dbName: "DBLearn")
                    }
                    
                    let getStepsData = WWMHelperClass.fetchDB(dbName: "DBSteps") as! [DBSteps]
                    if getStepsData.count > 0 {
                        WWMHelperClass.deletefromDb(dbName: "DBSteps")
                    }
                    
                    let getThirtyDaysData = WWMHelperClass.fetchDB(dbName: "DBThirtyDays") as! [DBThirtyDays]
                    if getThirtyDaysData.count > 0 {
                        WWMHelperClass.deletefromDb(dbName: "DBThirtyDays")
                    }
                    
                    let getEightWeekData = WWMHelperClass.fetchDB(dbName: "DBEightWeek") as! [DBEightWeek]
                    if getEightWeekData.count > 0 {
                        WWMHelperClass.deletefromDb(dbName: "DBEightWeek")
                    }
                    
                    for dict in data{
                        
                        let dbLearnData = WWMHelperClass.fetchEntity(dbName: "DBLearn") as! DBLearn
                        
                        let timeInterval = Int(Date().timeIntervalSince1970)
                        //print("timeInterval.... \(timeInterval)")
                        dbLearnData.last_time_stamp = "\(timeInterval)"
                        
                        if dict["name"] as? String == "30 Day Challenge"{
                            self.appPreference.set30IntroCompleted(value: dict["intro_completed"] as? Bool ?? false)
                            self.appPreference.set30DaysURL(value: dict["intro_url"] as? String ?? "")
                            self.appPreference.set30DaysIsExpired(value: dict["is_expired"] as? Bool ?? false)
                        }
                        
                        if dict["name"] as? String == "8 Weeks Challenge"{
                            self.appPreference.set8IntroCompleted(value: dict["intro_completed"] as? Bool ?? false)
                            self.appPreference.set8WeekURL(value: dict["intro_url"] as? String ?? "")
                            self.appPreference.set8WeekIsExpired(value: dict["is_expired"] as? Bool ?? false)
                        }
                                                
                        if let name = dict["name"] as? String{
                            dbLearnData.name = name
                        }
                        
                        if let intro_url = dict["intro_url"] as? String{
                            dbLearnData.intro_url = intro_url
                        }
                        
                        if let intro_completed = dict["intro_completed"] as? Bool{
                            dbLearnData.intro_completed = intro_completed
                        }
                        
                        if let min_limit = dict["min_limit"] as? String{
                            dbLearnData.min_limit = min_limit
                        }
                        
                        if let max_limit = dict["max_limit"] as? String{
                            dbLearnData.max_limit = max_limit
                        }
                        
                        if let is_expired = dict["is_expired"] as? Bool{
                            dbLearnData.is_expired = is_expired
                        }else{
                            dbLearnData.is_expired = false
                        }
                        
                        if let step_list = dict["step_list"] as? [[String: Any]]{
                            for dict in step_list{
                                let dbStepsData = WWMHelperClass.fetchEntity(dbName: "DBSteps") as! DBSteps
                                if let completed = dict["completed"] as? Bool{
                                    dbStepsData.completed = completed
                                }
                                
                                if let date_completed = dict["date_completed"] as? String{
                                    dbStepsData.date_completed = date_completed
                                }
                                
                                if let description = dict["description"] as? String{
                                    dbStepsData.description1 = description
                                }
                                
                                if let id = dict["id"]{
                                    dbStepsData.id = "\(id)"
                                }
                                
                                if let outro_audio = dict["outro_audio"] as? String{
                                    dbStepsData.outro_audio = outro_audio
                                }
                                
                                if let step_audio = dict["step_audio"] as? String{
                                    dbStepsData.step_audio = step_audio
                                }
                                
                                if let step_name = dict["step_name"] as? String{
                                    dbStepsData.step_name = step_name
                                }
                                
                                if let timer_audio = dict["timer_audio"] as? String{
                                    dbStepsData.timer_audio = timer_audio
                                }
                                
                                if let title = dict["title"] as? String{
                                    dbStepsData.title = title
                                }
                                
                                if let min_limit = dict["min_limit"] as? String{
                                    dbStepsData.min_limit = min_limit
                                }else{
                                    dbStepsData.min_limit = "95"
                                }
                                
                                if let max_limit = dict["max_limit"] as? String{
                                    dbStepsData.max_limit = max_limit
                                }else{
                                    dbStepsData.max_limit = "98"
                                }
                                
                                WWMHelperClass.saveDb()
                                
                            }
                        }
                        
                        if let day_list = dict["day_list"] as? [[String: Any]]{
                            for dict in day_list{
                                let dbThirtyDays = WWMHelperClass.fetchEntity(dbName: "DBThirtyDays") as! DBThirtyDays
                                                                
                                if let id = dict["id"]{
                                    dbThirtyDays.id = "\(id)"
                                }
                                
                                if let day_name = dict["day_name"] as? String{
                                    dbThirtyDays.day_name = day_name
                                }
                                
                                if let auther_name = dict["auther_name"] as? String{
                                    dbThirtyDays.auther_name = auther_name
                                }
                                
                                if let description = dict["description"] as? String{
                                    dbThirtyDays.description1 = description
                                }
                                
                                if let is_milestone = dict["is_milestone"] as? Bool{
                                    dbThirtyDays.is_milestone = is_milestone
                                }
                                
                                if let min_limit = dict["min_limit"] as? String{
                                    dbThirtyDays.min_limit = min_limit
                                }else{
                                    dbThirtyDays.min_limit = "95"
                                }
                                
                                if let max_limit = dict["max_limit"] as? String{
                                    dbThirtyDays.max_limit = max_limit
                                }else{
                                    dbThirtyDays.max_limit = "98"
                                }
                                
                                if let prep_time = dict["prep_time"] as? String{
                                    dbThirtyDays.prep_time = prep_time
                                }else{
                                    dbThirtyDays.prep_time = "60"
                                }
                                
                                if let meditation_time = dict["meditation_time"] as? String{
                                    dbThirtyDays.meditation_time = meditation_time
                                }else{
                                    dbThirtyDays.meditation_time = "1200"
                                }
                                
                                if let rest_time = dict["rest_time"] as? String{
                                    dbThirtyDays.rest_time = rest_time
                                }else{
                                    dbThirtyDays.rest_time = "120"
                                }
                                
                                if let prep_min = dict["prep_min"] as? String{
                                    dbThirtyDays.prep_min = prep_min
                                }else{
                                    dbThirtyDays.prep_min = "0"
                                }
                                
                                if let prep_max = dict["prep_max"] as? String{
                                    dbThirtyDays.prep_max = prep_max
                                }else{
                                    dbThirtyDays.prep_max = "300"
                                }
                                
                                if let rest_min = dict["rest_min"] as? String{
                                    dbThirtyDays.rest_min = rest_min
                                }else{
                                    dbThirtyDays.prep_max = "0"
                                }
                                
                                if let rest_max = dict["rest_max"] as? String{
                                    dbThirtyDays.rest_max = rest_max
                                }else{
                                    dbThirtyDays.prep_max = "600"
                                }
                                
                                if let med_min = dict["med_min"] as? String{
                                    dbThirtyDays.med_min = med_min
                                }else{
                                    dbThirtyDays.med_min = "0"
                                }
                                
                                if let med_max = dict["med_max"] as? String{
                                    dbThirtyDays.med_max = med_max
                                }else{
                                    dbThirtyDays.med_max = "2400"
                                }
                                
                                if let completed = dict["completed"] as? Bool{
                                    dbThirtyDays.completed = completed
                                }
                                
                                if let date_completed = dict["date_completed"] as? String{
                                    dbThirtyDays.date_completed = date_completed
                                }
                                
                                if let image = dict["image"] as? String{
                                    dbThirtyDays.image = image
                                }
                                
                                WWMHelperClass.saveDb()
                            }
                        }
                        
                        //8 week
                        if let daywise_list = dict["daywise_list"] as? [[String: Any]]{
                            for dict in daywise_list{
                                let dbEightWeek = WWMHelperClass.fetchEntity(dbName: "DBEightWeek") as! DBEightWeek
                                                                
                                if let id = dict["id"]{
                                    dbEightWeek.id = "\(id)"
                                }
                                
                                if let day_name = dict["day_name"] as? String{
                                    dbEightWeek.day_name = day_name
                                }
                                
                                if let auther_name = dict["auther_name"] as? String{
                                    dbEightWeek.auther_name = auther_name
                                }
                                
                                if let description = dict["description"] as? String{
                                    dbEightWeek.description1 = description
                                }
                                
                                if let secondDescription = dict["second_description"] as? String{
                                    dbEightWeek.secondDescription = secondDescription
                                }else{
                                    dbEightWeek.secondDescription = ""
                                }
                                
                                if let image = dict["image"] as? String{
                                    dbEightWeek.image = image
                                }else{
                                    dbEightWeek.image = ""
                                }
                                
                                if let min_limit = dict["min_limit"] as? String{
                                    dbEightWeek.min_limit = min_limit
                                }else{
                                    dbEightWeek.min_limit = "95"
                                }
                                
                                if let max_limit = dict["max_limit"] as? String{
                                    dbEightWeek.max_limit = max_limit
                                }else{
                                    dbEightWeek.max_limit = "98"
                                }
                                
                                if let completed = dict["completed"] as? Bool{
                                    dbEightWeek.completed = completed
                                }
                                
                                if let date_completed = dict["date_completed"] as? String{
                                    dbEightWeek.date_completed = date_completed
                                }
                                                                
                                if let is_pre_opened = dict["is_pre_opened"] as? Bool{
                                    dbEightWeek.is_pre_opened = is_pre_opened
                                }
                                
                                if let second_session_required = dict["second_session_required"] as? Bool{
                                    dbEightWeek.second_session_required = second_session_required
                                }
                                
                                if let second_session_completed = dict["second_session_completed"] as? Bool{
                                    dbEightWeek.second_session_completed = second_session_completed
                                }
                                
                                WWMHelperClass.saveDb()
                            }
                        }
                        
                        WWMHelperClass.saveDb()
                    }
                }
                
                DispatchQueue.main.async {
                    WWMHelperClass.hideLoaderAnimate(on: self.view)
                    self.callHomeVC1()
                }
            }
        }
    }
}
