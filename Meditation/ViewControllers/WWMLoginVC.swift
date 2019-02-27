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

class WWMLoginVC: WWMBaseViewController, GIDSignInDelegate,GIDSignInUIDelegate {

    var isFromWelcomeBack = false
    
    @IBOutlet weak var viewStartBeeja: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

       
        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setNavigationBar(isShow: false, title: "")
    }
    func setupView(){
        
        viewStartBeeja.layer.borderWidth = 2.0
        viewStartBeeja.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
//        if isFromWelcomeBack {
//            viewStartBeeja.isHidden = false
//        }else {
//            viewStartBeeja.isHidden = true
//        }
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
                                    "profileImage":"http://graph.facebook.com/\(fbData["id"] ?? "")/picture?type=large",
                                    "socialId":"\(fbData["id"] ?? "")",
                                    "name":"\(fbData["name"] ?? "")"
                                ]
                                self.loginWithSocial(param: param as Dictionary<String, Any>)
                            }else {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupEmailVC") as! WWMSignupEmailVC
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
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupNameVC") as! WWMSignupNameVC
        self.navigationController?.pushViewController(vc, animated: true)
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
                "profileImage":profileImage?.absoluteString,
                "socialId":userId,
                "name":fullName
            ]
            self.loginWithSocial(param: param as Dictionary<String, Any>)
            
        }
    }
    
    func loginWithSocial(param:[String : Any]) {

        WWMHelperClass.showSVHud()
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
            WWMHelperClass.dismissSVHud()
        }
    }
    
}
