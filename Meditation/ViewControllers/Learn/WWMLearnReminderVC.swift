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
    
    @IBOutlet weak var hourBtn: UIButton!
    @IBOutlet weak var minBtn: UIButton!
    @IBOutlet weak var amPmBtn: UIButton!
    
    let datePicker = UIDatePicker()
    var finalTime: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBar(isShow: false, title: "")
        self.setupView()
        
        txtView.tintColor = UIColor.clear
        self.showDatePicker()
    }

    func setupView(){
        let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let attributeString = NSMutableAttributedString(string: "Skip",
                                                        attributes: attributes)
        btnSkip.setAttributedTitle(attributeString, for: .normal)
        
    }
    
    @IBAction func btnSetReminderClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnDiscountVC") as! WWMLearnDiscountVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnSkipClicked(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func showDatePicker(){

        datePicker.datePickerMode = .time
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(donedatePicker))
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        txtView.inputAccessoryView = toolbar
        txtView.inputView = datePicker
    }
    
    @objc func donedatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm a"
        print("datePicker.date.... \(formatter.string(from: datePicker.date))")
        
        let date1 = formatter.string(from: datePicker.date)
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
        
        formatter.dateFormat = "HH:mm"
        self.finalTime = formatter.string(from: datePicker.date)
        
        self.view.endEditing(true)
    }
    
    func cancelDatePicker(){
        self.view.endEditing(true)
    }
}
