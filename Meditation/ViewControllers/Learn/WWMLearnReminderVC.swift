//
//  WWMLearnReminderVC.swift
//  Meditation
//
//  Created by Prema Negi on 16/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMLearnReminderVC: WWMBaseViewController {

    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var btnPickerView: UIButton!
    @IBOutlet weak var hourBtn: UIButton!
    @IBOutlet weak var minBtn: UIButton!
    @IBOutlet weak var amPmBtn: UIButton!
    @IBOutlet weak var btnTomm: UIButton!
    @IBOutlet weak var btnEveryday: UIButton!
    
    let dateFormatter = DateFormatter()
    let datePicker = UIDatePicker()
    var date = Date()
    var finalTime: String = ""
    
    var settingData = DBSettings()
    var flag = 0
    
    var min_limit = ""
    var max_limit = ""

    override func viewDidLoad() {
        super.viewDidLoad()

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
        }
    }
    
    @IBAction func btnTommClicked(_ sender: UIButton) {
        self.btnTomm.setBackgroundImage(UIImage(named: "onRadio"), for: .normal)
        self.btnEveryday.setBackgroundImage(UIImage(named: "offRadio"), for: .normal)
        
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = Locale.current
        dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
        
        dateFormatter.dateFormat = "dd:MM:yyyy HH:mm"
        let tommDate = Calendar.current.date(byAdding: .day, value: 1, to: date)
        AppDelegate.sharedDelegate().date = tommDate!
        AppDelegate.sharedDelegate().value = 1
        print("tommDate... \(tommDate!)")
        
    }
    
    @IBAction func btnEverydayClicked(_ sender: UIButton) {
        self.btnTomm.setBackgroundImage(UIImage(named: "offRadio"), for: .normal)
        self.btnEveryday.setBackgroundImage(UIImage(named: "onRadio"), for: .normal)
        
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = Locale.current
        dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
        
        dateFormatter.dateFormat = "dd:MM:yyyy HH:mm"
        let afterThirtyDate = Calendar.current.date(byAdding: .day, value: 30, to: date)
        AppDelegate.sharedDelegate().date = afterThirtyDate!
        AppDelegate.sharedDelegate().value = 2
        print("afterThirtyDate... \(afterThirtyDate!)")
        flag = 1
    }
    
    
    @IBAction func btnSetReminderClicked(_ sender: UIButton) {
        if flag == 0{
//            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.locale = Locale.current
            dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
            
            dateFormatter.dateFormat = "dd:MM:yyyy HH:mm"
            let tommDate = Calendar.current.date(byAdding: .day, value: 1, to: date)
            AppDelegate.sharedDelegate().date = tommDate!
            AppDelegate.sharedDelegate().value = 1
            print("tommDate... \(tommDate!)")
        }
        
        callPushNotification()
        
        self.navigationController?.popViewController(animated: true)
        
       if self.appPreference.isLogin(){
            DispatchQueue.global(qos: .background).async {
                let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
                       if data.count > 0 {
                           self.settingAPI()
                }
            }
        }
    }
    
    @IBAction func btnSkipClicked(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK:- UITextField Delegate Methods
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    func callPushNotification() {
        AppDelegate.sharedDelegate().setLocalPush()
    }
    
    @IBAction func btnPickerViewAction(_ sender: UIButton){
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .time
        self.txtView.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        self.txtView.becomeFirstResponder()
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        dateFormatter.dateFormat = "HH:mm"
        settingData.learnReminderTime = dateFormatter.string(from: sender.date)
        
        dateFormatter.dateFormat = "HH:mm a"
        print("datePicker.date.... \(dateFormatter.string(from: sender.date))")
        
        let date1 = dateFormatter.string(from: sender.date)
        let components = Calendar.current.dateComponents([.hour, .minute], from:  sender.date)
        let hour = components.hour!
        let minute = components.minute!
        
        if date1.contains("PM"){
            self.amPmBtn.setTitle("pm", for: .normal)
        }else{
            self.amPmBtn.setTitle("am", for: .normal)
        }
        
        self.hourBtn.setTitle("\(hour)", for: .normal)
        self.minBtn.setTitle("\(minute)", for: .normal)
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
        print("datePicker.date.... \(dateFormatter.string(from: datePicker.date))")
        
        let date1 = dateFormatter.string(from: datePicker.date)
        let components = Calendar.current.dateComponents([.hour, .minute], from:  datePicker.date)
        let hour = components.hour!
        let minute = components.minute!
        
        if date1.contains("pm"){
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
        //"IsMilestoneAndRewards"
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
            "meditation_data" : meditation_data
            ] as [String : Any]
        
        let param = [
            "user_id": self.appPreference.getUserID(),
            "isJson": true,
            "group": group
            ] as [String : Any]
        
        WWMWebServices.requestAPIWithBody(param:param, urlString: URL_SETTINGS, context: "WWMLearnReminderVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let success = result["success"] as? Bool {
                    print(success)
                    print("WWMLearnReminderVC")
                }
            }
        }
    }
}
