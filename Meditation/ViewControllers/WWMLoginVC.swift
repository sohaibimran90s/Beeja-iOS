//
//  WWMLoginVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 03/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit
import Lottie
import Crashlytics

class WWMLoginVC: WWMBaseViewController, GIDSignInDelegate,GIDSignInUIDelegate {

    var isFromWelcomeBack = false
    
    @IBOutlet weak var viewStartBeeja: UIView!
    @IBOutlet weak var lblSignup: UILabel!
    @IBOutlet weak var imgSignup: UIImageView!
    @IBOutlet weak var viewLottieAnimation: UIView!
    
    var animationView = AnimationView()
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.imgSignup.isHidden = true
        self.viewLottieAnimation.isHidden = false
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.imgSignup.isHidden = true
        self.viewLottieAnimation.isHidden = false
        animationView.play()
    }
    
    @IBAction func btnSignupTouchDown(_ sender: Any) {
        
        animationView.stop()
        self.viewLottieAnimation.isHidden = true
        self.imgSignup.isHidden = false
        self.viewStartBeeja.backgroundColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0)
        viewStartBeeja.layer.borderColor = UIColor.clear.cgColor
        self.lblSignup.textColor = UIColor.black
        self.imgSignup.image = UIImage.init(named: "iconToAnimateCopy2")
        
//        self.viewStartBeeja.backgroundColor = UIColor.white
//        viewStartBeeja.layer.borderColor = UIColor.clear.cgColor
//        self.lblSignup.textColor = UIColor.black
//        self.imgSignup.image = UIImage.init(named: "iconToAnimateCopy2")
    }
    
    func setupView(){
        
        self.setNavigationBar(isShow: false, title: "")
        
        //self.timer = Timer.scheduledTimer(timeInterval: 1.3, target: self, selector: #selector(animateView), userInfo: nil, repeats: false)
        
        animationView = AnimationView(name: "login11")
        animationView.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        viewLottieAnimation.addSubview(animationView)
        view.addSubview(viewLottieAnimation)
        animationView.play()
        
        self.lblSignup.textColor = UIColor.white
        self.imgSignup.image = UIImage.init(named: "startBeeja_Icon")
        self.viewStartBeeja.backgroundColor = UIColor.clear
        viewStartBeeja.layer.borderWidth = 2.0
        viewStartBeeja.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
//        if isFromWelcomeBack {
//            viewStartBeeja.isHidden = false
//        }else {
//            viewStartBeeja.isHidden = true
//        }
    }
    
    //MARK: Animate View
    @objc func animateView(){
        animationView.stop()
    }
    
    // MARK: Button Action
    
    @IBAction func btnLoginWithEmailAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLoginWithEmailVC") as! WWMLoginWithEmailVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnLoginWithFacebookAction(_ sender: UIButton) {
        
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (loginResult, error) in

            if error != nil {
                print(error?.localizedDescription ?? "")
            }else {
                if (loginResult?.isCancelled)! {
                    print("User Cancellled To login with fb")
                }else {
                let req = FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"email,name"], tokenString:loginResult?.token.tokenString , version: nil, httpMethod: "GET")
                req?.start(completionHandler: { (connection, result, error) in
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
                                
                                print("param facebook... \(param)")
                                
                                self.loginWithSocial(param: param as Dictionary<String, Any>)
                            }else {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupEmailVC") as! WWMSignupEmailVC
                                vc.isFromFb = true
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
 
    
    @IBAction func btnStartBe(_ sender: UIButton) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupNameVC") as! WWMSignupNameVC
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    @IBAction func btnLoginWithGoogleAction(_ sender: UIButton) {
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
                print("result.... \(result)")
                if let userProfile = result["userprofile"] as? [String:Any] {
                    if let isProfileCompleted = userProfile["IsProfileCompleted"] as? Bool {
                        self.appPreference.setIsLogin(value: true)
                        self.appPreference.setUserID(value:"\(userProfile["user_id"] as? Int ?? 0)")
                        Crashlytics.sharedInstance().setUserIdentifier("userId \(userProfile["user_id"] as? Int ?? 0)")

                        
                        self.appPreference.setUserToken(value: userProfile["token"] as? String ?? "Unauthorized request")
                        self.appPreference.setUserName(value: userProfile["name"] as? String ?? "Unauthorized request")
                        self.appPreference.setIsProfileCompleted(value: isProfileCompleted)
                        self.appPreference.setType(value: userProfile["type"] as? String ?? "")
                        self.appPreference.setGuideType(value: userProfile["guided_type"] as? String ?? "")
                        if isProfileCompleted {
                            if #available(iOS 13.0, *) {
                                let vc = self.storyboard?.instantiateViewController(identifier: "WWMTabBarVC") as! WWMTabBarVC
                                let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                                window?.rootViewController = vc
                            } else {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                                UIApplication.shared.keyWindow?.rootViewController = vc
                            }
                        }else {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
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
    
}
