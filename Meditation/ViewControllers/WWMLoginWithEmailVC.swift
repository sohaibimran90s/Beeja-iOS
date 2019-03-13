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
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserEmail: UILabel!
    
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
            self.lblUserName.text = self.userData.name
            self.lblUserEmail.text = self.userData.email
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
        WWMHelperClass.showSVHud()
        let param = [
            "email": isFromWelcomeBack ? self.userData.email: txtViewEmail.text!,
            "password":txtViewPassword.text!,
            "deviceId": kDeviceID,
            "deviceToken" : appPreference.getDeviceToken(),
            "DeviceType": kDeviceType,
            "loginType": kLoginTypeEmail,
            "profileImage":"",
            "socialId":"",
            "name":"",
            "model": UIDevice.current.model,
            "version": UIDevice.current.systemVersion
        ]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_LOGIN, headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                
                if let userProfile = result["userprofile"] as? [String:Any] {
                    if let isProfileCompleted = userProfile["IsProfileCompleted"] as? Bool {
                        self.appPreference.setIsLogin(value: true)
                        self.appPreference.setUserID(value:"\(userProfile["user_id"] as! Int)")
                        self.appPreference.setUserToken(value: userProfile["token"] as! String)
                        self.appPreference.setUserName(value: userProfile["name"] as! String)
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
                    WWMHelperClass.showPopupAlertController(sender: self, message: result["message"] as! String, title: kAlertTitle)
                }
                
            }else {
                WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)

            }
            WWMHelperClass.dismissSVHud()
        }
    }
    
}

