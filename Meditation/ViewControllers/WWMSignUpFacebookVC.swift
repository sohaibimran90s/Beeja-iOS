//
//  WWMSignUpPasswordVCViewController.swift
//  Meditation
//
//  Created by Prema Negi on 12/10/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import FirebaseCrashlytics

class WWMSignUpFacebookVC: WWMBaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var txtViewEmail: UITextField!
    @IBOutlet weak var btnBackTopConstraint: NSLayoutConstraint!
    
    var fbData = [String:Any]()
    var tap = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if WWMHelperClass.hasTopNotch{
            self.btnBackTopConstraint.constant = 30
        }else{
            self.btnBackTopConstraint.constant = 10
        }
        
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
            // Analytics
            WWMHelperClass.sendEventAnalytics(contentType: "SIGN_UP", itemId: "WHATS_YOUR_EMAIL", itemName: "")
            
            self.loginWithSocial()
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
            // Analytics
            WWMHelperClass.sendEventAnalytics(contentType: "SIGN_UP", itemId: "WHATS_YOUR_EMAIL", itemName: "")

            self.loginWithSocial()
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
        
        //print("param2... \(param)")
        WWMWebServices.requestAPIWithBody(param:param , urlString: URL_LOGIN, context: "WWMSignupEmailVC", headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                
                if let userProfile = result["userprofile"] as? [String:Any] {
                    
                    //print("userProfile WWMSignupEmailVC... \(userProfile)")
                    
                    DispatchQueue.global(qos: .background).async {
                        self.getInviteAcceptAPI(context1: "WWMLoginVC")
                    }
                    
                    if let isProfileCompleted = userProfile["IsProfileCompleted"] as? Bool {
                        Logger.logger.setIsLogging(value: true)
                        self.appPreference.setIsLogin(value: true)
                        self.appPreference.setUserID(value:"\(userProfile["user_id"] as? Int ?? 0)")
                        Crashlytics.crashlytics().setUserID("userId \(userProfile["user_id"] as? Int ?? 0)")
                        
                        self.appPreference.setEmail(value: userProfile["email"] as? String ?? "")
                        self.appPreference.setUserToken(value: userProfile["token"] as? String ?? "")
                        self.appPreference.setUserName(value: userProfile["name"] as? String ?? "")
                        self.appPreference.setIsProfileCompleted(value: isProfileCompleted)
                        self.appPreference.setType(value: userProfile["type"] as? String ?? "")
                        self.appPreference.setGuideType(value: userProfile["guided_type"] as? String ?? "")
                        self.appPreference.setGuideTypeFor3DTouch(value: userProfile["guided_type"] as? String ?? "")
                        self.appPreference.setUserData(value: [:])
                        
                        //print("self.appPreference.getUserName() ...... \(self.appPreference.getUserName())")
                        
                        self.appPreference.setHomePageURL(value: userProfile["home_page_url"] as! String)
                        self.appPreference.setLearnPageURL(value: userProfile["learn_page_url"] as! String)
                        
                        if isProfileCompleted {
                            
                            self.appPreference.setGetProfile(value: true)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                            UIApplication.shared.keyWindow?.rootViewController = vc
                            
                        }else {
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMConOnboardingVC") as! WWMConOnboardingVC
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
