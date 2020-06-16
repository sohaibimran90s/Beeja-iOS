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

    let dateFormatter = DateFormatter()
    let datePicker = UIDatePicker()
    var date = Date()
    
    var finalTime: String = ""
    
    var settingData = DBSettings()
    var flag = 0
    
    let appPreffrence = WWMAppPreference()

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
        
        self.dateToAddInCurrent()
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
        self.appPreffrence.setReminder21DaysDate(value: futureDate2 ?? currentDate)

        //print("futureDate*** \(self.appPreffrence.getReminder21DaysDate())")
    }
    
    @IBAction func btnSetReminderClicked(_ sender: UIButton) {
         self.callPushNotification()
         self.callHomeController()
    }
    
    @IBAction func btnSkipClicked(_ sender: UIButton){
        self.appPreffrence.setReminder21DaysTime(value: "")
        self.callHomeController()
    }
    
    func callHomeController(){
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
        self.appPreffrence.setReminder21DaysTime(value: dateFormatter.string(from: sender.date))
        
        dateFormatter.dateFormat = "HH:mm a"
        //print("datePicker.date.... \(dateFormatter.string(from: sender.date)) getReminder21DaysTime+++ \(self.appPreffrence.getReminder21DaysTime())")
        
        let date1 = dateFormatter.string(from: sender.date)
        let components = Calendar.current.dateComponents([.hour, .minute], from:  sender.date)
        let hour = components.hour!
        let minute = components.minute!
        
        if date1.contains("PM") || date1.contains("pm"){
            self.amPmBtn.setTitle("pm", for: .normal)
        }else{
            self.amPmBtn.setTitle("am", for: .normal)
        }
        
        self.hourBtn.setTitle("\(hour)", for: .normal)
        self.minBtn.setTitle("\(minute)", for: .normal)
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
