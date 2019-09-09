//
//  WWMSignupEmailVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 10/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Crashlytics

class WWMSignupEmailVC: WWMBaseViewController,UITextFieldDelegate {

    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var txtViewEmail: UITextField!
    
    var name = ""
    var isFromFb = Bool()
    var fbData = [String:Any]()
    var tap = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Next"
        self.setupView()
    }
    
    func setupView(){
        self.setNavigationBar(isShow: false, title: "")
        
        self.btnNext.layer.borderWidth = 2.0
        self.btnNext.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
    }
    
    @objc func KeyPadTap() -> Void {
        self.view.endEditing(true)
    }
    
    //MARK:- UITextField Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tap = UITapGestureRecognizer(target: self, action: #selector(self.KeyPadTap))
        view.addGestureRecognizer(tap)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view .removeGestureRecognizer(tap)
        if !(self.isValidEmail(strEmail: txtViewEmail.text!)){
            self.viewEmail.layer.borderColor = UIColor.clear.cgColor
            self.btnNext.setTitleColor(UIColor.white, for: .normal)
            self.btnNext.backgroundColor = UIColor.clear
        }
        
        if txtViewEmail.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message:Validation_EmailMessage , title: kAlertTitle)
        }else if !(self.isValidEmail(strEmail: txtViewEmail.text!)){
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_invalidEmailMessage, title: kAlertTitle)
        }else {
            if isFromFb {
                self.loginWithSocial()
            }else {
                self.signUpApi()
            }
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = txtViewEmail.text! + string
        
        if (self.isValidEmail(strEmail: str)) {
                self.viewEmail.layer.borderWidth = 1.0
                self.viewEmail.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
                self.btnNext.setTitleColor(UIColor.black, for: .normal)
                self.btnNext.backgroundColor = UIColor.init(hexString: "#00eba9")!
        }
        return true
    }
    
    // MARK: - UIButton Action
    
    @IBAction func btnNextAction(_ sender: UIButton) {
        if txtViewEmail.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message:Validation_EmailMessage , title: kAlertTitle)
        }else if !(self.isValidEmail(strEmail: txtViewEmail.text!)){
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_invalidEmailMessage, title: kAlertTitle)
        }else {
            if isFromFb {
                self.loginWithSocial()
            }else {
                self.signUpApi()
            }
        }
    }
    
    func signUpApi() {
        self.view.endEditing(true)
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
            "email": txtViewEmail.text!,
            "deviceToken" : appPreference.getDeviceToken(),
            "deviceId": kDeviceID,
            "DeviceType": kDeviceType,
            "loginType": kLoginTypeEmail,
            "name":self.name,
            "model": UIDevice.current.model,
            "version": UIDevice.current.systemVersion
        ]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_SIGNUP, context: "WWMSignupEmailVC", headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                
                print("signup result... \(result)")
                if let userProfile = result["userprofile"] as? [String:Any] {
                    self.appPreference.setUserToken(value: userProfile["token"] as? String ?? "")
                    self.appPreference.setUserID(value: "\(userProfile["user_id"] as? Int ?? 0)")
                    Crashlytics.sharedInstance().setUserIdentifier("userId \(userProfile["user_id"] as? Int ?? 0)")
                    
                    self.appPreference.setUserName(value: userProfile["name"] as? String ?? "")
                    self.appPreference.setIsLogin(value: true)
                    self.appPreference.setIsProfileCompleted(value: false)
                    self.appPreference.setType(value: userProfile["type"] as? String ?? "")
                    self.appPreference.setGuideType(value: userProfile["guided_type"] as? String ?? "")
                    self.appPreference.setHomePageURL(value: userProfile["home_page_url"] as! String)
                    self.appPreference.setLearnPageURL(value: userProfile["learn_page_url"] as! String)
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC
                    
                    vc.value = "SignupLetsStart"
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    WWMHelperClass.showPopupAlertController(sender: self, message:  result["message"] as? String ?? "Unauthorized request", title: kAlertTitle)
                }
                
                
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
    
    func loginWithSocial() {
        self.view.endEditing(true)
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        
        
        let param = [
            "email": txtViewEmail.text ?? "",
            "password":"",
            "deviceId": kDeviceID,
            "deviceToken" : appPreference.getDeviceToken(),
            "DeviceType": kDeviceType,
            "loginType": kLoginTypeFacebook,
            "profile_image":"http://graph.facebook.com/\(fbData["id"] ?? "")/picture?type=large",
            "socialId":"\(fbData["id"] ?? -1)",
            "name":"\(fbData["name"] ?? "")",
            "model": UIDevice.current.model,
            "version": UIDevice.current.systemVersion
            ] as [String : Any]
        
        print("param2... \(param)")
        WWMWebServices.requestAPIWithBody(param:param , urlString: URL_LOGIN, context: "WWMSignupEmailVC", headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                
                if let userProfile = result["userprofile"] as? [String:Any] {
                    if let isProfileCompleted = userProfile["IsProfileCompleted"] as? Bool {
                        self.appPreference.setIsLogin(value: true)
                        self.appPreference.setUserID(value:"\(userProfile["user_id"] as? Int ?? 0)")
                        Crashlytics.sharedInstance().setUserIdentifier("userId \(userProfile["user_id"] as? Int ?? 0)")
                        
                        self.appPreference.setUserToken(value: userProfile["token"] as? String ?? "")
                        self.appPreference.setUserName(value: userProfile["name"] as? String ?? "")
                        self.appPreference.setIsProfileCompleted(value: isProfileCompleted)
                        self.appPreference.setType(value: userProfile["type"] as? String ?? "")
                        self.appPreference.setGuideType(value: userProfile["guided_type"] as? String ?? "")
                        self.appPreference.setUserData(value: [:])
                        
                        print("self.appPreference.getUserName() ...... \(self.appPreference.getUserName())")
                        
                        self.appPreference.setHomePageURL(value: userProfile["home_page_url"] as! String)
                        self.appPreference.setLearnPageURL(value: userProfile["learn_page_url"] as! String)
                                                
                        if isProfileCompleted {
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                            UIApplication.shared.keyWindow?.rootViewController = vc
                        }else {
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC
                            
                            vc.value = "SignupLetsStart"
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
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
