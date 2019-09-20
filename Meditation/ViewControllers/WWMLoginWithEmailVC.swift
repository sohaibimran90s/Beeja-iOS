//
//  WWMLoginWithEmailVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 07/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import Crashlytics

class WWMLoginWithEmailVC:WWMBaseViewController,UITextFieldDelegate {
    
    @IBOutlet weak var txtViewPassword: UITextField!
    @IBOutlet weak var txtViewEmail: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnForgotPassword: UIButton!
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserEmail: UILabel!
    
    @IBOutlet weak var viewUserEmail: UIView!
    @IBOutlet weak var viewUserPass: UIView!
    
    @IBOutlet weak var viewContinueAsEmail: UIView!
    @IBOutlet weak var viewEmail: UIView!
    var tap = UITapGestureRecognizer()
    
    var isFromWelcomeBack = false
    let appPreffrence = WWMAppPreference()
    var userEmail: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        
        if isFromWelcomeBack {
            
            self.btnLogin.setTitle(KNEXT, for: .normal)
            viewContinueAsEmail.isHidden = false
            
            print("getuserdata..... \(self.appPreffrence.getUserData())")
            //self.appPreffrence.setUserData(value: result["user_profile"] as! [String : Any])
            let getuserdata = self.appPreffrence.getUserData()
            
            if let name = getuserdata["name"] as? String{
                self.lblUserName.text = name
            }
            
            //self.lblUserLoginType.text = self.userData.email
            //self.lblUserName.text = self.userData.name
            //self.lblUserEmail.text = self.userData.email
            
            viewEmail.isHidden = true
            
            if let userEmail = getuserdata["email"] as? String{
                self.userEmail = userEmail
            let userLoginTypeArray = userEmail.components(separatedBy: "@")
            if userLoginTypeArray.count > 1 {
                if userLoginTypeArray[0].count > 3{
                    var myString: String = String(userLoginTypeArray[0].prefix(3))
                    print(myString)
                    
                    let abc = myString.count
                    let pqr = userLoginTypeArray[0].count
                    let mno = pqr - abc
                    
                    for _ in 0..<mno{
                        myString.append(contentsOf: "*")
                    }
                    
                    myString.append(contentsOf: "@")
                    myString.append(contentsOf: userLoginTypeArray[1])
                    print(myString)
                    
                    self.lblUserEmail.text = myString
                    
                }else if userLoginTypeArray[0].count > 1{
                    var myString: String = String(userLoginTypeArray[0].prefix(1))
                    print(myString)
                    
                    let abc = myString.count
                    let pqr = userLoginTypeArray[0].count
                    let mno = pqr - abc
                    
                    for _ in 0..<mno{
                        myString.append(contentsOf: "*")
                    }
                    
                    myString.append(contentsOf: "@")
                    myString.append(contentsOf: userLoginTypeArray[1])
                    print(myString)
                    
                    self.lblUserEmail.text = myString
                }else{
                    
                    self.lblUserEmail.text = userEmail
                }
                print(userLoginTypeArray[0])
                print(userLoginTypeArray[1])
            }else{
                self.lblUserEmail.text = userEmail
            }
          }
        }else {
            viewContinueAsEmail.isHidden = true
            viewEmail.isHidden = false
        }
        
        self.setNavigationBar(isShow: false, title: "")
        self.btnLogin.layer.borderWidth = 2.0
        self.btnLogin.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
    }
    
    @objc func KeyPadTap() -> Void {
        self.view .endEditing(true)
    }
    
    //MARK:- UITextField Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tap = UITapGestureRecognizer(target: self, action: #selector(self.KeyPadTap))
        view.addGestureRecognizer(tap)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view .removeGestureRecognizer(tap)
        if txtViewPassword.text! == ""{
            self.viewUserPass.layer.borderColor = UIColor.clear.cgColor
            self.btnLogin.setTitleColor(UIColor.white, for: .normal)
            self.btnLogin.backgroundColor = UIColor.clear
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        }
        if textField == txtViewPassword {
            let str = txtViewPassword.text! + string
            if str.count > 0 {
                self.viewUserPass.layer.borderWidth = 1.0
                self.viewUserPass.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
                self.btnLogin.setTitleColor(UIColor.black, for: .normal)
                self.btnLogin.backgroundColor = UIColor.init(hexString: "#00eba9")!
            }
            if str.count > 50 {
                return false
            }
        }
        return true
    }
    
    // MARK: Button Action
    
    @IBAction func btnLoginAction(_ sender: UIButton) {
        if !isFromWelcomeBack {
            if txtViewEmail.text == "" {
                WWMHelperClass.showPopupAlertController(sender: self, message: KDONTFORGETEMAIL, title: kAlertTitle)
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
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
            "email": isFromWelcomeBack ? self.userEmail: txtViewEmail.text!,
            "password":txtViewPassword.text!,
            "deviceId": kDeviceID,
            "deviceToken" : appPreference.getDeviceToken(),
            "DeviceType": kDeviceType,
            "loginType": kLoginTypeEmail,
            "profile_image":"",
            "socialId":"",
            "name":"",
            "model": UIDevice.current.model,
            "version": UIDevice.current.systemVersion
        ]
        
        print("backparam... \(param)")
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_LOGIN, context: "WWMLoginWithEmailVC", headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                
                if let userProfile = result["userprofile"] as? [String:Any] {
                    if let isProfileCompleted = userProfile["IsProfileCompleted"] as? Bool {
                        self.appPreference.setIsLogin(value: true)
                        self.appPreference.setUserID(value:"\(userProfile["user_id"] as? Int ?? 0)")
                        
                        //self.appPreference.setUserID(value:"1601")
                        
                        Crashlytics.sharedInstance().setUserIdentifier("userId \(userProfile["user_id"] as? Int ?? 0)")
                        
                        self.appPreference.setUserToken(value: userProfile["token"] as? String ?? "")
                        self.appPreference.setUserName(value: userProfile["name"] as? String ?? "")
                        self.appPreference.setIsProfileCompleted(value: isProfileCompleted)
                        self.appPreference.setType(value: userProfile["type"] as? String ?? "")
                        self.appPreference.setGuideType(value: userProfile["guided_type"] as? String ?? "")
                        if isProfileCompleted {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                            UIApplication.shared.keyWindow?.rootViewController = vc
                        }else {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }else {
                    WWMHelperClass.showPopupAlertController(sender: self, message: result["message"] as? String ?? KFAILTORECOGNISEEMAIL, title: kAlertTitle)
                }
            }else {
                if error?.localizedDescription == "The Internet connection appears to be offline."{
                    WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                }else{
                    WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? KFAILTORECOGNISEEMAIL, title: kAlertTitle)
                }
                

            }
            //WWMHelperClass.dismissSVHud()
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    //1. If user has selected mood meter but not has entered journal input. E.g. Thanks, your mood expression has been recorded.
    //2. If user has not selected mood and skipped but has entered journal inputs. E.g., Thanks, your journal entry has been recorded
}

