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

class WWMWelcomeBackVC: WWMBaseViewController, GIDSignInDelegate,GIDSignInUIDelegate{

    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserLoginType: UILabel!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var btnUseAnother: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.setNavigationBar(isShow: false, title: "")
    }
    func setupView(){
        self.btnUseAnother.layer.borderWidth = 2.0
        self.btnUseAnother.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.lblUserName.text = self.userData.name
        //self.lblUserLoginType.text = self.userData.email
        
            let userLoginTypeArray = self.userData.email.components(separatedBy: "@")
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
                
                self.lblUserLoginType.text = self.userData.email
            }
            print(userLoginTypeArray[0])
            print(userLoginTypeArray[1])
            }else{
                self.lblUserLoginType.text = self.userData.email
        }
        
        self.imageViewProfile.sd_setImage(with: URL.init(string: self.userData.profileImage), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
        
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
        
        WWMHelperClass.showSVHud()
        WWMWebServices.requestAPIWithBody(param:param , urlString: URL_LOGIN, headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                if let userProfile = result["userprofile"] as? [String:Any] {
                    if let isProfileCompleted = userProfile["IsProfileCompleted"] as? Bool {
                        self.appPreference.setIsLogin(value: true)
                        self.appPreference.setUserID(value:"\(userProfile["user_id"] as! Int)")
                        self.appPreference.setUserToken(value: userProfile["token"] as! String)
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
                if error != nil {
                    WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                }
                
            }
            WWMHelperClass.dismissSVHud()
        }
    }

}
