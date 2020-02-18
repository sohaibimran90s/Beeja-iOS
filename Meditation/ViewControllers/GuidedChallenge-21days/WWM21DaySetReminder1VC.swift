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
    
    @IBAction func btnSetReminderClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
        
        if date1.contains("PM") || date1.contains("pm"){
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
}
