//
//  WWMSignupEmailVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 10/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit

class WWMSignupEmailVC: WWMBaseViewController {

    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var txtViewEmail: UITextField!
    var name = ""
    var isFromFb = Bool()
    var fbData = [String:Any]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    
    func setupView(){
        
        self.setNavigationBar(isShow: false, title: "")
        
        self.btnNext.layer.borderWidth = 2.0
        self.btnNext.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
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
        WWMHelperClass.showSVHud()
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
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_SIGNUP, headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                
                if let userProfile = result["userprofile"] as? [String:Any] {
                    self.appPreference.setUserToken(value: userProfile["token"] as! String)
                    self.appPreference.setUserID(value: "\(userProfile["user_id"] as! Int)")
                    self.appPreference.setUserName(value: userProfile["name"] as! String)
                    self.appPreference.setIsLogin(value: true)
                    self.appPreference.setIsProfileCompleted(value: false)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    WWMHelperClass.showPopupAlertController(sender: self, message:  result["message"] as! String, title: kAlertTitle)
                }
                
                
            }else {
                WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
            }
            WWMHelperClass.dismissSVHud()
        }
    }
    
    func loginWithSocial() {
        self.view.endEditing(true)
        WWMHelperClass.showSVHud()
        let param = [
            "email": txtViewEmail.text ?? "",
            "password":"",
            "deviceId": kDeviceID,
            "deviceToken" : appPreference.getDeviceToken(),
            "DeviceType": kDeviceType,
            "loginType": kLoginTypeFacebook,
            "profileImage":"http://graph.facebook.com/\(fbData["id"] ?? "")/picture?type=large",
            "socialId":"\(fbData["id"] ?? -1)",
            "name":"\(fbData["name"] ?? "")",
            "model": UIDevice.current.model,
            "version": UIDevice.current.systemVersion
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param:param , urlString: URL_LOGIN, headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
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
                }
            }else {
                WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                
            }
            WWMHelperClass.dismissSVHud()
        }
    }
}
