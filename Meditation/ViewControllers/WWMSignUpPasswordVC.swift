//
//  WWMSignUpPasswordVCViewController.swift
//  Meditation
//
//  Created by Prema Negi on 12/10/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Crashlytics

class WWMSignUpPasswordVC: WWMBaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtViewPassword: UITextField!
    @IBOutlet weak var txtViewRetypePassword: UITextField!
    @IBOutlet weak var btnNext: UIButton!
    
    var email: String = ""
    var name: String = ""
    
    var tap = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Done"
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
        self.view.removeGestureRecognizer(tap)
    }
        
    @IBAction func btnNextAction(_ sender: UIButton) {
        if txtViewPassword.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: KENTERPASS, title: kAlertTitle)
        }else if txtViewRetypePassword.text == "" {
             WWMHelperClass.showPopupAlertController(sender: self, message: KRETYPECONFIRMPASS, title: kAlertTitle)
        }else if txtViewPassword.text != txtViewRetypePassword.text{
            WWMHelperClass.showPopupAlertController(sender: self, message: KPASSNOTMATCH, title: kAlertTitle)
        }else{
            self.signUpApi()
        }
    }
    
    func signUpApi() {
        // Analytics
        WWMHelperClass.sendEventAnalytics(contentType: "SIGN_UP", itemId: "WHATS_YOUR_PASSWORD", itemName: "")
        print("email... \(email) name... \(self.name) password... \(self.txtViewPassword.text!) retype password... \(self.txtViewRetypePassword.text!)")
        
        
        self.view.endEditing(true)
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
            "email": email,
            "deviceToken" : appPreference.getDeviceToken(),
            "deviceId": kDeviceID,
            "DeviceType": kDeviceType,
            "loginType": kLoginTypeEmail,
            "name":self.name,
            "model": UIDevice.current.model,
            "version": UIDevice.current.systemVersion,
            "password": self.txtViewPassword.text!
        ]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_SIGNUP, context: "WWMSignupEmailVC", headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                
                print("signup result... \(result)")
                if let userProfile = result["userprofile"] as? [String:Any] {
                    self.appPreference.setUserToken(value: userProfile["token"] as? String ?? "")
                    self.appPreference.setUserID(value: "\(userProfile["user_id"] as? Int ?? 0)")
                    Crashlytics.sharedInstance().setUserIdentifier("userId \(userProfile["user_id"] as? Int ?? 0)")
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "logoutSuccessful"), object: nil)
                    
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
    
    @IBAction func btnDoneAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC
        
        vc.value = "SignupLetsStart"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
