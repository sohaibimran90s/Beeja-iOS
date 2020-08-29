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
//import GoogleSignIn
//import FBSDKLoginKit

class WWMSignupEmailVC: WWMBaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtViewName: UITextField!
    @IBOutlet weak var viewName: UIView!
    @IBOutlet weak var txtViewEmail: UITextField!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var txtViewPassword: UITextField!
    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnBackTopConstraint: NSLayoutConstraint!
    
    var name: String = ""
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
        if textField == txtViewName {
            
            if txtViewName.text ?? "" == ""{
                self.viewName.layer.borderColor = UIColor.clear.cgColor
            }
            
        }else if textField == self.txtViewEmail{
            self.txtViewEmail.text = self.txtViewEmail.text?.trimmingTrailingSpaces()
            if txtViewEmail.text ?? "" == ""{
                self.viewEmail.layer.borderColor = UIColor.clear.cgColor
            }
        }else if textField == self.txtViewPassword{
            if txtViewPassword.text ?? "" == ""{
                self.viewPassword.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtViewName {
            
            let str = txtViewName.text ?? "" + string
            if string == "" {
                return true
            }
            let strRegEx = "[A-Z a-z]"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", strRegEx)
            if !emailTest.evaluate(with: string) {
                return false
            }
            
            if str.count > 0 {
                self.viewName.layer.borderWidth = 1.0
                self.viewName.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
            }
            if str.count > 50 {
                return false
            }
        }else if textField == self.txtViewEmail{
            let str = txtViewEmail.text! + string
            
            if (self.isValidEmail(strEmail: str)) {
                self.viewEmail.layer.borderWidth = 1.0
                self.viewEmail.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
            }
            return true
        }else if textField == txtViewPassword{
            let str = txtViewPassword.text ?? "" + string
            if string == "" {
                return true
            }
            
            if str.count > 0 {
                self.viewPassword.layer.borderWidth = 1.0
                self.viewPassword.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
            }
            if str.count > 50 {
                return false
            }
        }
        return true
        
    }
    
    @IBAction func btnSignUpAction(_ sender: UIButton) {
        
        if self.txtViewName.text == "" {
            self.name = "You"
        }else{
            self.name = self.txtViewName.text!
        }
        
        if txtViewEmail.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message:Validation_EmailMessage , title: kAlertTitle)
        }else if !(self.isValidEmail(strEmail: txtViewEmail.text!.trimmingTrailingSpaces())){
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_invalidEmailMessage, title: kAlertTitle)
        }else if txtViewPassword.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: KENTERPASS, title: kAlertTitle)
        }else{
            self.signUpApi()
        }
    }
    
    func signUpApi() {
        // Analytics
        WWMHelperClass.sendEventAnalytics(contentType: "SIGN_UP", itemId: "WHATS_YOUR_PASSWORD", itemName: "")
        
        self.view.endEditing(true)
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
            "email": txtViewEmail.text ?? "",
            "deviceToken" : appPreference.getDeviceToken(),
            "deviceId": kDeviceID,
            "DeviceType": kDeviceType,
            "loginType": kLoginTypeEmail,
            "name":self.name,
            "model": UIDevice.current.model,
            "version": UIDevice.current.systemVersion,
            "password": self.txtViewPassword.text!
        ]
        
        //print("name... \(self.name) password... \(self.txtViewPassword.text ?? "") param... \(param)")
        
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_SIGNUP, context: "WWMSignupEmailVC", headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                
                //print("signup result... \(result)")
                if let userProfile = result["userprofile"] as? [String:Any] {
                    
                    //print("userProfile WWMSignupEmailVC... \(userProfile)")
                    
                    self.appPreference.setEmail(value: userProfile["email"] as? String ?? "")
                    self.appPreference.setUserToken(value: userProfile["token"] as? String ?? "")
                    self.appPreference.setUserID(value: "\(userProfile["user_id"] as? Int ?? 0)")
                    //Crashlytics.sharedInstance().setUserIdentifier("userId \(userProfile["user_id"] as? Int ?? 0)")
                    Crashlytics.crashlytics().setUserID("userId \(userProfile["user_id"] as? Int ?? 0)")
                    self.appPreference.setCheckEnterSignupLogin(value: true)
                    
                    self.appPreference.setUserName(value: userProfile["name"] as? String ?? "")
                    self.appPreference.setIsLogin(value: true)
                    self.appPreference.setIsProfileCompleted(value: false)
                    self.appPreference.setType(value: userProfile["type"] as? String ?? "")
                    self.appPreference.setGuideType(value: userProfile["guided_type"] as? String ?? "")
                    self.appPreference.setGuideTypeFor3DTouch(value: userProfile["guided_type"] as? String ?? "")
                    self.appPreference.setHomePageURL(value: userProfile["home_page_url"] as! String)
                    self.appPreference.setLearnPageURL(value: userProfile["learn_page_url"] as! String)
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMConOnboardingVC") as! WWMConOnboardingVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
//                    GIDSignIn.sharedInstance()?.signOut()
                    WWMHelperClass.showPopupAlertController(sender: self, message:  result["message"] as? String ?? "Unauthorized request", title: kAlertTitle)
                }
                
            }else {
//                GIDSignIn.sharedInstance()?.signOut()
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
    
    //MARK: Social Login & Terms n Condition button
    /*
    @IBAction func btnLoginWithFacebookAction(_ sender: UIButton) {
        WWMHelperClass.sendEventAnalytics(contentType: "SIGN_IN", itemId: "FACEBOOK", itemName: "")
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { (loginResult, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "")
            }else {
                if (loginResult?.isCancelled)! {
                    //print("User Cancellled To login with fb")
                }else {
                    let req = GraphRequest.init(graphPath: "me", parameters: ["fields":"email,name"], tokenString:loginResult?.token?.tokenString , version: nil, httpMethod: HTTPMethod(rawValue: "GET"))
                    req.start(completionHandler: { (connection, result, error) in
                        if error == nil {
                            print(result!)
                            if let fbData = result as? [String:Any] {
                                if let fbEmail = fbData["email"] as? String {
                                    
                                    let param = [
                                        "email": fbEmail,
                                        "password":"",
                                        "deviceId": kDeviceID,
                                        "DeviceType": kDeviceType,
                                        "deviceToken" : self.appPreference.getDeviceToken(),
                                        "loginType": kLoginTypeFacebook,
                                        "profile_image":"http://graph.facebook.com/\(fbData["id"] ?? "")/picture?type=large",
                                        "socialId":"\(fbData["id"] ?? "")",
                                        "name":"\(fbData["name"] ?? "")",
                                        "model": UIDevice.current.model,
                                        "version": UIDevice.current.systemVersion
                                    ]
                                    
                                    //print("param facebook... \(param)")
                                    
                                    self.loginWithSocial(param: param as Dictionary<String, Any>)
                                }else {
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignUpFacebookVC") as! WWMSignUpFacebookVC
                                    vc.fbData = fbData
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        }else {
                            print(error?.localizedDescription ?? "")
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func btnLoginWithGoogleAction(_ sender: UIButton) {
        WWMHelperClass.sendEventAnalytics(contentType: "SIGN_IN", itemId: "GOOGLE", itemName: "")
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    */
    
    @IBAction func btnPrivacyPolicyAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWebViewVC") as! WWMWebViewVC
        vc.strUrl = URL_PrivacyPolicy
        vc.strType = "Privacy Policy"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnTermsOfUseAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWebViewVC") as! WWMWebViewVC
        vc.strUrl = URL_TermsnCondition
        vc.strType = "Terms & Conditions"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // Google Login Delegate Method
    /*
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            // let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            // let givenName = user.profile.givenName
            // let familyName = user.profile.familyName
            let email = user.profile.email
            let profileImage = user.profile.imageURL(withDimension: 400)
            let param = [
                "email": email,
                "password":"",
                "deviceId": kDeviceID,
                "DeviceType": kDeviceType,
                "deviceToken" : self.appPreference.getDeviceToken(),
                "loginType": kLoginTypeGoogle,
                "profile_image":profileImage?.absoluteString,
                "socialId":userId,
                "name":fullName,
                "model": UIDevice.current.model,
                "version": UIDevice.current.systemVersion
            ]
            
            self.loginWithSocial(param: param as Dictionary<String, Any>)
            
        }
    }
 */
    
    func loginWithSocial(param:[String : Any]) {
        self.view.endEditing(true)

        WWMHelperClass.showLoaderAnimate(on: self.view)
        WWMWebServices.requestAPIWithBody(param:param , urlString: URL_LOGIN, context: "WWMSignupEmailVC", headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                
                if let userProfile = result["userprofile"] as? [String:Any] {
                    
                    //print("userProfile WWMSignupEmailVC... \(userProfile)")
                    
                    DispatchQueue.global(qos: .background).async {
                        self.getInviteAcceptAPI(context1: "WWMLoginVC")
                    }
                    
                    if let isProfileCompleted = userProfile["IsProfileCompleted"] as? Bool {
                        self.appPreference.setIsLogin(value: true)
                        self.appPreference.setUserID(value:"\(userProfile["user_id"] as? Int ?? 0)")
                        //Crashlytics.sharedInstance().setUserIdentifier("userId \(userProfile["user_id"] as? Int ?? 0)")
                        
                        Crashlytics.crashlytics().setUserID("userId \(userProfile["user_id"] as? Int ?? 0)")
                        
                        //NotificationCenter.default.post(name: Notification.Name(rawValue: "logoutSuccessful"), object: nil)
                        
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
                            
                            // UIApplication.shared.keyWindow?.rootViewController = AppDelegate.sharedDelegate().animatedTabBarController()
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
