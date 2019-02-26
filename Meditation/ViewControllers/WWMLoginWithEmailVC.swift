//
//  WWMLoginWithEmailVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 07/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMLoginWithEmailVC:WWMBaseViewController {
    
    @IBOutlet weak var txtViewPassword: UITextField!
    @IBOutlet weak var txtViewEmail: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnForgotPassword: UIButton!
    
    @IBOutlet weak var viewContinueAsEmail: UIView!
    @IBOutlet weak var viewEmail: UIView!
    
    
    var isFromWelcomeBack = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        
        if isFromWelcomeBack {
            viewContinueAsEmail.isHidden = false
            viewEmail.isHidden = true
        }else {
            viewContinueAsEmail.isHidden = true
            viewEmail.isHidden = false
        }
        
        self.setNavigationBar(isShow: false, title: "")
        self.btnLogin.layer.borderWidth = 2.0
        self.btnLogin.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
    }
    // MARK: Button Action
    
    @IBAction func btnLoginAction(_ sender: UIButton) {
        if !isFromWelcomeBack {
            if txtViewEmail.text == "" {
                WWMHelperClass.showPopupAlertController(sender: self, message: Validation_EmailMessage, title: kAlertTitle)
                return
            }else if !(self.isValidEmail(strEmail: txtViewEmail.text!)){
                WWMHelperClass.showPopupAlertController(sender: self, message: Validation_invalidEmailMessage, title: kAlertTitle)
                return
            }
        }
        if self.txtViewPassword.text == "" {
                WWMHelperClass.showPopupAlertController(sender: self, message: Validation_passwordMessage, title: kAlertTitle)
        }else {
                self.loginWithEmail()
        }
        
        
    }
    
    @IBAction func btnForgotPasswordAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMForgotPasswordVC") as! WWMForgotPasswordVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func loginWithEmail() {
        let param = [
            "email": isFromWelcomeBack ? txtViewEmail.text!: self.userData.email,
            "password":txtViewPassword.text!,
            "deviceId": UIDevice.current.identifierForVendor!.uuidString,
            "deviceToken" : appPreference.getDeviceToken(),
            "DeviceType": "ios",
            "loginType": "eml",
            "profileImage":"",
            "socialId":"gmail",
            "name":""
        ]
        WWMWebServices.requestAPIWithBody(param:param , urlString: URL_LOGIN, headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                self.appPreference.setIsLogin(value: true)
                self.appPreference.setUserID(value:result["user_id"] as! String)
                if let isProfileCompleted = result["IsProfileCompleted"] as? Bool {
                    self.appPreference.setIsProfileCompleted(value: isProfileCompleted)
                    if isProfileCompleted {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                        UIApplication.shared.keyWindow?.rootViewController = vc
                    }else {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
                        UIApplication.shared.keyWindow?.rootViewController = vc
                    }
                }
                
            }else {
                WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)

            }
        }
    }
    
}

