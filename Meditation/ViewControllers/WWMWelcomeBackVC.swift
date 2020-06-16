  
  
  
  //
//  WWMWelcomeBackVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 08/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit
import FirebaseCrashlytics

class WWMWelcomeBackVC: WWMBaseViewController, GIDSignInDelegate,GIDSignInUIDelegate{

    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserLoginType: UILabel!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var btnUseAnother: UIButton!
    
    let appPreffrence = WWMAppPreference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    //1. If user has selected mood meter but not has entered journal input. E.g. Thanks, your mood expression has been recorded.
    override func viewWillAppear(_ animated: Bool) {
        self.setNavigationBar(isShow: false, title: "")
    }
    
    func setupView(){
        self.btnUseAnother.layer.borderWidth = 2.0
        self.btnUseAnother.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        //print("getuserdata..... \(self.appPreffrence.getUserData())")
        //self.appPreffrence.setUserData(value: result["user_profile"] as! [String : Any])
        let getuserdata = self.appPreffrence.getUserData()
        
        if let name = getuserdata["name"] as? String{
            self.lblUserName.text = name
        }
        
        //self.lblUserLoginType.text = self.userData.email
        
        if let userEmail = getuserdata["email"] as? String{
            let userLoginTypeArray = userEmail.components(separatedBy: "@")
            if userLoginTypeArray.count > 1 {
                if userLoginTypeArray[0].count > 3{
                    
                    print(String("String(userLoginTypeArray[0]... \(userLoginTypeArray[0])"))
                    var myString: String = "\(userLoginTypeArray[0].prefix(3))"
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
                    
                    self.lblUserLoginType.text = myString
                    
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
                    
                    self.lblUserLoginType.text = myString
                }else{
                    
                    self.lblUserLoginType.text = userEmail
                }
                //print(userLoginTypeArray[0])
                //print(userLoginTypeArray[1])
            }else{
                self.lblUserLoginType.text = userEmail
            }

        }
        imageViewProfile.sd_setImage(with: URL(string: self.userData.profileImage), placeholderImage: UIImage(named: "AppIcon.png"))
        
    }

    
    // MARK: Button Action
    
    @IBAction func btnContinueAction(_ sender: Any) {
        if self.userData.loginType == kLoginTypeEmail {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLoginWithEmailVC") as! WWMLoginWithEmailVC
            vc.isFromWelcomeBack = true
            self.navigationController?.pushViewController(vc, animated: false)
        }else if self.userData.loginType == kLoginTypeFacebook {
            self.continueWithFacebook()
        }else if self.userData.loginType == kLoginTypeGoogle {
            self.continueWithGoogle()
        }else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLoginWithEmailVC") as! WWMLoginWithEmailVC
            vc.isFromWelcomeBack = true
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    @IBAction func btnAnotherAccountAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLoginVC") as! WWMLoginVC
        vc.isFromWelcomeBack = true
        self.navigationController?.pushViewController(vc, animated: false)
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
    func continueWithGoogle() {
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.signIn()
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
    
    
    func continueWithFacebook() {
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
                                var email = ""
                                if let fbEmail = fbData["email"] as? String {
                                    email = fbEmail
                                }else {
                                    email = self.userData.email
                                }
                                let param = [
                                    "email": email,
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
                                self.loginWithSocial(param: param as Dictionary<String, Any>)
                            }


                        }else {
                            print(error?.localizedDescription ?? "")
                        }
                    })
                }
            }

        }
    }
    
    
    ///MARK:- Login API Calling
    
    func loginWithSocial(param:[String : Any]) {
        
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        WWMWebServices.requestAPIWithBody(param:param , urlString: URL_LOGIN, context: "WWMWelcomeBackVC", headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                if let userProfile = result["userprofile"] as? [String:Any] {
                    
                    //print("userProfile WWMWelcomeBackVC... \(userProfile)")
                    
                    DispatchQueue.global(qos: .background).async {
                        self.bannerAPI()
                    }
                    
                    if let isProfileCompleted = userProfile["IsProfileCompleted"] as? Bool {
                        self.appPreference.setIsLogin(value: true)
                    self.appPreference.setUserID(value:"\(userProfile["user_id"] as? Int ?? 0)")
                        //Crashlytics.sharedInstance().setUserIdentifier("userId \(userProfile["user_id"] as? Int ?? 0)")
                        
                        Crashlytics.crashlytics().setUserID("userId \(userProfile["user_id"] as? Int ?? 0)")
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "logoutSuccessful"), object: nil)
                        
                        self.appPreference.setEmail(value: userProfile["email"] as? String ?? "")
                        self.appPreference.setUserToken(value: userProfile["token"] as? String ?? "")
                        self.appPreference.setIsProfileCompleted(value: isProfileCompleted)
                        if isProfileCompleted {
                            self.appPreference.setGetProfile(value: true)
                         
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                            UIApplication.shared.keyWindow?.rootViewController = vc
                            
                            
//                            if #available(iOS 13.0, *) {
//                                //                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
//                                let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
//                                window?.rootViewController = AppDelegate.sharedDelegate().animatedTabBarController()
//                            } else {
//                                //                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
//                                UIApplication.shared.keyWindow?.rootViewController = AppDelegate.sharedDelegate().animatedTabBarController()
//                            }
                            
                        }else {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignUpFacebookVC") as! WWMSignUpFacebookVC
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }else {
                    WWMHelperClass.showPopupAlertController(sender: self, message: result["message"] as? String ?? "", title: kAlertTitle)
                }
                
            }else {
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

    //bannerAPI
    func bannerAPI() {
        
    let param = ["user_id": self.appPreference.getUserID()] as [String : Any]
    WWMWebServices.requestAPIWithBody(param: param, urlString: URL_BANNERS, context: "WWMWelcomeBackVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if let _ = result["success"] as? Bool {
                //print("result")
                if let result = result["result"] as? [Any]{
                    self.appPreffrence.setBanners(value: result)
                }
            }
        }
    }
}
