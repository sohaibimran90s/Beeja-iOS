//
//  WWMBaseViewController.swift
//  Meditation
//
//  Created by Roshan Kumawat on 10/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit

class WWMBaseViewController: UIViewController {

    let appPreference = WWMAppPreference()
    var userData = WWMUserData.sharedInstance
    var alertPopupView = WWMAlertController()
    var title1: String = ""
    var pushVC: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUserDataFromPreference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //self.setUserDataFromPreference()
    }
    
    func setUserDataFromPreference() {
        if self.appPreference.isLogout() {
            userData = WWMUserData.init(json: self.appPreference.getUserData())
        }
    }
    
    func setNavigationBar(isShow:Bool,title:String){
        self.navigationItem.title = title
        self.navigationController?.navigationBar.barTintColor = UIColor.init(hexString: "#292178")
        self.navigationController?.navigationItem.backBarButtonItem?.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor.white

        if isShow {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }else {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    
    func setUpNavigationBarForDashboard(title:String) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        let sideMenuBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 24, height: 24))
        
        self.title1 = title
        if title == "Settings"{
            sideMenuBtn.setImage(UIImage.init(named: "crossMenu"), for: .normal)
        }else{
            sideMenuBtn.setImage(UIImage.init(named: "waveMenu"), for: .normal)
        }
        
        sideMenuBtn.addTarget(self, action: #selector(btnSideMenuAction(_:)), for: .touchUpInside)
        sideMenuBtn.contentMode = .scaleAspectFit
        
        let leftTitle = UIButton.init()
        let btnBack = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 24, height: 24))
        
        let barButtonGuided = UIButton.init()
        let barButtonSleep = UIButton.init()
        
        barButtonGuided.addTarget(self, action: #selector(dropDownGuided), for: .touchUpInside)
        barButtonSleep.addTarget(self, action: #selector(dropDownSleep), for: .touchUpInside)
        
        //To give space between bar button items
        // Set 26px of fixed space between the two UIBarButtonItems
        let fixedSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        fixedSpace.width = 26.0
        
        // Set -7px of fixed space before the two UIBarButtonItems so that they are aligned to the edge
//        let negativeSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
//        negativeSpace.width = -7.0
        
        barButtonGuided.setTitle("Guided", for: .normal)
        barButtonGuided.titleLabel?.font = UIFont.init(name: "Maax-Bold", size: 24)
        barButtonGuided.titleLabel?.textAlignment = .left
        
        barButtonSleep.setTitle("Sleep", for: .normal)
        barButtonSleep.titleLabel?.font = UIFont.init(name: "Maax-Bold", size: 24)
        
        if title == "Timer" {
            leftTitle.setTitle("  Toggle Flight Mode", for: .normal)
            leftTitle.setTitleColor(UIColor.init(displayP3Red: 0/255, green: 18/255, blue: 82/255, alpha: 0.45), for: .normal)
            leftTitle.titleLabel?.font = UIFont.init(name: "Maax", size: 14)
            leftTitle.setImage(UIImage.init(named: "FlightMode_Icon"), for: .normal)
            leftTitle.addTarget(self, action: #selector(btnFlightModeAction(_:)), for: .touchUpInside)
            
            let leftBarButtonItem = UIBarButtonItem.init(customView: leftTitle)
            let btnBackItem = UIBarButtonItem.init(customView: btnBack)
            btnBack.setImage(UIImage.init(named: "Back_Arrow_Icon"), for: .normal)
            btnBack.addTarget(self, action: #selector(btnBackAction(_:)), for: .touchUpInside)
            
            if self.appPreference.get21ChallengeName() == "30 Day Challenge" || self.appPreference.get21ChallengeName() == "8 Weeks Challenge"{
                self.navigationItem.leftBarButtonItems = [btnBackItem, leftBarButtonItem]
            }else{
                self.navigationItem.leftBarButtonItem = leftBarButtonItem
            }
        }else if title == "guided" {
            
            self.appPreference.setGuidedSleep(value: "Guided")
            barButtonGuided.alpha = 1.0
            barButtonSleep.alpha = 0.5
            let leftBarButtonItem = UIBarButtonItem.init(customView: barButtonGuided)
            let leftBarButtonItem1 = UIBarButtonItem.init(customView: barButtonSleep)
            //self.navigationItem.leftBarButtonItems = [negativeSpace, leftBarButtonItem, fixedSpace, leftBarButtonItem1]
            self.navigationItem.leftBarButtonItems = [leftBarButtonItem, fixedSpace, leftBarButtonItem1]
            
        }else if title == "sleep" {
            
            self.appPreference.setGuidedSleep(value: "Sleep")
            barButtonGuided.alpha = 0.5
            barButtonSleep.alpha = 1.0
            let leftBarButtonItem = UIBarButtonItem.init(customView: barButtonGuided)
            let leftBarButtonItem1 = UIBarButtonItem.init(customView: barButtonSleep)
            //self.navigationItem.leftBarButtonItems = [negativeSpace, leftBarButtonItem, fixedSpace, leftBarButtonItem1]
            self.navigationItem.leftBarButtonItems = [leftBarButtonItem, fixedSpace, leftBarButtonItem1]
        }else{
            
            navigationController?.navigationBar.barTintColor = UIColor(hexString: "#001252")
            leftTitle.setTitle(title, for: .normal)
            leftTitle.setTitleColor(UIColor.white, for: .normal)
            leftTitle.titleLabel?.font = UIFont.init(name: "Maax-Bold", size: 24)
            
            let leftBarButtonItem = UIBarButtonItem.init(customView: leftTitle)
            self.navigationItem.leftBarButtonItem = leftBarButtonItem
        }
        
        let rightBarButtonItem = UIBarButtonItem.init(customView: sideMenuBtn)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func setUpCrossNavigationBar(title:String) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        let sideMenuBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 24, height: 24))
        
        self.title1 = title
        sideMenuBtn.setImage(UIImage.init(named: "crossMenu"), for: .normal)
        sideMenuBtn.addTarget(self, action: #selector(buttonCrossAction(_:)), for: .touchUpInside)
        sideMenuBtn.contentMode = .scaleAspectFit
        
        let backButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 25, height: 25))
        backButton.setImage(UIImage.init(named: ""), for: .normal)
        backButton.contentMode = .scaleAspectFit
        
        let leftBarButtonItem = UIBarButtonItem.init(customView: backButton)
        let rightBarButtonItem = UIBarButtonItem.init(customView: sideMenuBtn)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    @IBAction func buttonCrossAction(_ sender: UIButton) {
        if self.title1 == "ChooseMantra"{
            let arrVc = self.navigationController?.viewControllers
            for vc in arrVc! {
                if vc.isKind(of: WWMSettingsVC.classForCoder()){
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            }
        }
    }
    
    @objc func btnBackAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dropDownSleep(){
        //KNOTIFICATIONCENTER.post(name: Notification.Name("guidedDropDownClicked"), object: nil)
        KNOTIFICATIONCENTER.post(name: Notification.Name("guidedDropDownClicked"), object: nil, userInfo: ["type": "guided", "subType": "Sleep"])
    }
    
    @objc func dropDownGuided(){
        
         KNOTIFICATIONCENTER.post(name: Notification.Name("guidedDropDownClicked"), object: nil, userInfo: ["type": "guided", "subType": "Guided"])
    }
    
    func setUpNavigationBarForAudioGuided(title:String) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        self.title = title
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.clear
        
        let sideMenuBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 25, height: 25))
        sideMenuBtn.setImage(UIImage.init(named: "sideMenu_Icon"), for: .normal)
        sideMenuBtn.addTarget(self, action: #selector(btnSideMenuAction(_:)), for: .touchUpInside)
        sideMenuBtn.contentMode = .scaleAspectFit
        
        let backButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 25, height: 25))
        backButton.setImage(UIImage.init(named: "Back_Arrow_Icon"), for: .normal)
        backButton.addTarget(self, action: #selector(btnBackAction(_:)), for: .touchUpInside)
        backButton.contentMode = .scaleAspectFit
        
        let leftBarButtonItem = UIBarButtonItem.init(customView: backButton)
        let rightBarButtonItem = UIBarButtonItem.init(customView: sideMenuBtn)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    
    func isValidEmail(strEmail:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: strEmail)
    }
    
    func showPopUp(title:String, message:String) {

        alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView.btnOK.layer.borderWidth = 2.0
        alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        alertPopupView.lblTitle.text = title
        alertPopupView.lblSubtitle.text = message
        alertPopupView.btnClose.isHidden = true
        
        window.rootViewController?.view.addSubview(alertPopupView)
    }
    
    func callHomeVC(index: Int){
        self.navigationController?.isNavigationBarHidden = false
        if let tabController = self.tabBarController as? WWMTabBarVC {
            tabController.selectedIndex = index
            for index in 0..<tabController.tabBar.items!.count {
                let item = tabController.tabBar.items![index]
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
                if index == index {
                    item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
                }
            }
        }
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    func callHomeVC1(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    // MARK: Button Action
    
    @IBAction func btnSideMenuAction(_ sender: UIButton) {
        
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count < 1 {
            return
        }
        
        if self.title1 == "Settings"{
            if self.appPreference.get21ChallengeName() == "30 Day Challenge" || self.appPreference.get21ChallengeName() == "8 Weeks Challenge"{
                self.navigationController?.popViewController(animated: true)
                let controllers = self.navigationController?.viewControllers
                 for vc in controllers! {
                   if vc is WWMTimerHomeVC {
                     _ = self.navigationController?.popToViewController(vc as! WWMTimerHomeVC, animated: true)
                   }
                }
            }else{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSideMenuVC") as! WWMSideMenuVC
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    @IBAction func btnFlightModeAction(_ sender: UIButton) {
        xibCall1()
    }
    
    func xibCall1(){
        alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView.lblTitle.text = "Toggle Airplane mode"
        alertPopupView.lblSubtitle.text = "Go to Settings app main page and toggle the airplane mode."
        alertPopupView.btnOK.layer.borderWidth = 2.0
        alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        alertPopupView.btnOK.addTarget(self, action: #selector(btnDoneAction1(_:)), for: .touchUpInside)
        
        window.rootViewController?.view.addSubview(alertPopupView)
    }
    
    @IBAction func btnDoneAction1(_ sender: Any) {
        if let url = URL(string:UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func secondToMinuteSecond(second : Int) -> String {
        return String.init(format: "%02d:%02d", second/60,second%60)
    }
    
    func convertToDictionary1(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

extension WWMBaseViewController{
    
    func getInviteAcceptAPI(context1: String) {
        
        let param = ["user_id": self.appPreference.getUserID(), "challenge_type": "30days"] as [String : Any]
        //print("param... \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_INVITEACCEPTUSERS, context: context1, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            
            if let _ = result["success"] as? Bool {
                
                let data = result["result"] as? [String]
                self.appPreference.setInvitationCount(value: data?.count ?? 0)
            }
        }
    }
}

extension WWMBaseViewController{
    
    //guided api call
    func getGuidedListAPI() {
        
        let param = ["user_id":self.appPreference.getUserID()] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_GETGUIDEDDATA, context: "WWMGuidedAudioListVC Appdelegate", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                
                if let _ = result["success"] as? Bool {
                    
                    if let result = result["result"] as? [[String:Any]] {
                                                
                        let guidedData = WWMHelperClass.fetchDB(dbName: "DBGuidedData") as! [DBGuidedData]
                        if guidedData.count > 0 {
                            WWMHelperClass.deletefromDb(dbName: "DBGuidedData")
                        }
                        
                        let guidedEmotionsData = WWMHelperClass.fetchDB(dbName: "DBGuidedEmotionsData") as! [DBGuidedEmotionsData]
                        if guidedEmotionsData.count > 0 {
                            WWMHelperClass.deletefromDb(dbName: "DBGuidedEmotionsData")
                        }
                        
                        let guidedAudioData = WWMHelperClass.fetchDB(dbName: "DBGuidedAudioData") as! [DBGuidedAudioData]
                        if guidedAudioData.count > 0 {
                            WWMHelperClass.deletefromDb(dbName: "DBGuidedAudioData")
                        }
                        
                        for dict in result {
                            
                            if let meditation_list = dict["meditation_list"] as? [[String: Any]]{
                                
                                for meditationList in meditation_list {
                                    let dbGuidedData = WWMHelperClass.fetchEntity(dbName: "DBGuidedData") as! DBGuidedData
                                    
                                    let timeInterval = Int(Date().timeIntervalSince1970)
                                    
                                    dbGuidedData.last_time_stamp = "\(timeInterval)"
                                    dbGuidedData.cat_name = dict["name"] as? String
                                    
                                    if let id = meditationList["id"]{
                                        dbGuidedData.guided_id = "\(id)"
                                    }
                                    
                                    if let name = meditationList["name"] as? String{
                                        dbGuidedData.guided_name = name
                                    }
                                    
                                    if let meditation_type = meditationList["meditation_type"] as? String{
                                        dbGuidedData.meditation_type = meditation_type
                                    }
                                    
                                    if let guided_mode = meditationList["mode"] as? String{
                                        dbGuidedData.guided_mode = guided_mode
                                    }
                                    
                                    if let min_limit = meditationList["min_limit"] as? String{
                                        dbGuidedData.min_limit = min_limit
                                    }else{
                                        dbGuidedData.min_limit = "95"
                                    }
                                    
                                    if let max_limit = meditationList["max_limit"] as? String{
                                        dbGuidedData.max_limit = max_limit
                                    }else{
                                        dbGuidedData.max_limit = "98"
                                    }
                                    
                                    if let meditation_key = meditationList["meditation_key"] as? String{
                                        dbGuidedData.meditation_key = meditation_key
                                    }else{
                                        if let meditation_type = dict["meditation_type"] as? String{
                                            dbGuidedData.meditation_key = meditation_type
                                        }
                                    }
                                    
                                    if let complete_count = meditationList["complete_count"] as? Int{
                                        dbGuidedData.complete_count = "\(complete_count)"
                                    }else{
                                        dbGuidedData.complete_count = "0"
                                    }
                                    
                                    if let intro_url = meditationList["intro_url"] as? String{
                                        dbGuidedData.intro_url = intro_url
                                    }else{
                                        dbGuidedData.intro_url = ""
                                    }
                                    
                                    if let intro_completed = meditationList["intro_completed"] as? Bool{
                                        dbGuidedData.intro_completed = intro_completed
                                    }else{
                                        dbGuidedData.intro_completed = false
                                    }
                                                                        
                                    if let emotion_list = meditationList["emotion_list"] as? [[String: Any]]{
                                        for emotionsDict in emotion_list {
                                            
                                            let dbGuidedEmotionsData = WWMHelperClass.fetchEntity(dbName: "DBGuidedEmotionsData") as! DBGuidedEmotionsData
                                            
                                            if let id = meditationList["id"]{
                                                dbGuidedEmotionsData.guided_id = "\(id)"
                                            }
                                            
                                            if let emotion_id = emotionsDict["emotion_id"]{
                                                dbGuidedEmotionsData.emotion_id = "\(emotion_id)"
                                            }
                                            
                                            if let author_name = emotionsDict["author_name"]{
                                                dbGuidedEmotionsData.author_name = "\(author_name)"
                                            }
                                            
                                            if let emotion_image = emotionsDict["emotion_image"] as? String{
                                                dbGuidedEmotionsData.emotion_image = emotion_image
                                            }
                                            
                                            if let emotion_name = emotionsDict["emotion_name"] as? String{
                                                dbGuidedEmotionsData.emotion_name = emotion_name
                                            }
                                            
                                            if let intro_completed = emotionsDict["intro_completed"] as? Bool{
                                                dbGuidedEmotionsData.intro_completed = intro_completed
                                            }else{
                                                dbGuidedEmotionsData.intro_completed = false
                                            }
                                            
                                            if let tile_type = emotionsDict["tile_type"] as? String{
                                                dbGuidedEmotionsData.tile_type = tile_type
                                            }
                                            
                                            if let emotion_key = emotionsDict["emotion_key"] as? String{
                                                dbGuidedEmotionsData.emotion_key = emotion_key
                                            }
                                            
                                            if let emotion_body = emotionsDict["emotion_body"] as? String{
                                                dbGuidedEmotionsData.emotion_body = emotion_body
                                            }
                                            
                                            if let completed = emotionsDict["completed"] as? Bool{
                                                dbGuidedEmotionsData.completed = completed
                                            }
                                            
                                            if let completed_date = emotionsDict["completed_date"] as? String{
                                                dbGuidedEmotionsData.completed_date = completed_date
                                            }
                                            
                                            if let intro_url = emotionsDict["intro_url"] as? String{
                                                dbGuidedEmotionsData.intro_url = intro_url
                                            }else{
                                                dbGuidedEmotionsData.intro_url = ""
                                            }
                                            
                                            if let emotion_type = emotionsDict["emotion_type"] as? String{
                                                dbGuidedEmotionsData.emotion_type = emotion_type
                                            }else{
                                                dbGuidedEmotionsData.emotion_type = ""
                                            }
                                                                                        
                                            if let audio_list = emotionsDict["audio_list"] as? [[String: Any]]{
                                                for audioDict in audio_list {
                                                    
                                                    let dbGuidedAudioData = WWMHelperClass.fetchEntity(dbName: "DBGuidedAudioData") as! DBGuidedAudioData
                                                    
                                                    if let emotion_id = emotionsDict["emotion_id"]{
                                                        dbGuidedAudioData.emotion_id = "\(emotion_id)"
                                                    }
                                                    
                                                    if let audio_id = audioDict["id"]{
                                                        dbGuidedAudioData.audio_id = "\(audio_id)"
                                                    }
                                                    
                                                    if let audio_image = audioDict["audio_image"] as? String{
                                                        dbGuidedAudioData.audio_image = audio_image
                                                    }
                                                    
                                                    if let audio_name = audioDict["audio_name"] as? String{
                                                        dbGuidedAudioData.audio_name = audio_name
                                                    }
                                                    
                                                    if let audio_url = audioDict["audio_url"] as? String{
                                                        dbGuidedAudioData.audio_url = audio_url
                                                    }
                                                    
                                                    if let author_name = audioDict["author_name"] as? String{
                                                        dbGuidedAudioData.author_name = author_name
                                                    }
                                                    
                                                    if let duration = audioDict["duration"]{
                                                        dbGuidedAudioData.duration = "\(duration)"
                                                    }
                                                    
                                                    if let paid = audioDict["paid"] as? Bool{
                                                        dbGuidedAudioData.paid = paid
                                                    }
                                                    
                                                    if let vote = audioDict["vote"] as? Bool{
                                                        dbGuidedAudioData.vote = vote
                                                    }
                                                                                            
                                                    WWMHelperClass.saveDb()
                                                }
                                            }
                                            
                                            WWMHelperClass.saveDb()
                                        }
                                    }
                                }
                            }
                            WWMHelperClass.saveDb()
                        }
                    }
                }
            }
        }
    }//end guided api*

    //MARK: getLearnSetps API call
    func getLearnAPI() {
        
        //self.learnStepsListData.removeAll()
        let param = ["user_id": self.appPreference.getUserID()] as [String : Any]
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_LEARN_, context: "WWMLearnStepListVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            
            if let _ = result["success"] as? Bool {
                if let total_paid = result["total_paid"] as? Double{
                    WWMHelperClass.total_paid = Int(round(total_paid))
                }
                
                if let data = result["data"] as? [[String: Any]]{
                    
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
                 NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationLearn"), object: nil)
            }
        }
    }
}

//BASS-999
extension WWMBaseViewController{
    func invalidURLPopUp(pushVC: String, title1: String){
        self.pushVC = pushVC
        alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView.btnOK.layer.borderWidth = 2.0
        alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        alertPopupView.lblTitle.text = title1
        alertPopupView.lblSubtitle.isHidden = true
        alertPopupView.btnOK.setTitle(KOK, for: .normal)
        alertPopupView.btnClose.isHidden = true
        alertPopupView.btnOK.addTarget(self, action: #selector(btnPopUpAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertPopupView)
    }
    
    @IBAction func btnPopUpAction(_ sender: Any) {
        self.alertPopupView.removeFromSuperview()
        if self.pushVC == "homeTab"{
            self.navigationController?.popViewController(animated: true)
        }else if self.pushVC == "learnIntro"{
            self.callHomeVC1()
        }else if self.pushVC == "timer"{
            self.callHomeVC1()
        }else if self.pushVC == "learnOutro"{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnCongratsVC") as! WWMLearnCongratsVC
            self.appPreference.setType(value: "learn")
            vc.watched_duration = ""
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
}
