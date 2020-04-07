//
//  WWMEditMeditationTimeVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 15/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMEditMeditationTimeVC: WWMBaseViewController {

    
    @IBOutlet weak var layoutSliderPrepTimeWidth: NSLayoutConstraint!
    @IBOutlet weak var lblPrepTime: UILabel!
    @IBOutlet weak var sliderPrepTime: WWMSlider!
    @IBOutlet weak var layoutSliderMeditationTimeWidth: NSLayoutConstraint!
    @IBOutlet weak var lblMeditationTime: UILabel!
    @IBOutlet weak var sliderMeditationTime: WWMSlider!
    @IBOutlet weak var layoutSliderRestTimeWidth: NSLayoutConstraint!
    @IBOutlet weak var lblRestTime: UILabel!
    @IBOutlet weak var sliderRestTime: WWMSlider!
    
    @IBOutlet weak var btnSaveSettings: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    var settingData = DBSettings()
    var selectedMeditationData  = DBMeditationData()
    var selectedLevelData  = DBLevelData()
    
    var min = 0
    var prepTime = 0
    var restTime = 0
    var meditationTime = 0
    
    var min_limit = ""
    var max_limit = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpViewAndDataFetch()
    }
    
    func setUpViewAndDataFetch() {
        self.setUpNavigationBarForDashboard(title: "Settings")
        self.btnSaveSettings.layer.borderWidth = 2.0
        self.btnSaveSettings.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.btnCancel.layer.borderWidth = 2.0
        self.btnCancel.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        print(self.userData.name)
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
            if let meditationData = settingData.meditationData?.array as? [DBMeditationData]{
                for dic in meditationData{
                    if dic.isMeditationSelected {
                        self.selectedMeditationData = dic
                        if let levels = self.selectedMeditationData.levels?.array as? [DBLevelData]{
                            for level in levels{
                                if level.isLevelSelected {
                                    selectedLevelData = level
                                    self.setUpSliderTimesAccordingToLevels()
                                }
                            }//end level
                        }
                    }
                }//end meditationData
            }
        }
        
    }

    override func viewDidLayoutSubviews() {
        self.layoutSliderPrepTimeWidth.constant = self.sliderPrepTime.superview?.frame.size.height ?? 0.0
        self.layoutSliderRestTimeWidth.constant = self.sliderPrepTime.superview?.frame.size.height ?? 0.0
        self.layoutSliderMeditationTimeWidth.constant = self.sliderPrepTime.superview?.frame.size.height ?? 0.0
        
       // self.sliderPrepTime.setMinimumTrackImage(UIImage.init(named: "minSlider_Icon"), for: .normal)
       // self.sliderRestTime.setMinimumTrackImage(UIImage.init(named: "minSlider_Icon"), for: .normal)
      //  self.sliderMeditationTime.setMinimumTrackImage(UIImage.init(named: "minSlider_Icon"), for: .normal)
    }
    
    func setUpSliderTimesAccordingToLevels() {
        self.sliderPrepTime.minimumValue = Float(self.selectedLevelData.minPrep)
        self.sliderPrepTime.maximumValue = Float(self.selectedLevelData.maxPrep)
        self.sliderPrepTime.value = Float(settingData.prepTime ?? "0") ?? 0
        self.lblPrepTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderPrepTime.value))
        
        self.sliderMeditationTime.minimumValue = Float(self.selectedLevelData.minMeditation)
        self.sliderMeditationTime.maximumValue = Float(self.selectedLevelData.maxMeditation)
        print("settingData.meditationTime*** \(settingData.meditationTime)")
        self.sliderMeditationTime.value = Float(settingData.meditationTime ?? "0") ?? 0
        self.lblMeditationTime.text = self.secondsToMinutesSeconds1(second: Int(self.sliderMeditationTime.value))
        
        self.sliderRestTime.minimumValue = Float(self.selectedLevelData.minRest)
        self.sliderRestTime.maximumValue = Float(self.selectedLevelData.maxRest)
        self.sliderRestTime.value = Float(settingData.restTime ?? "0") ?? 0
        self.lblRestTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderRestTime.value))
    }
    // MARK: - UIButton Action
    
    
    @IBAction func sliderPrepTimeValueChangedAction(_ sender: Any) {
        print("self.sliderPrepTime.value....\(Int(self.sliderPrepTime.value))")
        
        self.min = Int(self.sliderPrepTime.value)/60
        
        if (self.min != 0){
            if self.min < 2{
                self.prepTime = Int(self.sliderPrepTime.value/15) * 15
            }else{
                //Modified By Akram
                self.prepTime = Int(self.sliderPrepTime.value/30) * 30
            }
        }else{
            self.prepTime = Int(self.sliderPrepTime.value/15) * 15
        }
        
        self.lblPrepTime.text = self.secondsToMinutesSeconds(second: Int(self.prepTime))
        self.selectedLevelData.prepTime = Int32(self.prepTime)
        
        self.settingData.prepTime = "\(self.prepTime)"
    }
    
    
    @IBAction func sliderMeditationTimeValueChangedAction(_ sender: Any) {
        
        self.min = Int(self.sliderMeditationTime.value)/60
        
        if (self.min != 0){
            self.meditationTime = Int(self.sliderMeditationTime.value/60) * 60
        }else{
            self.meditationTime = Int(self.sliderMeditationTime.value/60) * 60
        }
        
        self.lblMeditationTime.text = self.secondsToMinutesSeconds1(second: Int(self.meditationTime))
        self.selectedLevelData.meditationTime = Int32(self.meditationTime)
        
        print("self.meditationTime... \(self.meditationTime)")

        self.settingData.meditationTime = "\(self.meditationTime)"
    }
    
    @IBAction func sliderRestTimeValueChangedAction(_ sender: Any) {
        
        self.min = Int(self.sliderRestTime.value)/60
        
        if (self.min != 0){
            if self.min < 2{
                self.restTime = Int(self.sliderRestTime.value/15) * 15
            }else{
                self.restTime = Int(self.sliderRestTime.value/30) * 30
                if self.min >= 5{
                    self.restTime = Int(self.sliderRestTime.value/60) * 60
                }
            }
        }else{
            self.restTime = Int(self.sliderRestTime.value/15) * 15
        }
                
        self.lblRestTime.text = self.secondsToMinutesSeconds(second: Int(self.restTime))
        self.selectedLevelData.restTime = Int32(self.restTime)
        
        self.settingData.restTime = "\(self.restTime)"
    }
    
    @IBAction func btnSaveSettingAction(_ sender: Any) {
        
        if self.appPreference.isLogin(){
            DispatchQueue.global(qos: .background).async {
                let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
                       if data.count > 0 {
                           self.settingAPI()
                }
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCancelAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
    func secondsToMinutesSeconds (second : Int) -> String {
        if second<60 {
            return "\(second) sec"
        }else {
            return String.init(format: "%d:%02d min", second/60,second%60)
        }
    }
    */
    func secondsToMinutesSeconds (second : Int) -> String {
        if second<60 {
            return String.init(format: "%d:%02d", second/60,second%60)
        }else {
            if self.min == 1{
                return String.init(format: "%d:%02d", second/60,second%60)
            }else{
                // Modified By Akram
                // return String.init(format: "%d mins", second/60)
                if self.min >= 5 {
                    //return String.init(format: "%d:%02d mins", second/60,second%60)
                    return String.init(format: "%d mins", second/60,second%60)
                }
                return String.init(format: "%d:%02d", second/60,second%60)
                
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
    
    // MARK:- API Calling
    
    func settingAPI() {
        
        var meditation_data = [[String:Any]]()
        let meditationData = self.settingData.meditationData!.array as? [DBMeditationData]
        for dic in meditationData!{
            
            if dic.meditationName == "Beeja"{
                self.min_limit = dic.min_limit ?? "94"
                self.max_limit = dic.max_limit ?? "97"
            }
            
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
            
            if dic.min_limit == "" || dic.min_limit == nil{
                let data = ["meditation_id":dic.meditationId,
                            "meditation_name":dic.meditationName ?? "",
                            "isSelected":dic.isMeditationSelected,
                            "setmyown" : dic.setmyown,
                            "min_limit" : self.min_limit,
                            "max_limit" : self.max_limit,
                            "levels":levelDic] as [String : Any]
                meditation_data.append(data)
            }else{
                let data = ["meditation_id":dic.meditationId,
                            "meditation_name":dic.meditationName ?? "",
                            "isSelected":dic.isMeditationSelected,
                            "setmyown" : dic.setmyown,
                            "min_limit" : dic.min_limit ?? "94",
                            "max_limit" : dic.max_limit ?? "97",
                            "levels":levelDic] as [String : Any]
                meditation_data.append(data)
            }
        }
        
        let group = [
            "startChime": self.settingData.startChime!,
            "endChime": self.settingData.endChime!,
            "finishChime": self.settingData.finishChime!,
            "intervalChime": self.settingData.intervalChime!,
            "ambientSound": self.settingData.ambientChime!,
            "moodMeterEnable": self.settingData.moodMeterEnable,
            "IsMorningReminder": self.settingData.isMorningReminder,
            "IsMilestoneAndRewards":self.settingData.isMilestoneAndRewards,
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
        
        print("edit param... \(param)")
        
        WWMWebServices.requestAPIWithBody(param:param, urlString: URL_SETTINGS, context: "WWMEditMeditationTimeVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let success = result["success"] as? Bool {
                    print(success)
                    print("WWMEditMeditationTimeVC background thread")
                }
            }
        }
    }
    
    func logoutAPI() {
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
            "token" : appPreference.getToken()
        ]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_LOGOUT, context: "WWMEditMeditationTimeVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                self.appPreference.setIsLogin(value: false)
                self.appPreference.setUserToken(value: "")
                self.appPreference.setUserID(value: "")
                self.appPreference.setIsProfileCompleted(value: false)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "logoutSuccessful"), object: nil)
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWelcomeBackVC") as! WWMWelcomeBackVC
                let vcc = UINavigationController.init(rootViewController: vc)
                UIApplication.shared.keyWindow?.rootViewController = vcc
                
            }else {
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
