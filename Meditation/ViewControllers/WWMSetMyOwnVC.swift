//
//  WWMSetMyOwnVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 01/03/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMSetMyOwnVC: WWMBaseViewController {

    @IBOutlet weak var txtViewMeditationName: UITextField!
    @IBOutlet weak var layoutSliderPrepTimeWidth: NSLayoutConstraint!
    @IBOutlet weak var lblPrepTime: UILabel!
    @IBOutlet weak var sliderPrepTime: WWMSlider!
    @IBOutlet weak var layoutSliderMeditationTimeWidth: NSLayoutConstraint!
    @IBOutlet weak var lblMeditationTime: UILabel!
    @IBOutlet weak var sliderMeditationTime: WWMSlider!
    @IBOutlet weak var layoutSliderRestTimeWidth: NSLayoutConstraint!
    @IBOutlet weak var lblRestTime: UILabel!
    @IBOutlet weak var sliderRestTime: WWMSlider!
    
    @IBOutlet weak var btnSubmit: UIButton!
    
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var userName: UILabel!
    var type = ""
    var selectedMeditation_Id = -1
    var selectedLevel_Id = -1
    var isFromSetting = false
    var settingData = DBSettings()
    
    var prepTime = 0
    var meditationTime = 0
    var restTime = 0
    var min = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpView()
    }
    
    func setUpView() {
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
            if let meditationData = settingData.meditationData?.array as?  [DBMeditationData] {
                
            }
        }
        self.setNavigationBar(isShow: false, title: "")
        
        if self.appPreference.getUserName().contains(" "){
            let userNameArr = self.appPreference.getUserName().components(separatedBy: " ")
            self.userName.text = "Ok \(userNameArr[0]),"
        }else{
            self.userName.text = "Ok \(self.appPreference.getUserName()),"
        }
        
        self.btnSubmit.layer.borderWidth = 2.0
        self.btnSubmit.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.setUpSliderTimesAccordingToLevels()
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//    }
    
    override func viewDidLayoutSubviews() {
        self.layoutSliderPrepTimeWidth.constant = self.sliderPrepTime.superview?.frame.size.height ?? 0.0
        self.layoutSliderRestTimeWidth.constant = self.sliderPrepTime.superview?.frame.size.height ?? 0.0
        self.layoutSliderMeditationTimeWidth.constant = self.sliderPrepTime.superview?.frame.size.height ?? 0.0
        
       // self.sliderPrepTime.setMinimumTrackImage(UIImage.init(named: "minSlider_Icon"), for: .normal)
       // self.sliderRestTime.setMinimumTrackImage(UIImage.init(named: "minSlider_Icon"), for: .normal)
       // self.sliderMeditationTime.setMinimumTrackImage(UIImage.init(named: "minSlider_Icon"), for: .normal)
    }
    
    func setUpSliderTimesAccordingToLevels() {
        self.sliderPrepTime.minimumValue = 0
        self.sliderPrepTime.maximumValue = 3600
        self.sliderPrepTime.value = 0
        self.lblPrepTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderPrepTime.value))
        self.prepTime = Int(self.sliderPrepTime.value)
        
        self.sliderMeditationTime.minimumValue = 0
        self.sliderMeditationTime.maximumValue = 7200
        self.sliderMeditationTime.value = 0
        self.lblMeditationTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderMeditationTime.value))
        self.meditationTime = Int(self.sliderMeditationTime.value)
        
        self.sliderRestTime.minimumValue = 0
        self.sliderRestTime.maximumValue = 3600
        self.sliderRestTime.value = 0
        self.lblRestTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderRestTime.value))
        self.restTime = Int(self.sliderRestTime.value)
    }
    
    func secondsToMinutesSeconds (second : Int) -> String {
        if second<60 {
            return String.init(format: "%d:%02d", second/60,second%60)
        }else {
            if self.min == 1{
                return String.init(format: "%d:%02d", second/60,second%60)
            }else{
                return String.init(format: "%d mins", second/60)
            }
        }
    }
    
    func secondsToMinutesSeconds1 (second : Int) -> String {
        if second<60 {
            return String.init(format: "%d:%02d", second/60,second%60)
        }else {
            if self.min >= 2{
                return String.init(format: "%d mins", second/60,second%60)
            }else{
                return String.init(format: "%d min", second/60)
            }
        }
    }
    // MARK: - UIButton Action
    
    
    @IBAction func sliderPrepTimeValueChangedAction(_ sender: Any) {
        self.min = Int(self.sliderPrepTime.value)/60
        
        if (self.min != 0){
            if self.min < 2{
                self.prepTime = Int(self.sliderPrepTime.value/15) * 15
            }else{
                self.prepTime = Int(self.sliderPrepTime.value/60) * 60
            }
        }else{
            self.prepTime = Int(self.sliderPrepTime.value/15) * 15
        }
        self.lblPrepTime.text = self.secondsToMinutesSeconds(second: Int(self.prepTime))
    }
    @IBAction func sliderMeditationTimeValueChangedAction(_ sender: Any) {
        self.min = Int(self.sliderMeditationTime.value)/60
        
        if (self.min != 0){
            self.meditationTime = Int(self.sliderMeditationTime.value/60) * 60
        }else{
            self.meditationTime = Int(self.sliderMeditationTime.value/60) * 60
        }
        
        self.lblMeditationTime.text = self.secondsToMinutesSeconds1(second: Int(self.meditationTime))
    }
    @IBAction func sliderRestTimeValueChangedAction(_ sender: Any) {
        self.min = Int(self.sliderRestTime.value)/60
        
        if (self.min != 0){
            if self.min < 2{
                self.restTime = Int(self.sliderRestTime.value/15) * 15
            }else{
                self.restTime = Int(self.sliderRestTime.value/60) * 60
            }
        }else{
            self.restTime = Int(self.sliderRestTime.value/15) * 15
        }
        
        self.lblRestTime.text = self.secondsToMinutesSeconds(second: Int(self.restTime))
    }
    
    @IBAction func btnSaveSettingAction(_ sender: Any) {

        if txtViewMeditationName.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: "Please enter meditation name", title: kAlertTitle)
        }else {
            self.setMyOwnAPI()
        }
    }

    
    @IBAction func btnSetMyOwnBackAction(_ sender: UIButton) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func setMyOwnAPI() {
        self.view.endEditing(true)
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
            "user_id":self.appPreference.getUserID(),
            "meditation_name":txtViewMeditationName.text ?? "",
            "prep_time":"\(self.prepTime)",
            "meditation_time":"\(self.meditationTime)",
            "rest_time":"\(self.restTime)",
            "setmyown": 1,
            "level_name": "Beginner",
            "prep_min": "0",
            "prep_max": "3600",
            "rest_min": "0",
            "rest_max": "3600",
            "med_min": "0",
            "med_max": "7200"
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_SETMYOWN, context: "WWMSetMyOwnVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let result1 = result["result"] as? [String:Any] {
                    self.selectedMeditation_Id = result1["meditation_id"] as! Int
                    self.selectedLevel_Id = result1["level_id"] as! Int
                    if self.isFromSetting {
                        self.saveDataToSetting()
                         //WWMHelperClass.dismissSVHud()
                    }else {
                       self.meditationApi()
                    }
                    
                }else {
                     WWMHelperClass.showPopupAlertController(sender: self, message:  result["message"] as? String ?? "", title: kAlertTitle)
                     //WWMHelperClass.dismissSVHud()
                    WWMHelperClass.hideLoaderAnimate(on: self.view)
                }

            }else {
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                }
                 //WWMHelperClass.dismissSVHud()
                  WWMHelperClass.hideLoaderAnimate(on: self.view)
            }
           
        }
    }
    
    func meditationApi() {
        self.view.endEditing(true)
        //WWMHelperClass.showSVHud()
        let param = [
            "meditation_id" : self.selectedMeditation_Id,
            "level_id"         : self.selectedLevel_Id,
            "user_id"       : self.appPreference.getUserID(),
            "type" : "timer",
            "guided_type" : ""
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_MEDITATIONDATA, context: "WWMSetMyOwnVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let sucessAPI = result["success"] as? Bool {
                    if sucessAPI {
                        self.appPreference.setIsProfileCompleted(value: true)
                        self.appPreference.setGuideType(value: "")
                        self.appPreference.setType(value: "timer")
                        UIView.transition(with: self.welcomeView, duration: 1.0, options: .transitionCrossDissolve, animations: {
                            self.welcomeView.isHidden = false
                        }) { (Bool) in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                
                                self.appPreference.setGetProfile(value: true)
                              /*  let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                                UIApplication.shared.keyWindow?.rootViewController = vc*/
                                if #available(iOS 13.0, *) {
                                    let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                                    window?.rootViewController = AppDelegate.sharedDelegate().animatedTabBarController()
                                    
                                } else {
                                    UIApplication.shared.keyWindow?.rootViewController = AppDelegate.sharedDelegate().animatedTabBarController()
                                }
                                
                            }
                        }
                    }else {
                        WWMHelperClass.showPopupAlertController(sender: self, message:  result["message"] as? String ?? "", title: kAlertTitle)
                    }
                
            }else {
                    if error != nil {
                        if error?.localizedDescription == "The Internet connection appears to be offline."{
                            WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                        }else{
                            WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                        }
                    }
                 
            }
            //WWMHelperClass.dismissSVHud()
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }

}
    
    // MARK:- API Calling
    
    func saveDataToSetting() {
        if let meditationData = self.settingData.meditationData!.array as? [DBMeditationData] {
            for dic in meditationData {
                dic.isMeditationSelected = false
                if let levels = dic.levels?.array as? [DBLevelData] {
                    for dic in levels {
                        dic.isLevelSelected = false
                    }
                }
            }
        
        let meditationDB = WWMHelperClass.fetchEntity(dbName: "DBMeditationData") as! DBMeditationData
        meditationDB.meditationId = Int32(self.selectedMeditation_Id)
        meditationDB.setmyown = 1
        meditationDB.meditationName = self.txtViewMeditationName.text ?? ""
        meditationDB.isMeditationSelected = true
        
            let levelDB = WWMHelperClass.fetchEntity(dbName: "DBLevelData") as! DBLevelData
            levelDB.isLevelSelected = true
        
        settingData.prepTime = "\(self.prepTime)"
        settingData.meditationTime = "\(self.meditationTime)"
        settingData.restTime = "\(self.restTime)"
        
        levelDB.levelId = Int32(self.selectedLevel_Id)
            levelDB.levelName = "Beginner"
        levelDB.prepTime = Int32(self.prepTime)
        levelDB.meditationTime = Int32(self.meditationTime)
        levelDB.restTime = Int32(self.restTime)
            levelDB.minPrep = 0
            levelDB.minRest = 0
            levelDB.minMeditation = 0
            levelDB.maxPrep = 3600
            levelDB.maxRest = 3600
            levelDB.maxMeditation = 7200
            meditationDB.addToLevels(levelDB)
            self.settingData.addToMeditationData(meditationDB)
        }
        
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            self.settingAPI()
        }
    }
    
    func settingAPI() {
       // WWMHelperClass.showSVHud()
        
        var meditation_data = [[String:Any]]()
        let meditationData = self.settingData.meditationData!.array as? [DBMeditationData]
        for dic in meditationData!{
            let levels = dic.levels?.array as? [DBLevelData]
            var levelDic = [[String:Any]]()
            for level in levels! {
                let leveldata = [
                    "level_id": level.levelId,
                    "isSelected": level.isLevelSelected,
                    "name": level.levelName!,
                    "prep_time": "\(level.prepTime)",
                    "meditation_time": "\(level.meditationTime)",
                    "rest_time": "\(level.restTime)",
                    "prep_min": "\(level.minPrep)",
                    "prep_max": "\(level.maxPrep)",
                    "med_min": "\(level.minMeditation)",
                    "med_max": "\(level.maxMeditation)",
                    "rest_min": "\(level.minRest)",
                    "rest_max": "\(level.maxRest)"
                    ] as [String : Any]
                levelDic.append(leveldata)
            }
            
            let data = ["meditation_id":dic.meditationId,
                        "meditation_name":dic.meditationName ?? "",
                        "isSelected":dic.isMeditationSelected,
                        "setmyown" : dic.setmyown,
                        "levels":levelDic] as [String : Any]
            meditation_data.append(data)
        }
        
        let group = [
            "startChime": self.settingData.startChime!,
            "endChime": self.settingData.endChime!,
            "finishChime": self.settingData.finishChime!,
            "intervalChime": self.settingData.intervalChime!,
            "ambientSound": self.settingData.ambientChime!,
            "moodMeterEnable": self.settingData.moodMeterEnable,
            "IsMorningReminder": self.settingData.isMorningReminder,
            "MorningReminderTime": self.settingData.morningReminderTime!,
            "IsAfternoonReminder": self.settingData.isAfterNoonReminder,
            "AfternoonReminderTime": self.settingData.afterNoonReminderTime!,
            "meditation_data" : meditation_data
            ] as [String : Any]
        
        let param = [
            "user_id": self.appPreference.getUserID(),
            "isJson": true,
            "group": group
            ] as [String : Any]
        
        WWMWebServices.requestAPIWithBody(param:param, urlString: URL_SETTINGS, context: "WWMSetMyOwnVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let success = result["success"] as? Bool {
                    print(success)
                    self.navigationController?.popViewController(animated: true)
                }
            }else {
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                }
            }
            //WWMHelperClass.dismissSVHud()
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
}
