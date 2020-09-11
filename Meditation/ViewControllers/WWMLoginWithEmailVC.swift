//
//  WWMLoginWithEmailVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 07/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import FirebaseCrashlytics
import GoogleSignIn
import FBSDKLoginKit
import AuthenticationServices


class WWMLoginWithEmailVC:WWMBaseViewController, UITextFieldDelegate, GIDSignInDelegate,GIDSignInUIDelegate {
    
    @IBOutlet weak var txtViewPassword: UITextField!
    @IBOutlet weak var txtViewEmail: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserEmail: UILabel!
    @IBOutlet weak var lblFogetPass: UILabel!
    @IBOutlet weak var viewUserEmail: UIView!
    @IBOutlet weak var viewUserPass: UIView!
    @IBOutlet weak var viewContinueAsEmail: UIView!
    @IBOutlet weak var viewSocialLogin: UIView!
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnBackTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loginScrollView: UIScrollView!
    
    var tap = UITapGestureRecognizer()
    
    var isFromWelcomeBack = false
    let appPreffrence = WWMAppPreference()
    var userEmail: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if WWMHelperClass.hasTopNotch{
            self.btnBackTopConstraint.constant = 30
        }else{
            self.btnBackTopConstraint.constant = 10
        }

        self.underLineLbl()
        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    func underLineLbl(){
    
        let underLineColor: UIColor = UIColor.init(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0)
        let underLineStyle = NSUnderlineStyle.single.rawValue

        let labelAtributes:[NSAttributedString.Key : Any]  = [NSAttributedString.Key.underlineStyle: underLineStyle,
            NSAttributedString.Key.underlineColor: underLineColor
        ]

        let underlineAttributedString = NSAttributedString(string: "Forgot password?", attributes: labelAtributes)

        lblFogetPass.attributedText = underlineAttributedString
    }
    
    func setupView(){
        
        if isFromWelcomeBack {
            
            self.stackViewTopConstraint.constant = 31
            self.btnLogin.setTitle(KNEXT, for: .normal)
            viewContinueAsEmail.isHidden = false
            
            //print("getuserdata..... \(self.appPreffrence.getUserData())")
            //self.appPreffrence.setUserData(value: result["user_profile"] as! [String : Any])
            let getuserdata = self.appPreffrence.getUserData()
            
            if let name = getuserdata["name"] as? String{
                self.lblUserName.text = name
            }
            
            //self.lblUserLoginType.text = self.userData.email
            //self.lblUserName.text = self.userData.name
            //self.lblUserEmail.text = self.userData.email
            
            viewSocialLogin.isHidden = true
            viewUserEmail.isHidden = true
            
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
            self.stackViewTopConstraint.constant = -126
            viewContinueAsEmail.isHidden = true
            viewSocialLogin.isHidden = false
            viewUserEmail.isHidden = false
        }
        
        self.setNavigationBar(isShow: false, title: "")
        self.btnLogin.layer.borderWidth = 2.0
        self.btnLogin.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
    }
    
