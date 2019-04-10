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
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.setUpViewAndDataFetch()
        // Do any additional setup after loading the view.
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
            let meditationData = settingData.meditationData!.array as? [DBMeditationData]
            for dic in meditationData!{
                if dic.isMeditationSelected {
                    self.selectedMeditationData = dic
                    let levels = self.selectedMeditationData.levels?.array as? [DBLevelData]
                    for level in levels! {
                        if level.isLevelSelected {
                            selectedLevelData = level
                            self.setUpSliderTimesAccordingToLevels()
                        }
                    }
                }
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
        self.sliderPrepTime.value = Float(settingData.prepTime!)!
        self.lblPrepTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderPrepTime.value))
        
        self.sliderMeditationTime.minimumValue = Float(self.selectedLevelData.minMeditation)
        self.sliderMeditationTime.maximumValue = Float(self.selectedLevelData.maxMeditation)
        self.sliderMeditationTime.value = Float(settingData.meditationTime!)!
        self.lblMeditationTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderMeditationTime.value))
        
        self.sliderRestTime.minimumValue = Float(self.selectedLevelData.minRest)
        self.sliderRestTime.maximumValue = Float(self.selectedLevelData.maxRest)
        self.sliderRestTime.value = Float(settingData.restTime!)!
        self.lblRestTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderRestTime.value))
    }
    // MARK: - UIButton Action
    
    
    @IBAction func sliderPrepTimeValueChangedAction(_ sender: Any) {
        self.lblPrepTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderPrepTime.value))
        self.selectedLevelData.prepTime = Int32(self.sliderPrepTime.value)
    }
    @IBAction func sliderMeditationTimeValueChangedAction(_ sender: Any) {
        self.lblMeditationTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderMeditationTime.value))
        self.selectedLevelData.meditationTime = Int32(self.sliderMeditationTime.value)
    }
    @IBAction func sliderRestTimeValueChangedAction(_ sender: Any) {
        self.lblRestTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderRestTime.value))
        self.selectedLevelData.restTime = Int32(self.sliderRestTime.value)
    }
    
    @IBAction func btnSaveSettingAction(_ sender: Any) {
        self.settingData.prepTime = "\(Int(self.sliderPrepTime.value))"
        self.settingData.restTime = "\(Int(self.sliderRestTime.value))"
        self.settingData.meditationTime = "\(Int(self.sliderMeditationTime.value))"
        self.settingAPI()
    }
    
    @IBAction func btnCancelAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func secondsToMinutesSeconds (second : Int) -> String {
        if second<60 {
            return "\(second) sec"
        }else {
            return String.init(format: "%d:%02d min", second/60,second%60)
        }
        
    }
    
    // MARK:- API Calling
    
    func settingAPI() {
        WWMHelperClass.showSVHud()
        
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
                        "meditation_name":dic.meditationName!,
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
        
        WWMWebServices.requestAPIWithBody(param:param, urlString: URL_SETTINGS, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
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
            WWMHelperClass.dismissSVHud()
        }
    }
    
    func logoutAPI() {
        WWMHelperClass.showSVHud()
        let param = [
            "token" : appPreference.getToken()
        ]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_LOGOUT, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                self.appPreference.setIsLogin(value: false)
                self.appPreference.setUserToken(value: "")
                self.appPreference.setUserID(value: "")
                self.appPreference.setIsProfileCompleted(value: false)
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
            WWMHelperClass.dismissSVHud()
        }
    }
}
