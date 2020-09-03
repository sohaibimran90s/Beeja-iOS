//
//  WWMSupportVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 14/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class WWMSupportVC: WWMBaseViewController {

    @IBOutlet weak var txtViewName: UITextField!
    @IBOutlet weak var txtViewEmail: UITextField!
    @IBOutlet weak var txtViewQuery: UITextView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnLogs: UIButton!
    //var alertPopupView = WWMAlertController()
    var alertLogsView = LoggerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Done"
        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        
        self.txtViewQuery.delegate = self
        self.setNavigationBar(isShow: false, title: "")
        self.btnSubmit.layer.borderWidth = 2.0
        self.btnSubmit.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.btnLogs.layer.borderWidth = 2.0
        self.btnLogs.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        if self.userData.name == "You"{
            self.txtViewName.text = ""
        }else{
            self.txtViewName.text = self.userData.name
        }
        
        self.txtViewEmail.text = self.userData.email
        
        hideShowLogBtn()
    }
    // MARK: Button Action
    
    @IBAction func btnEditTextAction(_ sender: Any) {
        self.txtViewQuery.isEditable = true
        self.txtViewQuery.becomeFirstResponder()
    }
    
    @IBAction func btnSubmitAction(_ sender: UIButton) {
        
        if txtViewName.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_EmailName, title: kAlertTitle)
        }else if txtViewName.text == "You" || txtViewName.text == "you"{
            WWMHelperClass.showPopupAlertController(sender: self, message: KVALIDATIONNAME, title: kAlertTitle)
        }else if txtViewEmail.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_EmailName, title: kAlertTitle)
        }else if !(self.isValidEmail(strEmail: txtViewEmail.text!)){
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_invalidEmailMessage, title: kAlertTitle)
        }else if txtViewQuery.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_QueryMessage, title: kAlertTitle)
        }else{
            self.submitQueryAPI()
        }
    }
    
    func submitQueryAPI() {
        WWMHelperClass.showLoaderAnimate(on: self.view)
        
        
        //Prashant
        //=====================================================================
        
        /*
         Platform - [iOS/Android]OS
         Version - [Version No]
         Beeja App Version - [App version No]
         Subscription status - [Free/Premium]
         Premium Subscription - [NA/Monthly/Annually/Lifetime]
         */
        
        let platform = "iOS"
        let version = UIDevice.current.systemVersion
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let subscriptionStatus = UserDefaults.standard.string(forKey: "UserSubscription") ?? ""
        let subscriptionPlan = UserDefaults.standard.string(forKey: "subscription_plan") ?? ""
        
        let queryBody = "\(txtViewQuery.text!)\n\n\nPlatform - \(platform)\nVersion - \(version)\nBeeja App Version - \(appVersion!)\nSubscription status - \(subscriptionStatus)\nPremium Subscription - \(subscriptionPlan)"
        
        let param = [
                      "user_id" : self.appPreference.getUserID(),
                      "name" : txtViewName.text!,
                      "email" : txtViewEmail.text!,
                      "body" : queryBody
            ] as [String : Any]
        
        //=====================================================================
        
        
        WWMWebServices.requestAPIWithBody(param: param as [String : Any], urlString: URL_SUPPORT, context: "WWMSupportVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                //self.navigationController?.popViewController(animated: true)
                //WWMHelperClass.showPopupAlertController(sender: self, message:result["message"] as! String , title: kAlertTitle)
                
                self.xibCall()
            }else {
                self.saveToDB(param: param)
            }
            //WWMHelperClass.dismissSVHud()
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    func xibCall(){
        alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView.btnOK.layer.borderWidth = 2.0
        alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        alertPopupView.lblTitle.text = ""
        alertPopupView.lblSubtitle.text = KSUPPORTMSG
        alertPopupView.btnClose.isHidden = true
        
        alertPopupView.btnOK.addTarget(self, action: #selector(btnDoneAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertPopupView)
    }
    
    
    func saveToDB(param:[String:Any]) {
        let dbContact = WWMHelperClass.fetchEntity(dbName: "DBContactUs") as! DBContactUs
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: param, options:.prettyPrinted)
        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        dbContact.data = myString
        WWMHelperClass.saveDb()
        self.xibCall()
    }
    
    
    @IBAction func btnDoneAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.alertPopupView.removeFromSuperview()
    }
}

extension WWMSupportVC: UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (txtViewQuery.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 1501
    }
}

extension WWMSupportVC{
    //MARK: Logs
    @IBAction func btnLogsAction(_ sender: UIButton) {
        xibLogs()
    }
    
    func hideShowLogBtn(){
        #if DEBUG
        self.btnLogs.isHidden = false
        #else
        self.btnLogs.isHidden = true
        #endif
    }
    
    func xibLogs(){
        alertLogsView = UINib(nibName: "LoggerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! LoggerView
        let window = UIApplication.shared.keyWindow!
        alertLogsView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        
        alertLogsView.btnSendLogs.layer.borderWidth = 2.0
        alertLogsView.btnSendLogs.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        alertLogsView.btnSendLogs.layer.cornerRadius = 20
        
        alertLogsView.btnDeleteLogs.layer.borderWidth = 2.0
        alertLogsView.btnDeleteLogs.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        alertLogsView.btnDeleteLogs.layer.cornerRadius = 20
        
        if Logger.logger.getIsLogging(){
            alertLogsView.btnSwitch.isOn = true
            Logger.logger.setUpLogger()
        }else{
            alertLogsView.btnSwitch.isOn = false
        }
        
        alertLogsView.btnSendLogs.addTarget(self, action: #selector(btnSendLogsAction(_:)), for: .touchUpInside)
        
        alertLogsView.btnDeleteLogs.addTarget(self, action: #selector(btnDeleteLogsAction(_:)), for: .touchUpInside)
        alertLogsView.btnSwitch.addTarget(self, action: #selector(btnSwitchAction), for: UIControl.Event.valueChanged)
        
        window.rootViewController?.view.addSubview(alertLogsView)
    }
    
    @objc func btnSwitchAction(mySwitch: UISwitch) {
        if mySwitch.isOn {
            Logger.logger.setIsLogging(value: true)
            Logger.logger.setUpLogger()
            print("UISwitch is ON")
        } else {
            Logger.logger.setIsLogging(value: false)
            print("UISwitch is OFF")
        }
    }
    
    @IBAction func btnSendLogsAction(_ sender: Any) {
        Logger.logger.sendLogs()
    }
    
    @IBAction func btnDeleteLogsAction(_ sender: Any) {
        Logger.logger.deleteLogFile()
    }
}