    @objc func KeyPadTap() -> Void {
        self.view.endEditing(true)
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
    
    @IBAction func clickSignup() {
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "WWMSignupSocialVC") as! WWMSignupSocialVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
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
        }else{
            self.loginWithEmail()
        }
    }
    
    @IBAction func btnForgotPasswordAction(_ sender: UIButton) {
        WWMHelperClass.sendEventAnalytics(contentType: "SIGN_IN", itemId: "FORGOT_PASSWORD", itemName: "")
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
        
        //print("backparam... \(param)")
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_LOGIN, context: "WWMLoginWithEmailVC", headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                
                if let userProfile = result["userprofile"] as? [String:Any] {
                    
                    //print("userProfile WWMLoginWithEmailVC... \(userProfile)")
                    DispatchQueue.global(qos: .background).async {
                        self.getInviteAcceptAPI(context1: "WWMLoginVC")
                    }
                    
                    if let isProfileCompleted = userProfile["IsProfileCompleted"] as? Bool {
                        Logger.shared.setIsLogging(value: true)
                        self.appPreference.setIsLogin(value: true)
                        self.appPreference.setUserID(value:"\(userProfile["user_id"] as? Int ?? 0)")
                                                
                        //self.appPreference.setUserID(value:"1715")
                        
                        //Crashlytics.sharedInstance().setUserIdentifier("userId \(userProfile["user_id"] as? Int ?? 0)")
                        Crashlytics.crashlytics().setUserID("userId \(userProfile["user_id"] as? Int ?? 0)")
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "logoutSuccessful"), object: nil)
                        
                        self.appPreference.setEmail(value: userProfile["email"] as? String ?? "")
                        self.appPreference.setUserToken(value: userProfile["token"] as? String ?? "")
                        self.appPreference.setUserName(value: userProfile["name"] as? String ?? "")
                        self.appPreference.setIsProfileCompleted(value: isProfileCompleted)
                        self.appPreference.setType(value: userProfile["type"] as? String ?? "")
                        self.appPreference.setGuideType(value: userProfile["guided_type"] as? String ?? "")
                        self.appPreference.setGuideTypeFor3DTouch(value: userProfile["guided_type"] as? String ?? "")
                        if isProfileCompleted {
                            self.appPreference.setGetProfile(value: true)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                            UIApplication.shared.keyWindow?.rootViewController = vc
                            
                            
                        }else {
                            //let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMConOnboardingVC") as! WWMConOnboardingVC
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
    
    
    //MARK: Social Login & Terms n Condition button
    
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
       
    func loginWithSocial(param:[String : Any]) {
        
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        WWMWebServices.requestAPIWithBody(param:param , urlString: URL_LOGIN, context: "WWMLoginVC", headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                //print("result.... \(result)")
                if let userProfile = result["userprofile"] as? [String:Any] {
                    //print("userProfile WWMLoginVC... \(userProfile)")
                    
                    if let isProfileCompleted = userProfile["IsProfileCompleted"] as? Bool {
                        self.appPreference.setIsLogin(value: true)
                        self.appPreference.setUserID(value:"\(userProfile["user_id"] as? Int ?? 0)")
                        //Crashlytics.sharedInstance().setUserIdentifier("userId \(userProfile["user_id"] as? Int ?? 0)")
                        
                        Crashlytics.crashlytics().setUserID("userId \(userProfile["user_id"] as? Int ?? 0)")
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "logoutSuccessful"), object: nil)
                        
                        self.appPreference.setEmail(value: userProfile["email"] as? String ?? "")
                        self.appPreference.setUserToken(value: userProfile["token"] as? String ?? "Unauthorized request")
                        self.appPreference.setUserName(value: userProfile["name"] as? String ?? "Unauthorized request")
                        self.appPreference.setIsProfileCompleted(value: isProfileCompleted)
                        self.appPreference.setType(value: userProfile["type"] as? String ?? "")
                        self.appPreference.setGuideType(value: userProfile["guided_type"] as? String ?? "")
                        self.appPreference.setGuideTypeFor3DTouch(value: userProfile["guided_type"] as? String ?? "")
                        if isProfileCompleted {
                            self.appPreference.setGetProfile(value: true)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                            UIApplication.shared.keyWindow?.rootViewController = vc
                            
                        }else {
                            //let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMConOnboardingVC") as! WWMConOnboardingVC
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }else {
                    GIDSignIn.sharedInstance()?.signOut()
                    WWMHelperClass.showPopupAlertController(sender: self, message: result["message"] as? String ?? "Unauthorized request", title: kAlertTitle)
                }
                
            }else {
                GIDSignIn.sharedInstance()?.signOut()
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                    
                }
                
            }
            //WWMHelperClass.dismissSVHud()
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    @IBAction func AppleButtonTapped() {
        let authorizationProvider = ASAuthorizationAppleIDProvider()
        let request = authorizationProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension WWMLoginWithEmailVC: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        
        let userIdentifier = appleIDCredential.user
        let userFirstName = appleIDCredential.fullName?.givenName
        let userLastName = appleIDCredential.fullName?.familyName
        let userEmail = appleIDCredential.email
        let fullname = (userFirstName ?? "") + " " + (userLastName ?? "")
        
        UserDefaults.standard.set(userIdentifier, forKey: "apple_id")
        
        if appleIDCredential.fullName != nil {
            UserDefaults.standard.set(fullname, forKey: "apple_fullname")
        }
        if userEmail != nil {
            UserDefaults.standard.set(userEmail, forKey: "apple_email")
        }
        
        print("AppleID Credential Authorization: userId: \(appleIDCredential.user), email: \(String(describing: appleIDCredential.email))")
        
        self.loginWithApple()

    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("AppleID Credential failed with error: \(error.localizedDescription)")
    }
    
    func loginWithApple() {
        
        let email = UserDefaults.standard.string(forKey: "apple_email")
        let userId = UserDefaults.standard.string(forKey: "apple_id")
        let fullName = UserDefaults.standard.string(forKey: "apple_fullname")
        
        let param = [
            "email": email,
            "password":"",
            "deviceId": kDeviceID,
            "DeviceType": kDeviceType,
            "deviceToken" : self.appPreference.getDeviceToken(),
            "loginType": kLoginTypeApple,
            "profile_image":"",
            "socialId":userId,
            "name":fullName,
            "model": UIDevice.current.model,
            "version": UIDevice.current.systemVersion
        ]
        
        self.loginWithSocial(param: param as Dictionary<String, Any>)
    }
}

extension WWMLoginWithEmailVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

