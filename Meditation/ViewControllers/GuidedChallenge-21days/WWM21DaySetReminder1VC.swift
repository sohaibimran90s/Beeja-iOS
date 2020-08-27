//
//  WWM21DaySetReminder1VC.swift
//  Meditation
//
//  Created by Prema Negi on 18/02/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class WWM21DaySetReminder1VC: WWMBaseViewController {
    
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var btnPickerView: UIButton!
    @IBOutlet weak var hourBtn: UIButton!
    @IBOutlet weak var minBtn: UIButton!
    @IBOutlet weak var amPmBtn: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    
    var type: String = ""
    let dateFormatter = DateFormatter()
    let datePicker = UIDatePicker()
    var date = Date()
    var finalTime: String = ""
    var settingData = DBSettings()
    var flag = 0
    var defaultDate = ""
    var isSetting = false
    var min_limit = ""
    var max_limit = ""
    //8_week
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appPreference.setGetProfile(value: false)
        self.setNavigationBar(isShow: false, title: "")
        self.setupView()
        
        txtView.tintColor = UIColor.clear
    }
    
    func setupView(){
        let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let attributeString = NSMutableAttributedString(string: KSKIP,
                                                        attributes: attributes)
        btnSkip.setAttributedTitle(attributeString, for: .normal)
        
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
            
            //set selected notification in picker
            if type == "30_days"{
                let reminderTime = self.settingData.thirtyDaysReminder ?? ""
                if reminderTime != ""{
                    let reminderTimeArray = reminderTime.components(separatedBy: ":")
                    self.hourBtn.setTitle("\(reminderTimeArray[0])", for: .normal)
                    self.minBtn.setTitle("\(reminderTimeArray[1])", for: .normal)
                    
                    if reminderTime.contains("PM") || reminderTime.contains("pm") || reminderTime.contains("AM") || reminderTime.contains("am"){
                        if reminderTime.contains("PM") || reminderTime.contains("pm"){
                            self.amPmBtn.setTitle("pm", for: .normal)
                        }else{
                            self.amPmBtn.setTitle("am", for: .normal)
                        }
                    }else{
                        switch Int(reminderTimeArray[0]) ?? 0{
                        case 12...23:
                            self.amPmBtn.setTitle("pm", for: .normal)
                        default:
                            self.amPmBtn.setTitle("am", for: .normal)
                        }
                    }
                }else{
                    let dateAsString = "\(self.hourBtn.titleLabel?.text ?? "4"):\(self.minBtn.titleLabel?.text ?? "00") \(self.amPmBtn.titleLabel?.text ?? "pm")"
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale.current
                    dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
                    
                    dateFormatter.dateFormat = "h:mm a"
                    let date = dateFormatter.date(from: dateAsString)!
                    
                    dateFormatter.dateFormat = "HH:mm"
                    let date1 = dateFormatter.string(from: date)
                    self.defaultDate = date1
                    //print("date1 \(date1) dateAsString \(dateAsString) defaultDate \(defaultDate)")
                }
            }else if type == "8_week"{
                let reminderTime = self.settingData.eightWeekReminder ?? ""
                if reminderTime != ""{
                    let reminderTimeArray = reminderTime.components(separatedBy: ":")
                    self.hourBtn.setTitle("\(reminderTimeArray[0])", for: .normal)
                    self.minBtn.setTitle("\(reminderTimeArray[1])", for: .normal)
                    
                    if reminderTime.contains("PM") || reminderTime.contains("pm") || reminderTime.contains("AM") || reminderTime.contains("am"){
                        if reminderTime.contains("PM") || reminderTime.contains("pm"){
                            self.amPmBtn.setTitle("pm", for: .normal)
                        }else{
                            self.amPmBtn.setTitle("am", for: .normal)
                        }
                    }else{
                        switch Int(reminderTimeArray[0]) ?? 0{
                        case 12...23:
                            self.amPmBtn.setTitle("pm", for: .normal)
                        default:
                            self.amPmBtn.setTitle("am", for: .normal)
                        }
                    }
                }else{
                    let dateAsString = "\(self.hourBtn.titleLabel?.text ?? "4"):\(self.minBtn.titleLabel?.text ?? "00") \(self.amPmBtn.titleLabel?.text ?? "pm")"
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale.current
                    dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
                    
                    dateFormatter.dateFormat = "h:mm a"
                    let date = dateFormatter.date(from: dateAsString)!
                    
                    dateFormatter.dateFormat = "HH:mm"
                    let date1 = dateFormatter.string(from: date)
                    self.defaultDate = date1
                }
            }
        }
        
        if type == "21_days"{
            self.lblSubTitle.text = "Set a notification for your 7 day sequence"
            self.dateToAddInCurrent()
        }else if type == "30_days"{
            self.lblSubTitle.text = "Set a notification for your 30 day sequence"
        }else{
            self.lblSubTitle.text = "Set a notification for your 8 week challenge"
        }
    }
    
    func dateToAddInCurrent(){
        
        let dateFormate = DateFormatter()
        dateFormate.locale = Locale.current
        dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
        dateFormate.dateFormat = "yyyy-MM-dd"
        
        let daysToAdd = 0
        let currentDate = getCurrentDate()
        
        var dateComponent = DateComponents()
        dateComponent.day = daysToAdd
        
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        let futureDate1 = dateFormate.string(from: futureDate ?? currentDate)
        let futureDate2 = dateFormate.date(from: futureDate1)
        //print("currentDate+++ \(currentDate) futureDate2+++ \(futureDate2 ?? currentDate)")
        self.appPreference.setReminder21DaysDate(value: futureDate2 ?? currentDate)
        
        //print("futureDate*** \(self.appPreffrence.getReminder21DaysDate())")
    }
    
    @IBAction func btnSetReminderClicked(_ sender: UIButton) {
        
        print(datePicker.date)
        self.callPushNotification()
        if self.type == "21_days"{
            self.appPreference.setIs21DaysReminder(value: true)
        }else if self.type == "30_days"{
            self.appPreference.set21ChallengeName(value: "30 Day Challenge")
            if flag == 0{
                settingData.thirtyDaysReminder = self.defaultDate
            }
            settingData.isThirtyDaysReminder = true
            self.callSettingAPI()
            return
        }else if self.type == "8_week"{
            self.appPreference.set21ChallengeName(value: "8 Weeks Challenge")
            if flag == 0{
                settingData.eightWeekReminder = self.defaultDate
            }
            settingData.isEightWeekReminder = true
            self.callSettingAPI()
            return
        }
        
        if isSetting{
            self.callHomeController(selectedIndex: 2)
        }else{
            self.callHomeController(selectedIndex: 4)
        }
    }
    
    @IBAction func btnSkipClicked(_ sender: UIButton){
        self.appPreference.setReminder21DaysTime(value: "")
        
        if self.type == "30_days"{
            self.appPreference.set21ChallengeName(value: "30 Day Challenge")
            if isSetting{
                self.callHomeVC1()
            }else{
                self.callHomeController(selectedIndex: 4)
            }
            return
        }else if self.type == "8_week"{
            self.appPreference.set21ChallengeName(value: "8 Weeks Challenge")
            if isSetting{
                self.callHomeVC1()
            }else{
                self.callHomeController(selectedIndex: 4)
            }
            return
        }
        
        if isSetting{
            self.callHomeController(selectedIndex: 2)
        }else{
            self.callHomeController(selectedIndex: 4)
        }
    }
    
    func callSettingAPI(){
        WWMHelperClass.saveDb()
        if self.appPreference.isLogin(){
            DispatchQueue.global(qos: .background).async {
                let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
                if data.count > 0 {
                    self.settingAPI()
                }
            }
        }
    }
    
    func callHomeController(selectedIndex: Int){
        self.navigationController?.isNavigationBarHidden = false
        
        if let tabController = self.tabBarController as? WWMTabBarVC {
            tabController.selectedIndex = selectedIndex
            for index in 0..<tabController.tabBar.items!.count {
                let item = tabController.tabBar.items![index]
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
                if index == selectedIndex {
                    item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
                }
            }
        }
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    // MARK:- UITextField Delegate Methods
    @IBAction func btnPickerViewAction(_ sender: UIButton){
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .time
        self.txtView.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        self.txtView.becomeFirstResponder()
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        dateFormatter.dateFormat = "HH:mm"
        
        //print(settingData.isThirtyDaysReminder)
        if self.type == "21_days"{
            settingData.twentyoneDaysReminder = dateFormatter.string(from: sender.date)
            self.appPreference.setReminder21DaysTime(value: dateFormatter.string(from: sender.date))
        }else if self.type == "30_days"{
            settingData.thirtyDaysReminder = dateFormatter.string(from: sender.date)
        }else if self.type == "8_week"{
            settingData.eightWeekReminder = dateFormatter.string(from: sender.date)
        }
        
        dateFormatter.dateFormat = "HH:mm a"
        
        let date1 = dateFormatter.string(from: sender.date)
        let components = Calendar.current.dateComponents([.hour, .minute], from:  sender.date)
        let hour = components.hour!
        let minute = components.minute!
        
        if !date1.contains("PM") || !date1.contains("pm") || !date1.contains("AM") || !date1.contains("am"){
            switch hour {
            case 12...23:
                self.amPmBtn.setTitle("pm", for: .normal)
            default:
                self.amPmBtn.setTitle("am", for: .normal)
            }
        }else{
            if date1.contains("PM") || date1.contains("pm"){
                self.amPmBtn.setTitle("pm", for: .normal)
            }else{
                self.amPmBtn.setTitle("am", for: .normal)
            }
        }
        
        self.hourBtn.setTitle("\(hour)", for: .normal)
        self.minBtn.setTitle("\(minute)", for: .normal)
        
        flag = 1
    }
    
    func callPushNotification() {
        AppDelegate.sharedDelegate().setLocalPush()
    }
    
    func showDatePicker(){
        
        datePicker.datePickerMode = .time
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: KDONE, style: .plain, target: self, action: #selector(donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: KCANCEL, style: .plain, target: self, action: #selector(donedatePicker))
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        txtView.inputAccessoryView = toolbar
        txtView.inputView = datePicker
    }
    
    @objc func donedatePicker(){
        dateFormatter.dateFormat = "HH:mm a"
        //print("datePicker.date.... \(dateFormatter.string(from: datePicker.date))")
        
        let date1 = dateFormatter.string(from: datePicker.date)
        let components = Calendar.current.dateComponents([.hour, .minute], from:  datePicker.date)
        let hour = components.hour ?? 04
        let minute = components.minute ?? 00
        
        if date1.contains("PM") || date1.contains("pm"){
            self.amPmBtn.setTitle("pm", for: .normal)
        }else{
            self.amPmBtn.setTitle("am", for: .normal)
        }
        
        self.hourBtn.setTitle("\(hour)", for: .normal)
        self.minBtn.setTitle("\(minute)", for: .normal)
        
        dateFormatter.dateFormat = "HH:mm"
        self.finalTime = dateFormatter.string(from: datePicker.date)
        
        self.view.endEditing(true)
    }
    
    func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    func getCurrentDate()-> Date {
        var now = Date()
        var nowComponents = DateComponents()
        let calendar = Calendar.current
        nowComponents.year = Calendar.current.component(.year, from: now)
        nowComponents.month = Calendar.current.component(.month, from: now)
        nowComponents.day = Calendar.current.component(.day, from: now)
        nowComponents.hour = Calendar.current.component(.hour, from: now)
        nowComponents.minute = Calendar.current.component(.minute, from: now)
        nowComponents.second = Calendar.current.component(.second, from: now)
        nowComponents.timeZone = NSTimeZone.local
        now = calendar.date(from: nowComponents)!
        return now as Date
    }
}

