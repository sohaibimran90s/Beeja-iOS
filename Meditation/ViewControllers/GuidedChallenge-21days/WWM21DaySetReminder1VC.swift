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
            
            //set selected notification in picker
            if type == "30_days"{
                let reminderTime = self.settingData.thirtyDaysReminder ?? ""
                if reminderTime != ""{
                    let reminderTimeArray = reminderTime.components(separatedBy: ":")
                    self.hourBtn.setTitle("\(reminderTimeArray[0])", for: .normal)
                    self.minBtn.setTitle("\(reminderTimeArray[1])", for: .normal)
                    
                    if !reminderTime.contains("PM") || !reminderTime.contains("pm") || !reminderTime.contains("AM") || !reminderTime.contains("am"){
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
                    print("date1 \(date1) dateAsString \(dateAsString) defaultDate \(defaultDate)")
                }
            }
        }
        
        if type == "21_days"{
            self.lblSubTitle.text = "Set a notification for your 7 day sequence"
            self.dateToAddInCurrent()
        }else{
            self.lblSubTitle.text = "Set a notification for your 30 day sequence"
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
        if self.type == "21_days"{
            self.appPreference.setIs21DaysReminder(value: true)
        }else if self.type == "30_days"{
            if flag == 0{
                settingData.thirtyDaysReminder = self.defaultDate
            }
            self.appPreference.setIs30DaysReminder(value: true)
        }
        
        self.callPushNotification()
        if isSetting{
            self.callHomeController(selectedIndex: 2)
        }else{
            self.callHomeController(selectedIndex: 4)
        }
    }
    
    @IBAction func btnSkipClicked(_ sender: UIButton){
        self.appPreference.setReminder21DaysTime(value: "")
        
        if isSetting{
            self.callHomeController(selectedIndex: 2)
        }else{
            self.callHomeController(selectedIndex: 4)
        }
    }
    
    func callHomeController(selectedIndex: Int){
        self.navigationController?.isNavigationBarHidden = false
        
        if let tabController = self.tabBarController as? WWMTabBarVC {
            tabController.selectedIndex = 4
            for index in 0..<tabController.tabBar.items!.count {
                let item = tabController.tabBar.items![index]
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
                if index == 4 {
                    item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
                }
            }
        }
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    // MARK:- UITextField Delegate Methods
    
    func textFieldDidEndEditing(_ textField: UITextField) {
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
        
        //print(settingData.isThirtyDaysReminder)
        if self.type == "21_days"{
            settingData.twentyoneDaysReminder = dateFormatter.string(from: sender.date)
            self.appPreference.setReminder21DaysTime(value: dateFormatter.string(from: sender.date))
        }else if self.type == "30_days"{
            settingData.thirtyDaysReminder = dateFormatter.string(from: sender.date)
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