extension WWM21DaySetReminder1VC{
    // MARK:- API Calling
    func settingAPI() {
        
        var meditation_data = [[String:Any]]()
        let meditationData = self.settingData.meditationData?.array as? [DBMeditationData]
        
        if meditationData?.count ?? 0 > 0{
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
                        "name": level.levelName ?? "",
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
                    //print("++++++ \(self.min_limit) \(self.max_limit)")
                    
                    let data = ["meditation_id":dic.meditationId,
                                "meditation_name":dic.meditationName ?? "",
                                "isSelected":dic.isMeditationSelected,
                                "min_limit" : self.min_limit,
                                "max_limit" : self.max_limit,
                                "setmyown" : dic.setmyown,
                                "levels":levelDic] as [String : Any]
                    meditation_data.append(data)
                }else{
                    //print("++++++ \(String(describing: dic.min_limit)) +++++ \(dic.max_limit)")
                    
                    let data = ["meditation_id":dic.meditationId,
                                "meditation_name":dic.meditationName ?? "",
                                "isSelected":dic.isMeditationSelected,
                                "min_limit" : dic.min_limit ?? "94",
                                "max_limit" : dic.max_limit ?? "97",
                                "setmyown" : dic.setmyown,
                                "levels":levelDic] as [String : Any]
                    meditation_data.append(data)
                }
            }
            
            //"IsMilestoneAndRewards"
            
            if self.settingData.startChime == "JAY GURU DEVA"{
                self.settingData.startChime = "JAI GURU DEVA"
            }
            
            if self.settingData.endChime == "JAY GURU DEVA"{
                self.settingData.endChime = "JAI GURU DEVA"
            }
            
            if self.settingData.finishChime == "JAY GURU DEVA"{
                self.settingData.finishChime = "JAI GURU DEVA"
            }
            
            if self.settingData.ambientChime == "JAY GURU DEVA"{
                self.settingData.ambientChime = "JAI GURU DEVA"
            }
            
            if self.settingData.intervalChime == "JAY GURU DEVA"{
                self.settingData.intervalChime = "JAI GURU DEVA"
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
                "MantraID":self.settingData.mantraID,
                "LearnReminderTime":self.settingData.learnReminderTime!,
                "IsLearnReminder":self.settingData.isLearnReminder,
                "isThirtyDaysReminder":self.settingData.isThirtyDaysReminder,
                "thirtyDaysReminder":self.settingData.thirtyDaysReminder ?? "",
                "isTwentyoneDaysReminder":self.settingData.isTwentyoneDaysReminder,
                "twentyoneDaysReminder":self.settingData.twentyoneDaysReminder ?? "",
                "isEightWeekReminder":self.settingData.isEightWeekReminder,
                "eightWeekReminder":self.settingData.eightWeekReminder ?? "",
                "meditation_data" : meditation_data
                ] as [String : Any]
            
            let param = [
                "user_id": self.appPreference.getUserID(),
                "isJson": true,
                "group": group
                ] as [String : Any]
            
            print("settings param... \(param)")
            
            WWMWebServices.requestAPIWithBody(param:param, urlString: URL_SETTINGS, context: "WWMSettingsVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
                
                DispatchQueue.main.async {
                    if self.isSetting{
                        self.callHomeVC1()
                    }else{
                        self.callHomeController(selectedIndex: 4)
                    }
                }
            }
        }
    }
}
